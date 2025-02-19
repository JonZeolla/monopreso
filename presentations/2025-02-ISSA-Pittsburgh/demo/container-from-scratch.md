## Getting Started

```bash
echo $SHLVL
bash
echo $SHLVL
sh
echo $SHLVL
sh
echo $SHLVL
exit
exit
exit
echo $SHLVL
```

## Capabilities

```bash
man 7 capabilities
# File capabilities
getcap $(which ping)
cp $(which ping) ./
getcap -v ping
# Process capabilities
getpcaps 0
getpcaps $$
sudo bash
getpcaps $$ # full Effective (e) and Permitted (p) capabilities
```

## cgroups v1

```bash
cat /proc/$$/cgroup
grep memory /proc/$$/cgroup
cat /sys/fs/cgroup/memory/$(grep memory /proc/$$/cgroup | awk -F\: '{print $NF}')/memory.limit_in_bytes
# limit_in_bytes in GB
expr $(!!) / 1024 / 1024 / 1024
# Dump cgroups "before" docker
lscgroup > ~/before
# Run something docker
docker run alpine ls > /dev/null
# Look into docker cgroups
ls /sys/fs/cgroup/*/docker | grep docker
# Dump cgroups "after" docker
lscgroup > ~/after
# Compare before/after
diff ~/before ~/after
```

## cgroups v2

```bash
awk -F\: '{print $NF}' < /proc/$$/cgroup
cat /sys/fs/cgroup/user.slice/user-1000.slice/session-*.scope/memory.max # This is the cgroup max memory limit for the current UID 1000 session
lscgroup | grep docker
cat /sys/fs/cgroup/system.slice/docker.service/memory.max
```

## Namespaces

### UTS: Unix Timesharing System

```bash
man 1 unshare
# Listing namespaces
lsns # Run this as non-root
sudo bash
lsns
# Hostname
unshare --uts bash
echo $SHLVL
hostname
hostname new
hostname
exit
hostname
```

### PID namespaces

```bash
# Cannot run any commands; commands run after this try to spawn a process in the original namespace
unshare --pid bash # exit after
# Can run exactly one command
unshare --pid sh # exit after
# Run a new PID namespace that works as expected.  Forks the specified program as a child process of unshare rather than running it directly.
unshare --pid --fork sh
echo $$ # PID 1!
ps # Wait, what?
exit
```

## Container from scratch

```bash
# Root FS
chroot empty
chroot empty ls
echo $SHLVL
mkdir alpine
curl -o alpine/alpine.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-minirootfs-3.21.0-x86_64.tar.gz
pushd alpine
tar xvf alpine.tar.gz
rm alpine.tar.gz
popd
ls /bin/ash # Nothing up my sleeve
chroot alpine /bin/ash # exit after
chroot alpine ls /
# Multiple Namespaces
unshare --uts --pid --fork chroot alpine /bin/ash
echo $$
ps
ls /proc/ # We might need that
mount -t proc proc proc
ps # Success!
# Mount
unshare --mount chroot alpine ash
mount -t proc proc proc
hostname
hostname new
hostname
mount
exit
findmnt # Same info as mount, different format
```
