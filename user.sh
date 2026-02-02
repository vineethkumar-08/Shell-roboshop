#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
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

dnf module disable nodejs -y
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Install NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
VALIDATE $? "Creating system user"

mkdir /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "Downloading user code"

cd /app 
VALIDATE $? "Moving to app directory"

unzip /tmp/user.zip
VALIDATE $? "Uzip user code"

cd /app 
npm install 

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Created systemctl service for user"

systemctl daemon-reload
VALIDATE $? "Daemon Reload"

systemctl enable user 
VALIDATE $? "Enabling user service"

systemctl start user
VALIDATE $? "Starting user service"