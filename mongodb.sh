#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +%F:%r)
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
    exit 1
    else 
    echo -e "$G You are root user $N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE

VALIDATE $? "Copied MongoDB repository"

dnf install mongodb-org -y &>> $LOG_FILE

VALIDATE $? "Installing Mongodb-Org"

systemctl enable mongod &>> $LOG_FILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOG_FILE

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE

VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod &>> $LOG_FILE

VALIDATE $? "Restarting MongoDB"

