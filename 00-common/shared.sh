dc() { docker-compose -f docker-compose.yml -f docker-compose-clis.yml "${@}"; }
dccr() { dc run --rm "${@}"; }
kubectl() { dccr "kubectl" "${@}"; }
istioctl() { dccr "istioctl" "${@}"; }
openssl() { dccr "openssl" "${@}"; }

configure-cluster() {
  echo '### Setup k3s'
  dc up -d --scale k3s-server-A=1 --scale k3s-agent-A=3
  sleep 5
  until kubectl wait --for=condition=ready node --all; do sleep 1; done 2>/dev/null
  until kubectl wait --for=condition=available deployment/coredns -n kube-system; do sleep 1; done 2>/dev/null
  until kubectl wait --for=condition=available deployment/metrics-server -n kube-system; do sleep 1; done 2>/dev/null
  echo

  echo "### Setup istio"
  kubectl apply -f 00-common/istio.yaml
  until kubectl wait --for=condition=complete job/helm-install-istio-base -n istio-system; do sleep 1; done 2>/dev/null
  until kubectl wait --for=condition=complete job/helm-install-istiod -n istio-system; do sleep 1; done 2>/dev/null
  kubectl wait --for=condition=available deploy/istiod -n istio-system

  kubectl apply -f 00-common/istio-gateway.yaml
  until kubectl wait --for=condition=complete job/helm-install-istio-ingressgateway -n istio-system; do sleep 1; done 2>/dev/null
  kubectl wait --for=condition=available deploy/istio-ingressgateway -n istio-system
  kubectl apply -n istio-system -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: "default"
spec:
  mtls:
    mode: STRICT
EOF
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/prometheus.yaml
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/jaeger.yaml
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/kiali.yaml
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/grafana.yaml
  echo
}

fetch-gateway-url() {
  if [[ -z "${gateway_url_cache:-}" ]]; then
    gateway_url_cache="http://$(fetch-ingress-host):$(fetch-ingress-port)"
    export gateway_url_cache
  fi
  echo -n "${gateway_url_cache}"
}


fetch-secure-gateway-url() {
  if [[ -z "${secure_gateway_url_cache:-}" ]]; then
    secure_gateway_url_cache="http://$(fetch-ingress-host):$(fetch-secure-ingress-port)"
    export secure_gateway_url_cache
  fi
  echo -n "${secure_gateway_url_cache}"
}

fetch-ingress-host() {
  if [[ -z "${ingress_host_cache:-}" ]]; then
    ingress_host_cache="$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}' 2>/dev/null).nip.io"
    export ingress_host_cache
  fi
  echo -n "${ingress_host_cache}"
}

fetch-secure-ingress-port() {
  if [[ -z "${secure_ingress_port_cache:-}" ]]; then
    secure_ingress_port_cache="$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}' 2>/dev/null)"
    export secure_ingress_port_cache
  fi
  echo -n "${secure_ingress_port_cache}"
}

fetch-ingress-port() {
  if [[ -z "${ingress_port_cache:-}" ]]; then
    ingress_port_cache="$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}' 2>/dev/null)"
    export ingress_port_cache
  fi
  echo -n "${ingress_port_cache}"
}
