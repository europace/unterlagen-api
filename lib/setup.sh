#!/bin/bash

ME="$(basename "${0%.sh}")"
MYPWD="$PWD"
MYDIR="$(cd $(dirname "$0"); pwd)" || MYDIR="$PWD"

EP2_SCRIPTLIBDIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)" || EP2_DIR="$MYDIR"
EP2_DIR="$(dirname "$EP2_SCRIPTLIBDIR")"

import() {
  source "$EP2_SCRIPTLIBDIR/$@"
}