#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export MAKEFUN_CONTINUATION_DOC='TINY-VM-TOP10-RUN.md'
export MAKEFUN_CONTINUATION_MINUTES=30
exec bash "$script_dir/continue-tiny-vm.sh"
