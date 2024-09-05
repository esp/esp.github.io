# This script build and serves the docs locally using https://github.com/envygeeks/jekyll-docker

# without this Jekyll container, which runs a chown, can't correctly execute that.
chmod -R 755 ./vendor

export JEKYLL_VERSION=4.2.2
docker run --rm \
  --volume="$PWD:/srv/jekyll:z" \
  --volume="$PWD/vendor/bundle:/usr/local/bundle:z" \
  -p 127.0.0.1:4000:4000/tcp \
  -it jekyll/jekyll \
  jekyll serve

#  chown jekyll:jekyll -R /usr/gem && jekyll serve