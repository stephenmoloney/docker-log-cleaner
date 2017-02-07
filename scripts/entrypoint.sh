#!/usr/bin/env bash

source /scripts/functions;

start(){
  sleep 3s;

  IDS="$(get_container_ids)" && \
  if [ "$INCLUDE_SELF" == "TRUE" ]; then
    IDS=$(add_self "${IDS[@]}");
  else
    IDS=$(remove_self "${IDS[@]}");
  fi;

  ensure_clean_s6_dir && create_s6svscan_folder;

  for id in ${IDS}; do
    create_s6_service $id;
  done;

  create_s6_watch_service && \
  tree -aL 2 /etc/s6/ && \
  exec s6-svscan /etc/s6/
}

start