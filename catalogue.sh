#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE (){
    if [ $1 -ne 0 ]
        then
        echo -e "$2 :: $R FAILED $N"
        else 
        echo -e "$2 :: $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run with root user $N"
    exit 1  # you can give other than 0
    else 
    echo -e "$G You are root user $N"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOG_FILE

VALIDATE $? " Disabling nodejs "

dnf module enable nodejs:18 -y &>> $LOG_FILE

VALIDATE $? " Ebabling nodejs:18 version "

dnf install nodejs -y &>> $LOG_FILE

VALIDATE $? " Installing nodejs "

id roboshop #if roboshop user does not exist, then it is failure

if [$? -ne 0]
then
    useradd roboshop
    VALIDATE $? "Roboshop User is added"
else
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOG_FILE

VALIDATE $? " Creating app directory "

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE

VALIDATE $? " Downloading catalogue application "

cd /app  &>> $LOG_FILE

unzip -o /tmp/catalogue.zip &>> $LOG_FILE

VALIDATE $? " Unzipping catalogue application "

npm install  &>> $LOG_FILE

VALIDATE $? " Installing Dependencies "

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE

VALIDATE $? " copying catalogue service file "

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? " catalogue daemon reload "

systemctl enable catalogue &>> $LOG_FILE

VALIDATE $? " enabling catalogue "

systemctl start catalogue &>> $LOG_FILE

VALIDATE $? " Starting Catalogue "

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE

VALIDATE $? " Coping the mongo.repo "

dnf install mongodb-org-shell -y &>> $LOG_FILE

VALIDATE $? " Installing Mongodb "

mongo --host mongodb.daws76s.fun </app/schema/catalogue.js &>> $LOG_FILE

VALIDATE $? " Connecting mongodb "
