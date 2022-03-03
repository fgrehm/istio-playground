dc() {
  docker-compose -f docker-compose.yml "${@}"
}

kubectl() {
  docker exec -i istio-playground_tools_1 kubectl "${@}"
}

openssl() {
  dc exec tools openssl "${@}"
}

public-ca::step() {
  dc exec public-ca step  "${@}"
}

istioctl() {
  dc exec tools istioctl "${@}"
}
