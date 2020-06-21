# list volumes for all containers
docker ps --format '{{.Names}}' \
  | xargs -IF bash -c "echo F; docker inspect -f '{{ .Mounts }}' F | sed 's/}/}\n/g'"
