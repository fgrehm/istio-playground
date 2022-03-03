bootstrap::cluster() {
  if [[ "${SKIP_BOOTSTRAP:-no}" != "no" ]]; then
    echo_title "Skipping cluster bootstrap"
    return
  fi

  mkdir -p /tmp/istio-playground/registry-proxy-{ca,cache}
  bootstrap::configure-registry
  bootstrap::configure-cluster
  bootstrap::configure-istio
}

bootstrap::configure-cluster() {
  echo_title "Configuring k3s cluster"
  dc up -d server agent tools 2>&1 | ensure_indent

  kctl::wait 1 --for=condition=ready node -l "node-role.kubernetes.io/master=true"
  kctl::wait 1 --for=condition=ready node -l "!node-role.kubernetes.io/master"
  kctl::wait 1 --for=condition=available deployment/coredns -n kube-system
  kctl::wait 1 --for=condition=available deployment/metrics-server -n kube-system
}

bootstrap::configure-istio() {
  echo_title "Configuring istio"
  istioctl install -y
  istioctl analyze -n istio-system

  kubectl apply -f manifests/istio.yaml
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/prometheus.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/jaeger.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/kiali.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/grafana.yaml | ensure_indent
  echo
}

bootstrap::configure-registry() {
  echo_title "Configuring registry proxy"
  dc up -d registry-proxy 2>&1 | ensure_indent

  ca_key_path="/tmp/istio-playground/registry-proxy-ca/ca.key"
  echo_normal "Waiting for proxy CA cert at ${ca_key_path}"
  until [[ -f "${ca_key_path}" ]]; do echo -n '.' sleep 1; done
}
