# https://gist.githubusercontent.com/tbnorth/fbe6b109aba0c90c0b2d18a6cedb4014/raw/all_docker_data.py
import json
import os
import re
import subprocess


def text_from_cmd(cmd):
    if not isinstance(cmd, list):
        cmd = cmd.split()
    cmd = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    out, _ = cmd.communicate()
    return out.decode('utf8')


def short_anon(text):
    return re.sub("([a-z0-9]{7})[a-z0-9]{57}", r"\1", text)


containers = text_from_cmd("docker ps -a --format {{.Names}}").split()
running = text_from_cmd("docker ps --format {{.Names}}").split()
dangling = text_from_cmd("docker volume ls -q -f dangling=true").split()
mounts = {}
mounts = {
    container: json.loads(
        text_from_cmd(
            [
                "docker",
                "inspect",
                "--type",
                "container",
                "-f",
                "{{json .Mounts }}",
                container,
            ]
        )
    )
    for container in containers
}
volumes = []
seen = set()
for container, mounted in mounts.items():
    for mount in mounted:
        mount['Container'] = container
        mount['Running'] = container in running
        mount['Dangling'] = False
        mount['Shared'] = mount['Source'] in seen
        try:
            os.stat(mount['Source'])
            mount['Lost'] = False
        except FileNotFoundError:
            mount['Lost'] = True
        seen.add(mount['Source'])
        volumes.append(mount)

for volume in dangling:
    inspect = json.loads(text_from_cmd(f"docker volume inspect {volume}"))[0]
    inspect['Source'] = inspect['Mountpoint']
    assert inspect['Source'] not in seen
    inspect['Container'] = None
    inspect['Running'] = False
    inspect['Dangling'] = True
    try:
        os.stat(inspect['Source'])
        inspect['Lost'] = False
    except FileNotFoundError:
        inspect['Lost'] = True
    volumes.append(inspect)


for volume in sorted(volumes, key=lambda x: x['Source']):
    print(
        "{running}{dangling}{shared}{lost} {source} {name}{container}".format(
            running='R' if volume['Running'] else ' ',
            dangling='D' if volume['Dangling'] else ' ',
            lost='!' if volume['Lost'] else ' ',
            shared='S' if volume['Shared'] else ' ',
            source=short_anon(volume['Source']),
            name=short_anon(f"as {volume['Name']} ")
            if volume.get('Name')
            else '',
            container=f"in {volume['Container']}"
            if volume.get('Container')
            else '',
        )
    )