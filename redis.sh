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
    exit 1  # you can give other than 0
    else 
    echo -e "$G You are root user $N"
fi # fi means reverse of if, indicating condition end

dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y &>> $LOG_FILE

VALIDATE $? "Installing Remi release "

dnf module enable redis:remi-6.2 -y &>> $LOG_FILE

VALIDATE $? "Enabling Redis "

dnf install redis -y &>> $LOG_FILE

VALIDATE $? "Installing redis "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG_FILE

VALIDATE $? "Allowing Remote connection "

systemctl enable redis &>> $LOG_FILE

VALIDATE $? "Enabling Redis "

systemctl start redis &>> $LOG_FILE

VALIDATE $? "Starting Redis "
