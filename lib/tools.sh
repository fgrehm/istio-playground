tools::kubectl() {
  exec::tools kubectl "${@}"
}

tools::jq() {
  exec::tools jq "${@}"
}

tools::openssl() {
  exec::tools openssl "${@}"
}

tools::istioctl() {
  exec::tools istioctl "${@}"
}
