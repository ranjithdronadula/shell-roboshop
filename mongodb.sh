#!/bin/bash

USERID="$(id -u)"
R="\e[31m"
G="\e[31m"
Y="\e[31m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME="$(echo $0 | cut -d "." f1)"
LOG_FILES="$LOG_FOLDER/$SCRIPT_NAME.log"

echo "This  script started excuting at :: $(date)"


if[ $USERID -ne 0 ]
then
    echo -e "ERROR  ::  plese run this script root acces"
    exit 1
 else
     echo -e "this script running with root access nothing to do" 
  fi

  VOLIDATE(){
            if [ $1 -eq 0 ]
            then 
                echo "$2 ... IS SUCCSESS"
            else
                echo  $2.....is FAILURE"
                exit 1
      
            }
