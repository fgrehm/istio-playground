dc() {
  docker-compose -f docker-compose.yml "${@}"
}

kubectl() {
  dc exec -T tools kubectl "${@}"
}

openssl() {
  dc exec -T tools openssl "${@}"
}

istioctl() {
  dc exec -T tools istioctl "${@}"
}
