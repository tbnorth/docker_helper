# compact docker ps
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"

# remove non-running containers
docker rm $(docker ps -a -q)

# stop all containers
docker stop $(docker ps -a -q)

# command to get paths for named volumes
dv () {
  docker volume inspect $1 | jq -r '.[] | .Mountpoint'
}

# list volumes for all containers
docker ps --format '{{.Names}}' \
  | xargs -IF bash -c "echo F; docker inspect -f '{{ .Mounts }}' F | sed 's/}/}\n/g'"

# show runtime settings
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock assaflavie/runlike \
  CONTAINER_NAME | sed 's/ --/\n  --/g'