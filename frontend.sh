#!/bin/bash

START_TIME=$(date +%s)
USERID=(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME="$(echo $0 | cut -d "." f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.LOG"
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


     dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "Restarting nginx"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
