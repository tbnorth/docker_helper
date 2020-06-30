# docker_helper

[docker_data.py](./docker_data.py) lists all the paths used by Docker on the
host.  Anonymous volumes, named volumes, and bind mounts.  Results are sorted
by path so you can see which parts of your host filesystem docker uses.
Dangling volumes, container running / stopped status, volume sharing, and
missing volumes (host directory deleted) are indicated by flags.

```
Usage:
    sudo python3 docker_data.py [--container] [--color]
    --container: sort by container name instead of volume path
    --color: highlight volume names / container names
```
Example output:
```
  B:bind R:running D:dangling S:shared !:deleted
1 __D__ /var/lib/docker/volumes/219c6de*/_data as 219c6de*
2 _____ /var/lib/docker/volumes/28551f3*/_data as 28551f3* in mp_mapserver_1
3 ___S_ /var/lib/docker/volumes/mp_rwitmp/_data as mp_rwitmp in mp_mapserver_1
4 ___S_ /var/lib/docker/volumes/mp_rwitmp/_data as mp_rwitmp in mp_mezserver_1
5 _R___ /var/lib/docker/volumes/nrrickan_pg_data/_data as nrrickan_pg_data in nrrickan_db
6 BR___ /mnt/data in docker_apache_1
7 B__S_ /mnt/storage/usr1_scratch/tbrown/rwi.content/drive/otter in mp_mapserver_1
8 B__S_ /mnt/storage/usr1_scratch/tbrown/rwi.content/drive/otter in mp_mezserver_1
```
(1) a dangling anonymous volume, (2) an anonymous volume referenced by a
non-running container, (3,4) a named volume *S*hared by two (non-running)
containers, (5) a named volume used by a running container, (6) a bind mount
used by a running container, (7,8) a bind mount *S*hared by two (non-running)
containers.

On systems without Python 3.6+, you can run  `docker_data.py` with:
```shell
sudo docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    tbnorth/docker_data
```
Deleted volumes won't be reported, because the container can't see the host
file system.

---

[docker.sh](./docker.sh) is a listing of useful docker shell commands.

<!-- |documentation -->
<!-- Please see https://github.com/tbnorth/pymd_helper for instructions on
     updating this projects markdown files.  `pymd_helper` is used to
     insert/update files into markdown documentation, generate tables
     of contents, etc.
-->

<!-- |insert,src=docker.sh,syntax=shell,addpath -->
<div class='addpath'>(<a href="docker.sh"><i>docker.sh</i></a>)</div>

```shell
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
  CONTAINER_NAME | sed 's/ --/\n  --/g'```

