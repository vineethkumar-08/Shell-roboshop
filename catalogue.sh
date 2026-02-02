#!/bin/bash
 USERID=$(id -u)
LOGS_FOLDER="/var/logs/shell-roboshop"  #defining logs folder path
LOGS_FILE="$LOGS_FOLDER/$0.log"   #defining log file path

R="\033[31m"
G="\033[32m"
Y="\033[33m"
N="\033[0m"    

if [ $USERID -ne 0 ] ; then 
echo -e "$R Please run this script with root acess $N" | tee -a $LOGS_FILE    exit 1 # exit scode
fi
    mkdir -p $LOGS_FOLDER  #creating logs folder if not exists

# Function to validate the installation status
VALIDATE(){
     
    if [ $1 -ne 0 ] ; then
  echo -e " $2 ${R}installation failed...${N}" | tee -a $LOGS_FILE        exit 1
    else

      echo -e " $2 ${G}installation successful....${N}" | tee -a $LOGS_FILE
      fi
}

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling Nodejs module"   

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Nodejs 20 module"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Nodejs installation"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> $LOGS_FILE
VALIDATE $? "Adding roboshop user"

mkdir /app &>> $LOGS_FILE
VALIDATE $? "Creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>> $LOGS_FILE
cd /app 
unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "Extracting application content"

cd /app 
npm install &>> $LOGS_FILE
VALIDATE $? "Installing application dependencies" 