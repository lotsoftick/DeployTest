#!/bin/bash
error='\033[0;36m'
success='\033[0;32m';
info='\033[0;34m'
reset='\033[0m'

PROJECT_NAME=$(grep PROJECT_NAME= .env |awk -F'[:=]+' '{ print $2 }')
HOSTNAME=$(grep HOSTNAME= .env |awk -F'[:=]+' '{ print $2 }')
HOST_IP=$(grep HOST_IP= .env |awk -F'[:=]+' '{ print $2 }')
PROJECT_NETWORK_NAME=$(echo "${PWD##*/}" | awk '{print tolower($0)}')"_default"

if [ -n "$(ifconfig lo0 | grep $HOST_IP)" ]
    then
        ip_last_digits=(`ifconfig lo0 | grep "inet " | awk -F'[: .]+' '{ print $5 }'`)
        max=${ip_last_digits[0]}
        for n in "${ip_last_digits[@]}" ; do
            ((n > max)) && max=$n
        done
        free_ip=127.0.0.$(($max+1))
        HOST_IP=$free_ip
        $(sed -i".bak" "/HOST_IP/d" .env)
        $(echo "HOST_IP="$HOST_IP >> .env)
        $(rm .env.bak)
        printf  $info"INFO:\t"$reset"The .env file was updated HOST_IP="$HOST_IP"\n"
fi

(sudo ifconfig lo0 alias $HOST_IP)
printf  $success"OK\t"$reset"The new ip "$HOST_IP" added to lo0\n"

function removehost() {
    if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
    then
        printf $info"INFO:\t"$reset$HOSTNAME" Found in your /etc/hosts, Removing now...\n"
        $(sudo sed -i".bak" "/$HOSTNAME/d" /etc/hosts)
    else
        printf $info"INFO:\t"$reset$HOSTNAME" was not found in your /etc/hosts\n"
    fi
}

function addhost() {
    HostLine="$HOST_IP\t$HOSTNAME"
    if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
        then
            printf $error"ERROR:\t"$reset$HOSTNAME" already exists : "$(grep $HOSTNAME /etc/hosts)"\n"
        else
            printf $success"OK\t"$reset"Adding "$HOSTNAME" to your /etc/hosts\n"
            $(sudo -- sh -c -e "echo '$HostLine' >> /etc/hosts") sudo -- sh -c -e "echo ups.local >> /etc/hosts"
            if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                then
                    printf $success"OK\t"$reset$HOST_IP"\t"$HOSTNAME" was added succesfully \n"
                else
                    printf $error"ERROR:\t"$reset"Failed to Add "$HOSTNAME", Try again!\n"
            fi
    fi
}

#remove host if exsist
(removehost)

#add new host
(addhost)

#removing  network from docker if exsist
if [ -n "$(docker network ls | grep $PROJECT_NETWORK_NAME)" ]
    then
        netres=$(docker network rm $PROJECT_NETWORK_NAME)
        printf "\t"$netres"\n"
        printf $success"OK\t"$reset$PROJECT_NETWORK_NAME" removed from docker network\n"
fi
