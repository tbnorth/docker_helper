# compact docker ps
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"

# list volumes for all containers
docker ps --format '{{.Names}}' \
  | xargs -IF bash -c "echo F; docker inspect -f '{{ .Mounts }}' F | sed 's/}/}\n/g'"

# show runtime settings
sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock assaflavie/runlike \
  CONTAINER_NAME | sed 's/ --/\n  --/g'