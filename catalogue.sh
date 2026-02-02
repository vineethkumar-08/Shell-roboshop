#!/bin/bash
 USERID=$(id -u)
LOGS_FOLDER="/var/logs/shell-roboshop"  #defining logs folder path
LOGS_FILE="$LOGS_FOLDER/$0.log"   #defining log file path

R="\e[31m"   
G="\e[32m"   
Y="\e[33m"    
N="\e[0m"    

if [ $USERID -ne 0 ] ; then 
    echo "$R Please run this script with root acess $N" | tee -a $LOGS_FILE     #run as root user 
    exit 1 # exit scode
fi
    mkdir -p $LOGS_FOLDER  #creating logs folder if not exists

# Function to validate the installation status
VALIDATE(){
     
    if [ $1 -ne 0 ] ; then
        echo " $2 $Rinstallation failed...$N" | tee -a $LOGS_FILE 
        exit 1
    else

        echo " $2 $Ginstallation successful....$N"  | tee -a $LOGS_FILE
fi
}

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling Nodejs module"   

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Nodejs 20 module"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Nodejs installation"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding roboshop user"

mkdir /app &>> $LOGS_FILE
VALIDATE $? "Creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "Extracting application content"

cd /app 
npm install &>> $LOGS_FILE
VALIDATE $? "Installing application dependencies"