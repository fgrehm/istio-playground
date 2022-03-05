ingress::fetch-gateway-url() {
  if [[ -z "${gateway_url_cache:-}" ]]; then
    gateway_url_cache="http://$(ingress::fetch-host):$(ingress::fetch-port)"
    export gateway_url_cache
  fi
  echo -n "${gateway_url_cache}"
}

ingress::fetch-secure-gateway-url() {
  if [[ -z "${secure_gateway_url_cache:-}" ]]; then
    secure_gateway_url_cache="https://$(ingress::fetch-host):$(ingress::fetch-secure-port)"
    export secure_gateway_url_cache
  fi
  echo -n "${secure_gateway_url_cache}"
}

ingress::fetch-host() {
  if [[ -z "${ingress_host_cache:-}" ]]; then
    ingress_host_cache="$(tools::kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null 2>/dev/null).nip.io"
    export ingress_host_cache
  fi
  echo -n "${ingress_host_cache}"
}

ingress::fetch-port() {
  if [[ -z "${ingress_port_cache:-}" ]]; then
    ingress_port_cache="$(tools::kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}' 2>/dev/null)"
    export ingress_port_cache
  fi
  echo -n "${ingress_port_cache}"
}

ingress::fetch-secure-port() {
  if [[ -z "${secure_ingress_port_cache:-}" ]]; then
    secure_ingress_port_cache="$(tools::kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}' 2>/dev/null)"
    export secure_ingress_port_cache
  fi
  echo -n "${secure_ingress_port_cache}"
}
