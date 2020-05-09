#!/bin/bash
[ -f .ruby-version ] && rbenv install $(cat .ruby-version) -s
[ -f .nvmrc ] && . $NVM_DIR/nvm.sh && nvm install
[ -f .python-version ] && pyenv install $(cat .python-version) -s

exec "$@"