#!/bin/bash

USERID="$(id -u)"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME="$(echo $0 | cut -d "." f1)"
LOG_FILES="$LOG_FOLDER/$SCRIPT_NAME.log"

echo -e "$R This  script started excuting at :: $(date) $N" 


if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR  ::  plese run this script root acces $N"
    exit 1
 else
     echo -e "$G this script running with root access nothing to do $N" 
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

