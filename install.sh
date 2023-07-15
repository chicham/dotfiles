#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

OP_VERSION=2.18.0
curl -l https://cache.agilebits.com/dist/1P/op2/pkg/v$OP_VERSION/op_linux_amd64_v$OP_VERSION.zip  > /tmp/op-$OP_VERSION.zip && unzip /tmp/op-$OP_VERSION.zip -d /tmp/op-$OP_VERSION && mv /tmp/op-$OP_VERSION/op ~/.local/bin && chmod u+x ~/.local/bin/op && rm -rf /tmp/op-$OP_VERSION*
if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  echo "Installing chezmoi to '${chezmoi}'" >&2
  if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL https://chezmoi.io/get)"
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- https://chezmoi.io/get)"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}"

echo "Running 'chezmoi $*'" >&2
# exec: replace current process with chezmoi
exec "$chezmoi" "$@"
