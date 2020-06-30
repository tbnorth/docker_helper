# docker_helper

[docker_data.py](./docker_data.py) lists all the paths used by Docker on the
host.  Anonymous volumes, named volumes, and bind mounts.  Results are sorted
by path so you can see which parts of your host filesystem docker uses.
Dangling volumes, container running / stopped status, volume sharing, and
missing volumes (host directory deleted) are indicated by flags.

[docker.sh](./docker.sh) is a listing of useful docker shell commands.

