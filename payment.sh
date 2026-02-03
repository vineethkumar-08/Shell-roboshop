#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.devopspractice08.online

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

dnf install python3 gcc python3-devel -y
VALIDATE $? "Installing Python3 and dependencies"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/payments.zip https://roboshop-artifacts.s3.amazonaws.com/payments-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading payments code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payments.zip &>>$LOGS_FILE
VALIDATE $? "Uzip payments code"

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing Python dependencies"

cp $SCRIPT_DIR/payments.service /etc/systemd/system/payments.service
VALIDATE $? "Copying systemd service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading systemd"     

systemctl enable payments &>>$LOGS_FILE
VALIDATE $? "Enabling payments service" 

systemctl start payments &>>$LOGS_FILE
VALIDATE $? "Starting payments service"






