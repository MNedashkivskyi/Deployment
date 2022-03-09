#!/bin/bash

CONFIG=""
PROJECT_ID=""

function ctrl_c() {
    printf '\n'
    echo "Stoppping instances"
    gcloud compute instances stop "${INSTANCES_BACKEND[@]}" --zone=$ZONE
    if [[ -n $INSTANCES_OTHER ]] ; then
        gcloud compute instances stop "${INSTANCES_OTHER[@]}" --zone=$ZONE
    fi
    echo "done"
    exit ;
}

FRONTEND="wus-lab1-frontend"
BACKEND="wus-lab1-backend"
BACKEND_PORT="9966"
BACKEND1="wus-lab1-backend1"
BACKEND1_PORT="9966"
BACKEND2="wus-lab1-backend2"
BACKEND2_PORT="9966"
DATABASE="wus-lab1-database"
MASTER="wus-lab1-master"
SLAVE="wus-lab1-slave"
NGINX="wus-lab1-nginx"

ZONE="europe-central2-a"

TEMPLATE_BACKEND="wus-lab1-backend-2021"
TEMPLATE_OTHER="wus-lab1-other-2021"

trap ctrl_c INT

gcloud compute instance-templates create $TEMPLATE_BACKEND --machine-type=e2-highcpu-4 --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud --boot-disk-size=20GB --boot-disk-auto-delete --boot-disk-device-name=wus-lab1-backend --boot-disk-type=pd-balanced --tags=http-server,https-server --scopes=cloud-platform --reservation-affinity=any --shielded-vtpm --shielded-integrity-monitoring --verbosity=critical

gcloud compute instance-templates create $TEMPLATE_OTHER --machine-type=e2-medium --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud --boot-disk-size=20GB --boot-disk-auto-delete --boot-disk-device-name=wus-lab1-backend --boot-disk-type=pd-balanced --tags=http-server,https-server --scopes=cloud-platform --reservation-affinity=any --shielded-vtpm --shielded-integrity-monitoring --verbosity=critical

if [[ "$CONFIG" == "1" ]] ; then
    declare -a INSTANCES_BACKEND=("$BACKEND")
    if [[ "$FRONTEND" != "$BACKEND" && "$DATABASE" != "$BACKEND" ]] ; then
        declare -a INSTANCES_OTHER=("$FRONTEND" "$DATABASE")
    elif [[ "$FRONTEND" != "$BACKEND" ]] ; then
        declare -a INSTANCES_OTHER=("$FRONTEND")
    elif [[ "$DATABASE" != "$BACKEND" ]] ; then
        declare -a INSTANCES_OTHER=("$DATABASE")
    fi
else
    declare -a INSTANCES_BACKEND=("$BACKEND1" "$BACKEND2")
    declare -a INSTANCES_OTHER=("$FRONTEND" "$MASTER" "$SLAVE" "$NGINX")
fi

echo "Deleting old instances.."
sleep 5
for INSTANCE in "${INSTANCES_BACKEND[@]}"
do
    gcloud compute instances delete $INSTANCE --zone=$ZONE --delete-disks=all -q --verbosity=critical
done

for INSTANCE in "${INSTANCES_OTHER[@]}"
do
    gcloud compute instances delete $INSTANCE --zone=$ZONE --delete-disks=all -q --verbosity=critical
done
echo "done"

echo "Creating new instances.."
sleep 5
gcloud compute instances create "${INSTANCES_BACKEND[@]}" --source-instance-template $TEMPLATE_BACKEND
if [[ -n $INSTANCES_OTHER ]] ; then
    gcloud compute instances create "${INSTANCES_OTHER[@]}" --source-instance-template $TEMPLATE_OTHER
fi
sleep 60
gcloud compute config-ssh --remove
gcloud compute config-ssh

echo "Running script"
sleep 5
if [[ "$CONFIG" == "1" ]] ; then
    ./script.sh --config=$CONFIG --project=$PROJECT_ID --frontend=$FRONTEND --backend=$BACKEND --backend-port=$BACKEND_PORT --database=$DATABASE | tee log.out
else
    ./script.sh --config=$CONFIG --project=$PROJECT_ID --frontend=$FRONTEND --backend1=$BACKEND1 --backend1-port=$BACKEND1_PORT --backend2=$BACKEND2 --backend2-port=$BACKEND2_PORT --nginx=$NGINX --master=$MASTER --slave=$SLAVE | tee log.out
fi
echo "done"

FRONTEND_EXTERNAL_IP=$(gcloud compute instances describe $FRONTEND --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "Access frontend: http://$FRONTEND_EXTERNAL_IP/petclinic"


TTL=1200 # 20 minutes
for ((i=0; i<TTL; i++)); do timeleft=$(($TTL-$i)) && echo -en "\r$timeleft s \t";sleep 1;done;
ctrl_c
