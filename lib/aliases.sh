dc() {
  docker-compose -f docker-compose.yml "${@}"
}

kubectl() {
  docker exec -i istio-playground_tools_1 kubectl "${@}"
}

openssl() {
  dc exec tools openssl "${@}"
}

istioctl() {
  dc exec tools istioctl "${@}"
}
