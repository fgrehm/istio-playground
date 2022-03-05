#!/usr/bin/env sh

set -eu -o pipefail

cat <<-DEFAULT > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
DEFAULT
