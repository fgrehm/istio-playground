apps::deploy-bookinfo() {
  ns="${1}"

  echo_title "Deploying bookinfo to ${ns}"
  istio::create-ns "${ns}"
  tools::kubectl apply -n "${ns}" -f manifests/bookinfo.yaml | ensure_indent
  k8s::wait 1 --for=condition=available deployments --all -n "${ns}"
}

apps::deploy-httpbin() {
  ns="${1}"

  echo_title "Deploying httpbin to ${ns}"
  istio::create-ns "${ns}"
  tools::kubectl apply -n "${ns}" -f manifests/httpbin.yaml | ensure_indent
  k8s::wait 1 --for=condition=available deployments --all -n "${ns}"
}
