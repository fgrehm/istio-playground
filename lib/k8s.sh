kctl::wait() {
  sleep_s="${1}"
  shift

  until kubectl wait "${@}"; do sleep "${sleep_s}"; done | ensure_indent
}
