#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python3 and dependencies"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding roboshop user"

mkdir /app &>>$LOGS_FILE
VALIDATE $? "Creating application directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading payment service code"

cd /app 
VALIDATE $? "Moving to application directory"

unzip /tmp/payment.zip
VALIDATE $? "Extracting payment service code"

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing payment service dependencies"


CP $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Creating systemd service file for payment"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading systemd"

systemctl enable payment &>>$LOGS_FILE
VALIDATE $? "Enabling payment service"
systemctl start payment &>>$LOGS_FILE
VALIDATE $? "Starting payment service"