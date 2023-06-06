#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "Select * from services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
   echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    HAVE_SERVICE=$($PSQL "Select service_id from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $HAVE_SERVICE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      CUSTOMER
    fi
  fi

}

CUSTOMER(){

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "Insert into customers(name,phone) Values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    APPOINTMENT
  else
    APPOINTMENT
  fi
}

APPOINTMENT(){
  NAME=$($PSQL "Select name from customers where customer_id=$CUSTOMER_ID")
  SERVICE=$($PSQL "Select name from services where service_id=$SERVICE_ID_SELECTED")

  FORMATED_NAME=$(echo $NAME | sed 's/ |/"/')
  FORMATED_SERVICE=$(echo $SERVICE | sed 's/ |/"/')

  echo -e "\nWhat time would you like your $FORMATED_SERVICE, $FORMATED_NAME?"
  read SERVICE_TIME

  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  APPOINTMENT_RESULT=$($PSQL "Insert into appointments(customer_id,service_id,time) Values($CUST_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  echo -e "\nI have put you down for a $FORMATED_SERVICE at $SERVICE_TIME, $FORMATED_NAME."

}
  

MAIN_MENU
