echo_title() {
  echo $'\e[1G----->' "$@"
}

echo_normal() {
  echo $'\e[1G      ' "$@"
}

ensure_indent() {
  while read -r line; do
    if [[ "${line}" == --* ]]; then
      echo $'\e[1G'"${line}"
    else
      echo $'\e[1G      ' "${line}"
    fi
  done
}

log_debug() {
  if [[ "${LOG_LEVEL}" = "debug" ]]; then
    echo_normal "$@" >&2
  fi
}

log_warn() {
  echo_normal "$@" >&2
}

fail() {
  echo_normal "$@" >&2
  exit 1
}

istio::create-ns() {
  ns="${1}"
  if ! kubectl get ns -o name | grep -q "namespace/${ns}"; then
    kubectl create ns "${ns}" | ensure_indent
  fi
  kubectl label namespace "${ns}" istio-injection=enabled --overwrite &>/dev/null
}

kctl::wait() {
  sleep_s="${1}"
  shift

  until kubectl wait "${@}"; do sleep "${sleep_s}"; done | ensure_indent
}
