#!/usr/bin/env bash

UUID=${UUID:-'43d1d906-f6cf-4e90-8b10-cdcab1df0826'}
VMESS_WSPATH=${VMESS_WSPATH:-'/NtOWapcpcnQ'}
VLESS_WSPATH=${VLESS_WSPATH:-'/KTOqvqCe'}
TROJAN_WSPATH=${TROJAN_WSPATH:-'/q6j8IgM'}
SS_WSPATH=${SS_WSPATH:-'/COvqp'}


# edit config
echo edit config
sed -i "s#UUID#$UUID#g;s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g;s#TROJAN_WSPATH#${TROJAN_WSPATH}#g;s#SS_WSPATH#${SS_WSPATH}#g" config.json
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g;s#TROJAN_WSPATH#${TROJAN_WSPATH}#g;s#SS_WSPATH#${SS_WSPATH}#g" /etc/nginx/nginx.conf
sed -i "s#RELEASE_RANDOMNESS#${RELEASE_RANDOMNESS}#g" /etc/supervisor/conf.d/supervisord.conf

# create nginx website
echo create nginx website
rm -rf /usr/share/nginx/*
site_link_b64="aHR0cHM6Ly9naXRsYWIuY29tL01pc2FrYS1ibG9nL3hyYXktcGFhcy8tL3Jhdy9tYWluL21pa3V0YXAuemlwCg=="
site_link=$(echo ${site_link_b64} | base64 -d)
wget ${site_link} -O /usr/share/nginx/mikutap.zip && echo "site download finished"
unzip -o "/usr/share/nginx/mikutap.zip" -d /usr/share/nginx/html
rm -f /usr/share/nginx/mikutap.zip

# create service
echo create service
service_link_b64='aHR0cHM6Ly9naXRodWIuY29tL1hUTFMvWHJheS1jb3JlL3JlbGVhc2VzL2xhdGVzdC9kb3dubG9hZC9YcmF5LWxpbnV4LTY0LnppcAo='
service_link=$(echo ${service_link_b64} | base64 -d)
wget -O ./app.zip ${service_link} &> /dev/null && echo "service download finished"
SERVICE=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
unzip ./app.zip $(echo eHJheQo= | base64 -d) >/dev/null
rm -f ./app.zip
mv $(echo eHJheQo= | base64 -d) ${SERVICE}
chmod -v 755 ${SERVICE}

# get resources
echo get resources
repo_name_b64="TG95YWxzb2xkaWVyL3YycmF5LXJ1bGVzLWRhdAo="
repo_name=$(echo ${repo_name_b64} | base64 -d)
wget https://github.com/${repo_name}/releases/latest/download/geoip.dat &> /dev/null
wget https://github.com/${repo_name}/releases/latest/download/geosite.dat &> /dev/null
cat config.json | base64 > config
rm -f config.json

# create index.html
# index.pth is index.html
echo create index.html
base64 -d index.pth > index.html && rm index.pth
sed -i "s#\$UUID#$UUID#g;s#\$VMESS_WSPATH#$VMESS_WSPATH#g;s#\$VLESS_WSPATH#$VLESS_WSPATH#g;s#\$TROJAN_WSPATH#$TROJAN_WSPATH#g;s#\$SS_WSPATH#$SS_WSPATH#g" index.html
mv index.html /usr/share/nginx/html/$UUID.html

# start service
echo start service
nginx

base64 -d config > config.json
./${SERVICE} -config=config.json &>/dev/null
