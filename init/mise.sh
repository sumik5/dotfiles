#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

mise_install() {
  e_prompt "install mise"
  if command -v mise >/dev/null 2>&1; then
     e_skip
  else
     curl https://mise.run | sh
  fi
}

mise_install
