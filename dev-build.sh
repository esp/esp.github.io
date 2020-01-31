# This script build and serves the docs locally using https://github.com/envygeeks/jekyll-docker

export JEKYLL_VERSION=3.8
docker run --rm \
  --volume="$PWD:/srv/jekyll" \
  --volume="$PWD/vendor/bundle:/usr/local/bundle" \
  -p 127.0.0.1:4000:4000/tcp \
  -it jekyll/jekyll:$JEKYLL_VERSION \
  jekyll serve