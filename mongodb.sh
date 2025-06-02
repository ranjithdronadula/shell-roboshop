#!/bin/bash

USERID="$(id -u)"   # CHECK USER ID 
R="\e[31m"          
G="\e[32m"          #BY ADDING COLORS FOR ERRORS SUCCSES
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME="$(echo $0 | cut -d "." f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER 
echo -e "$R This  script started excuting at :: $(date) $N" | tee -a $LOG_FILE  # THIS COMMAND REFER DISPLY THE CONTEND AND STORE IN LOG_FILE


if [ $USERID -ne 0 ]    # CHECK USER ID IF USER ID 0 ITS ROOT USER OTHER WISE NOT ROOT
then
    echo -e "$R ERROR  ::  plese run this script root acces $N" | tee -a $LOG_FILE
    exit 1  # 1 REFER EXIT THE SCRIPT OR STOP
 else
     echo -e "$G this script running with root access nothing to do $N" | tee -a $LOG_FILE
    fi 

  VOLIDATE(){
            if [ $1 -eq 0 ]
            then 
                echo -e "$2 ... IS $Y SUCCSESS $N"
            else
                echo -e "$2.....is $R FAILURE $N "
                 exit 1
           
           fi
            }

      
        #CREATING MONGODB USING SHELL SCRIPT

        cp mongod.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
        VOLIDATE $? "Copying MongoDB repo"

        dnf install mongodb-org -y &>>$LOG_FILE
        VOLIDATE $? "Installing MongoDB Server"

        systemctl enable mongod &>>$LOG_FILE
        VOLIDATE $? "Eanbleing MongoDB"

        systemctl start mongod &>>$LOG_FILE 
        VOLIDATE $? "Starting MongoDB"

        sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
        VALIDATE $? "Editing MongoDB Repo file to Remote Conections"

        systemctl restart mongod &>>$LOG_FILE
        Volidate $? "Restartig MongoDB"