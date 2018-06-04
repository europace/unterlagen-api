#!/bin/bash

mydate ()  { date '+%d.%m.%Y %H:%M:%S'; }
info ()    { printf '%s %s info %s\n' "$(mydate)" "$ME" "$*"; }
warning () { printf '%s %s warning %s\n' "$(mydate)" "$ME" "$*"; }
error () { printf '%s %s error %s\n' "$(mydate)" "$ME" "$*" 2>&1; exit 1; }
usage ()   { error "$(myhelp | grep -i '^Syntax:')"; }
gibVersionLesbarAus() {
  printf "%s\n%s\n" "${VERSION:0:10}" "${VERSION:11}"
}
