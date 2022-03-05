k8s::wait() {
  sleep_s="${1}"
  shift

  until tools::kubectl wait "${@}"; do sleep "${sleep_s}"; done | ensure_indent
}
