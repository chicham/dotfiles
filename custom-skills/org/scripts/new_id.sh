#!/usr/bin/env bash
# Print a fresh UUID and an org-formatted timestamp on two lines:
#   <UUID>
#   [YYYY-MM-DD Day HH:MM]
# For use when populating org property drawers.
set -euo pipefail
uuidgen | tr '[:upper:]' '[:lower:]'
date +'[%Y-%m-%d %a %H:%M]'
