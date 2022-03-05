bootstrap::public-ca() {
  echo_title 'Configuring "public" CA'
  mkdir -p ./tmp/public-ca
  dc up -d public-ca tools 2>&1 | ensure_indent
}

bootstrap::public-lb() {
  echo_title 'Configuring "public" LB'
  mkdir -p ./tmp/public-lb/nginx-conf.d
  dc up -d public-lb tools 2>&1 | ensure_indent
}

bootstrap::configure-registry() {
  echo_title "Configuring registry proxy"

  mkdir -p /tmp/istio-playground/registry-proxy-{ca,cache}
  dc up -d registry-proxy 2>&1 | ensure_indent

  ca_key_path="/tmp/istio-playground/registry-proxy-ca/ca.key"
  echo_normal "Waiting for proxy CA cert at ${ca_key_path}"
  until [[ -f "${ca_key_path}" ]]; do echo -n '.' sleep 1; done
}

bootstrap::cluster() {
  if [[ "${SKIP_CLUSTER_BOOTSTRAP:-no}" != "no" ]]; then
    echo_title "Skipping cluster bootstrap"
    return
  fi

  bootstrap::configure-registry

  echo_title "Configuring k3s cluster"
  dc up -d server agent tools 2>&1 | ensure_indent
  k8s::wait 1 --for=condition=ready node -l "node-role.kubernetes.io/master=true"
  k8s::wait 1 --for=condition=ready node -l "!node-role.kubernetes.io/master"
  k8s::wait 1 --for=condition=available deployment/coredns -n kube-system
  k8s::wait 1 --for=condition=available deployment/metrics-server -n kube-system

  echo_title "Configuring istio"
  tools::istioctl install -y --set values.global.proxy.logLevel=debug \
                          --set meshConfig.accessLogFile=/dev/stdout \
                          2>&1 \
    | ensure_indent

  tools::istioctl analyze -n istio-system 2>&1 | ensure_indent
  kubectl apply -f manifests/istio.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/prometheus.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/jaeger.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/kiali.yaml | ensure_indent
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/grafana.yaml | ensure_indent
  istio::label-ns "default"
  echo
}
