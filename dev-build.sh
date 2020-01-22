# This script build and serves the docs locally using https://github.com/envygeeks/jekyll-docker

# This stops the need to rebuild the bundle, however seems slower.
# I've not had time to check it out why
# --volume="$PWD/vendor/bundle:/usr/local/bundle" \

export JEKYLL_VERSION=3.8
docker run --rm \
  --volume="$PWD:/srv/jekyll" \
  --volume="$PWD/vendor/bundle:/usr/local/bundle" \
  -p 127.0.0.1:4000:4000/tcp \
  -it jekyll/jekyll:$JEKYLL_VERSION \
  jekyll serve