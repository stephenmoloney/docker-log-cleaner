#!/usr/bin/env bash

get_container_name(){
  id=$1;
  name=$(docker inspect $id | grep Name | tr -d " " | head -1 | cut -c10-1000 | rev | cut -c3-1000 | rev) && \
  echo $name;
}

get_container_id(){
  name=$1;
  id=$(docker inspect $name | grep Id | tr -d " " | cut -c7-70) && \
  echo $id;
}

get_container_ids() {
  CONTAINER_IDS=() && \
  if [ "${CONTAINERS_T0_CLEAN}" == "ALL" ]; then
    CONTAINERS_T0_CLEAN=$(docker ps -a -q | tr '\n' ' ') && \
    for container in ${CONTAINERS_T0_CLEAN}; do
      CONTAINER_IDS+=("$(get_container_id $container)")
    done
  else
    for container in "${CONTAINERS_T0_CLEAN}"; do
      CONTAINER_IDS+=("$(get_container_id $container)")
    done
  fi && \
  CONTAINER_IDS=$(remove_self "${CONTAINER_IDS[@]}") && \
  echo "${CONTAINER_IDS[@]}";
}

remove_self(){
  self_id=$(get_container_id ${SELF_NAME}) && \
  CONTAINER_IDS=$1 && \
  CONTAINER_IDS_WITHOUT_SELF=() && \
  for id in "${CONTAINER_IDS}"; do
    if [ "$self_id" != "$id" ]; then
      CONTAINER_IDS_WITHOUT_SELF+=("$id")
    fi
  done && \
  if [ "$INCLUDE_SELF" == "TRUE" ]; then
    echo "${CONTAINER_IDS[@]}";
  else
    echo "${CONTAINER_IDS_WITHOUT_SELF[@]}";
  fi
}

ensure_clean_s6_dir(){
  if [ -d /etc/s6/ ]; then
    rm -R /etc/s6/
  fi
}

create_s6svscan_folder(){
  if [ ! -d /etc/s6/.s6-svscan/finish ]; then
    echo "Creating file /etc/s6/.s6-svscan/finish ..." && \
    mkdir -p /etc/s6/.s6-svscan/ && touch /etc/s6/.s6-svscan/finish && chmod +x /etc/s6/.s6-svscan/finish && \
    cat > /etc/s6/.s6-svscan/finish << EOF
#!/bin/bash
/bin/true
EOF
  fi
}

prepare_s6_dir() {
  id=$1;
  name=$(get_container_name $id);

  if [ ! -e /etc/s6/${name}_cleaner/finish ]; then
    echo "Creating file /etc/s6/${name}_cleaner/finish ..." && \
    mkdir -p /etc/s6/${name}_cleaner/ && touch /etc/s6/${name}_cleaner/finish && chmod +x /etc/s6/${name}_cleaner/finish
  fi
  if [ ! -e /etc/s6/${name}_cleaner/run ]; then
    echo "Creating file /etc/s6/${name}_cleaner/run ..." && \
    mkdir -p /etc/s6/${name}_cleaner/ && touch /etc/s6/${name}_cleaner/run && chmod +x /etc/s6/${name}_cleaner/run
  fi
}

create_s6_service(){
  id=$1;
  name=$(get_container_name $id);

  cat > /etc/s6/${name}_cleaner/finish << EOF
#!/bin/bash
s6-svscanctl -r /etc/s6
EOF

  cat > /etc/s6/${name}_cleaner/run << EOF
#!/bin/bash
echo "clearing the logs from the $name container and the /var/lib/docker/containers/${id}/${id}-json.log file at \$(date +"%d-%m-%Y %H:%M:%S")..." && \
printf '' > /var/lib/docker/containers/${id}/${id}-json.log && \
sleep ${CLEAN_FREQUENCY}s
EOF
}

start(){
  # Give the containers a chance to start before initiating process, hence `sleep 5s`
  sleep 5s && \
  IDS=$(get_container_ids) && \
  ensure_clean_s6_dir && \
  for id in ${IDS}; do
    create_s6svscan_folder && \
    prepare_s6_dir $id && \
    create_s6_service $id;
  done && \
  tree -aL 2 /etc/s6/ && \
  exec s6-svscan /etc/s6/
}

start

