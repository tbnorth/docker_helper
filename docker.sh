# compact docker ps
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"

# remove non-running containers
docker rm $(docker ps -a -q -f status=exited -f status=dead)

# stop all containers
docker stop $(docker ps -a -q)

# command to get paths for named volumes, with no parameter it lists
# named volumes, with a volume name it lists the host path, so
#   cp setup.dat $(dv myapp_data)/tmp/
# for example would copy setup.dat into the volume 'myapp_data'
dv () {
  if [ "$1" ]; then
    docker volume inspect $1 | jq -r '.[] | .Mountpoint'
  else
    docker volume ls | grep '\s\w\{,60\}$'
    D=$(docker volume ls | grep '\s\w\{64\}$' | wc -l)
    echo "$D anonymous volumes omitted"
    D=$(docker volume ls -q -f dangling=true | wc -l)
    echo "docker volume ls -f dangling=true lists $D volumes"
  fi
}

# list volumes for all containers
docker ps --format '{{.Names}}' \
  | xargs -IF bash -c "echo F; docker inspect -f '{{ .Mounts }}' F | sed 's/}/}\n/g'"

# show runtime settings
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock assaflavie/runlike \
  CONTAINER_NAME | sed 's/ --/\n  --/g'