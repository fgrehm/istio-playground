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
