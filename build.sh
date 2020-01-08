# fix some issues with encoding https://github.com/csswizardry/inuit.css/issues/270#issuecomment-56056606
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

bundle exec jekyll serve -s ./