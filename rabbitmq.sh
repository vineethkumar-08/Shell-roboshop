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

cp  $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying RabbitMQ Repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Installing RabbitMQ Server"


systemctl enable rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Enabling RabbitMQ Server"

systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Starting RabbitMQ Server"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Adding RabbitMQ User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Setting RabbitMQ User Permissions"
