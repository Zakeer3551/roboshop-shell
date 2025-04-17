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

dnf module disable mysql -y &>> $LOG_FILE

VALIDATE $? " Disabling mysql "

cp /home/centos/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG_FILE

VALIDATE $? " Copied MySQl repo "

dnf install mysql-community-server -y &>> $LOG_FILE

VALIDATE $? " Installing MYSQL server "

systemctl enable mysqld &>> $LOG_FILE

VALIDATE $? " Enabling MYSQL server "

systemctl start mysqld &>> $LOG_FILE

VALIDATE $? " Starting MYSQL server "

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE

VALIDATE $? "Setting  MySQL root password"
