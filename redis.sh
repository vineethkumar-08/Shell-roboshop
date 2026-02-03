#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/redis.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disabling Redis Default version"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enabling Redis 7"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "Installing Redis"

# Update listen address
sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf
VALIDATE $? "Updating Redis bind address"

# Disable protected mode (DOCUMENT REQUIRED)
sed -i 's/^protected-mode .*/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Disabling Redis protected mode"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Enabling Redis Service"

systemctl restart redis &>>$LOGS_FILE
VALIDATE $? "Starting Redis Service"