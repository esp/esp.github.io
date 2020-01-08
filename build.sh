
# https://stackoverflow.com/questions/33113945/can-jekyll-use-a-config-file-from-a-different-repo
#remove docs-build-temp folder if it exists
#rm -rf ./docs-build-temp
#
##make temp-content folder
#mkdir ./docs-build-temp
#
##copy content from doc folder in submodules into temp-content folder
#cp -R ./esp-js/docs/* ./docs-build-temp

# fix some issues with encoding https://github.com/csswizardry/inuit.css/issues/270#issuecomment-56056606
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

#tell jekyll the content source
# bundle exec jekyll build -s ./docs-build-temp
# bundle exec jekyll serve -s ./esp-js/docs
bundle exec jekyll serve -s ./