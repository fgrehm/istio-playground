istio::create-ns() {
  ns="${1}"
  if ! kubectl get ns -o name | grep -q "namespace/${ns}"; then
    kubectl create ns "${ns}" | ensure_indent
  fi
  istio::label-ns "${ns}"
}

istio::label-ns() {
  ns="${1}"
  kubectl label namespace "${ns}" istio-injection=enabled --overwrite &>/dev/null
}
