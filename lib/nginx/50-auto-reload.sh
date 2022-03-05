#!/usr/bin/env sh

set -eu -o pipefail

cat <<-RELOADER > /bin/nginx-reloader
#!/usr/bin/env sh
echo "Reloading NGINX" 1>&2
nginx -s reload
RELOADER
chmod +x /bin/nginx-reloader

echo "Spawning reloader for nginx configs" 1>&2
inotifyd /bin/nginx-reloader /etc/nginx/conf.d:wdymDM &

  # https://medium.com/@mvuksano/using-tls-certificates-with-nginx-docker-container-74c6769a26db
  # mount certificates
  # inject header
