#!/bin/sh
# Update the gems before starting Jekyll
#bundle install --jobs 4

. $(pwd)/envrc

# NOTE:
# If you use 'jekyll serve' from inside the container, you MUST
# use the '-H 0.0.0.0' option, or jekyll will reject all connections
# (because it only listens on 127.0.0.1 by default).
jekyll "$@"
