#!/bin/bash

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


     dnf module list nodejs
     VALIDATE $? "List Nodejs Servers"

     dnf module disable nodejs -y
     VALIDATE $? "Disabling Nodejs server"

     dnf module enable nodejs:20 -y
     VALIDATE $? Enabling Nodejs:20  Servers"

     dnf install nodejs -y
     VALIDATE $? "Installing Nodejs servers"

     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
     VALIDATE $? "Creating roboshop System User"

     mkdir /app 
     VALIDATE $? "Creating App Directory"

     curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
     VALIDATE $? "Downloading catalogue"
    
     cd /app 
     unzip /tmp/catalogue.zip
     VALIDATE $? "Unziping catalogue"
     
     npm install
     VALIDATE $? "Installing Dependenceis"

     cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
     VALIDATE $? "Coppying catalogue services"

     systemctl daemon-reload
     systemctl enable catalogue 
     VALIDATE $? Enabling catalogue"

     systemctl start catalogue 
     VALIDATE $? "Start catalogue"

     cp $SCRIPT_DIR/mongod.repo /etc/yum.repos.d/mongo.repo
     VALIDATE $? "Coppying client server"

     dnf install mongodb-mongosh -y
     VALIDATE $? "Installing MongoDB Client"

     mongosh --host mongodb.ranjithdaws.site </app/db/master-data.js
     VALIDATE $? "Loading data into MongoDB"

 