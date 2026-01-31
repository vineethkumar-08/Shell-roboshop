#!/bin/bash
 USERID=$(id -u)
LOGS_FOLDER="/var/logs/shell-roboshop"  #defining logs folder path
LOGS_FILE="$LOGS_FOLDER/$0.log"   #defining log file path

R="\e[31m"   # Red color
G="\e[32m"   # Green color
Y="\e[33m"   # Yellow color 
N="\e[0m"    # No Color

if [ $USERID -ne 0 ] ; then 
    echo "$R Please run this script with root acess $N" | tee -a $LOGS_FILE     #run as root user 
    exit 1 # exit scode
fi
    mkdir -p $LOGS_FOLDER  #creating logs folder if not exists

# Function to validate the installation status
VALIDATE(){
     
    if [ $1 -ne 0 ] ; then
        echo " $2 $Rinstallation failed...$N" | tee -a $LOGS_FILE # error message 
        exit 1
    else

        echo " $2 $Ginstallation successful....$N"  | tee -a $LOGS_FILE
fi
}