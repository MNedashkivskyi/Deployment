#!/bin/bash

while getopts "c:p:z:-:" OPT; do
    if [ "$OPT" = "-" ]; then
        OPT="${OPTARG%%=*}"
        OPTARG="${OPTARG#$OPT}"
        OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
        c | config )
            if ! [[ $OPTARG =~ ^[145]$ ]] ; then
                echo "Invalid configuration number: '$OPTARG'."
                exit
            fi
        	CONFIG=$OPTARG;;
        p | project )
        	PROJECT=$OPTARG;;
        z | zone )
        	ZONE=$OPTARG;;
        frontend )
        	FRONTEND=$OPTARG;;
        backend ) # For config 1
        	BACKEND=$OPTARG;;
        backend-port )
        	BACKEND_PORT=$OPTARG;;
        backend1 ) # For config 4 (master) & 5
        	BACKEND1=$OPTARG;;
        backend2 ) # For config 4 (slave) & 5
        	BACKEND2=$OPTARG;;
        backend1-port ) # For config 4 (master) & 5
        	BACKEND1_PORT=$OPTARG;;
        backend2-port ) # For config 4 (slave) & 5
        	BACKEND2_PORT=$OPTARG;;
        database ) # For config 1
        	DATABASE=$OPTARG;;
        master )
        	MASTER=$OPTARG;;
        slave )
        	SLAVE=$OPTARG;;
        * )
            echo "Invalid option '$OPTIND'"
        	exit;;
    esac
done
shift $((OPTIND-1))

echo ""
echo "============================================"
echo "Checking params ============================"
echo ""

if [ -z "$ZONE" ] ; then
    ZONE="europe-central2-a"
fi

if [ -z "$FRONTEND" ] ; then
    echo "Frontend VM name not set. Use --frontend to set."
    exit
fi

if [[ $CONFIG =~ ^[1]$ && -z "$BACKEND" ]] ; then
    echo "Backend VM name not set. For configuration 1 you must set it by --backend option."
    exit
fi

if [[ $CONFIG =~ ^[1]$ && -z "$BACKEND_PORT" ]] ; then
    BACKEND_PORT="9966"
fi

if [[ $CONFIG =~ ^[45]$ && -z "$BACKEND1_PORT" ]] ; then
    BACKEND1_PORT="9966"
fi

if [[ $CONFIG =~ ^[45]$ && -z "$BACKEND2_PORT" ]] ; then
    BACKEND2_PORT="9966"
fi

if [[ $CONFIG =~ ^[45]$ && -z "$BACKEND1" ]] ; then
    echo "Backend 1 VM name not set. For configuration 4 (master) & 5 you must set it by --backend1 option."
    exit
fi

if [[ $CONFIG =~ ^[45]$ && -z "$BACKEND1_PORT" ]] ; then
    echo "Backend 1 port not set. For configuration 4 (master) & 5 you must set it by --backend1-port option."
    exit
fi

if [[ $CONFIG =~ ^[45]$ && -z "$BACKEND2" ]] ; then
    echo "Backend 2 VM name not set. For configuration 4 (slave) & 5 you must set it by --backend1 option."
    exit
fi

if [[ $CONFIG =~ ^[45]$ && -z "$BACKEND2_PORT" ]] ; then
    echo "Backend 2 port not set. For configuration 4 (master) & 5 you must set it by --backend2-port option."
    exit
fi

if [[ $CONFIG =~ ^[1]$ ]] && [ -z "$DATABASE" ] ; then
    echo "Database VM name not set. For configuration 1 you must set it by --database option."
    exit
fi

if [[ $CONFIG =~ ^[45]$ && -z "$MASTER" ]] ; then
    echo "Master database VM name not set. For configuration 4 & 5 you must set it by --master option."
    exit
fi

if [[ $CONFIG =~ ^[45]$ && -z "$SLAVE" ]] ; then
    echo "Slave database VM name not set. For configuration 4 & 5 you must set it by --slave option."
    exit
fi

echo ""
echo "Params check done =========================="
echo "============================================"
echo ""

FRONTEND_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $FRONTEND --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

if [[ $CONFIG =~ ^[1]$ ]] ; then
    BACKEND_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $BACKEND --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    BACKEND_INTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $BACKEND --zone $ZONE --format='get(networkInterfaces[0].networkIP)')
    DB_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $DATABASE --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    DB_INTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $DATABASE --zone $ZONE --format='get(networkInterfaces[0].networkIP)')
    echo "[database]" > inventory
    echo $DB_EXTERNAL_IP >> inventory
    echo "[backend]" >> inventory
    echo $BACKEND_EXTERNAL_IP >> inventory
    echo "[frontend]" >> inventory
    echo $FRONTEND_EXTERNAL_IP >> inventory
    echo "[all:vars]" >> inventory
    echo "frontend_ip=$FRONTEND_EXTERNAL_IP" >> inventory
    echo "db_internal_ip=$DB_INTERNAL_IP" >> inventory
    echo "db_external_ip=$DB_EXTERNAL_IP" >> inventory
    echo "backend_port=$BACKEND_PORT" >> inventory
    echo "backend_ip=$BACKEND_EXTERNAL_IP" >> inventory

    ansible-playbook -i inventory config-1.yml 


elif [[ $CONFIG =~ ^[45]$ ]] ; then
    BACKEND1_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $BACKEND1 --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    BACKEND1_INTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $BACKEND1 --zone $ZONE --format='get(networkInterfaces[0].networkIP)')
    BACKEND2_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $BACKEND2 --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    BACKEND2_INTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $BACKEND2 --zone $ZONE --format='get(networkInterfaces[0].networkIP)')
    MASTER_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $MASTER --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    MASTER_INTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $MASTER --zone $ZONE --format='get(networkInterfaces[0].networkIP)')
    SLAVE_EXTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $SLAVE --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    SLAVE_INTERNAL_IP=$(gcloud compute instances --project $PROJECT describe $SLAVE --zone $ZONE --format='get(networkInterfaces[0].networkIP)')

    echo "[master]" > inventory
    echo $MASTER_EXTERNAL_IP >> inventory
    echo "[slave]" >> inventory
    echo $SLAVE_EXTERNAL_IP >> inventory
    echo "[backend1]" >> inventory
    echo $BACKEND1_EXTERNAL_IP >> inventory
    echo "[backend2]" >> inventory
    echo $BACKEND2_EXTERNAL_IP >> inventory
    echo "[frontend]" >> inventory
    echo $FRONTEND_EXTERNAL_IP >> inventory
    echo "[all:vars]" >> inventory
    echo "frontend_ip=$FRONTEND_EXTERNAL_IP" >> inventory
    echo "master_internal_ip=$MASTER_INTERNAL_IP" >> inventory
    echo "master_external_ip=$MASTER_EXTERNAL_IP" >> inventory
    echo "slave_internal_ip=$SLAVE_INTERNAL_IP" >> inventory
    echo "slave_external_ip=$SLAVE_EXTERNAL_IP" >> inventory
    echo "backend1_port=$BACKEND1_PORT" >> inventory
    echo "backend1_ip=$BACKEND1_EXTERNAL_IP" >> inventory
    echo "backend2_port=$BACKEND2_PORT" >> inventory
    echo "backend2_ip=$BACKEND2_EXTERNAL_IP" >> inventory
fi

if [[ $CONFIG =~ ^[4]$ ]] ; then
    ansible-playbook -i inventory config-4.yml
fi

if [[ $CONFIG =~ ^[5]$ ]] ; then
    ansible-playbook -i inventory config-5.yml
fi
