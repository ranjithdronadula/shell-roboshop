#!/bin/bash

START_TIME=$(date +%s)
USER_ID=(id -u)

R="\e[31m"
G="\e[33m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME="$(echo $0 | cut -d "." f1)"
LOG_FILE="$LOG_FOLDWE/$SCRIPT_NMAE.LOG"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not

if [ $USERID -ne 0 ]
then
    echo -e "$G ERROR... Please run this Script root access$N" | tee -a $LOG_FILE
    exit 1
 else   
    echo -e "$Y Yor are running with root aceess..Nothing to do$N" | tee -a $LOG_FILE
fi

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
        if [ $1 -eq 0 ]
        then
            echo -e "$2...... is $G SUCCESS $N" | tee -a $LOG_FILE
         else
            echo -e "$2.......is $R FAILURE $N" | tee -a $LOG_FILE
            exit 1
        fi 
        } 

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven Service"

id roboshop
if [ $? -ne ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATE $? "Creating roboshop system user"
else
    echo -e ""System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app Directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE  
VALIDATE $? "Downloading shipping"

rm -rf /app/*
cd /app 

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping shipping files"


mvn clean package &>>$LOG_FILE
VALIDATE $? "Packaging the shipping application"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Moving and renaming Jar file"


cp SCRIPT_DIR/shipping.services /etc/systemd/system/shipping.service 

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting Shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql"

mysql -h mysql.ranjithdaws.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.ranjithdaws.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.ranjithdaws.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.ranjithdaws.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi
systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting Shipping"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE