#!/bin/bash
[ -f .ruby-version ] && rbenv install $(cat .ruby-version) -s
echo $PATH
[ -f .nvmrc ] && . $NVM_DIR/nvm.sh && nvm install
exec "$@"