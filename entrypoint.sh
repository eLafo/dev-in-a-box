#!/bin/bash
[ -f .ruby-version ] && rbenv install $(cat .ruby-version) -s
exec "$@"