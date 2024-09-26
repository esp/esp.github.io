---
title: Releasing
permalink: /source/releasing/
---

This document describes how to push the esp packages to npm.
It's a reference for the maintainers.

The project is published using [Lerna](https://github.com/lerna/lerna).

There is explicit configuration for the lerna publish command in `lerna.json` so the below should be read with that in mind.

The root `package.json`  has script targets for the most common publishing scenarios:

```
{
  ...
  "scripts": {
    ...
    "release-major": "yarn clean && yarn build-prod && lerna publish major",
    "release-minor": "yarn clean && yarn build-prod && lerna publish minor",
    "release-patch": "yarn clean && yarn build-prod && lerna publish patch",
    "pre-release-major": "yarn clean && yarn build-prod && lerna publish premajor --preid next --dist-tag next",
    "pre-release-minor": "yarn clean && yarn build-prod && lerna publish preminor --preid next --dist-tag next",
    "pre-release-patch": "yarn clean && yarn build-prod && lerna publish prepatch --preid next --dist-tag next"
  },
  ...
}
```

Each of these scripts:
* Builds and tests all the code.
* Uses lerna to bump the version, make a commit and push to the current branch.
* If using a  `pre-release-x` script target, the package version will include a preid (e.g. `esp-js-ui@2.1.0-next.0`) and will push to npm using a non 'latest' dist tag, e.g. 'next'
  This will stop a default `yarn install esp-js` from pulling the pre release  packages.
  
Procedure

Releases are carried out on a release branch named `release-x.x.x` (namings with a slash, i.e. `release/x.x.x` currently not supported due to a lerna error).
Simply run the appropriate yarn command, e.g: `yarn release-minor`.

If you have some issues with the above, lerna may have already pushed some tags which you'll have to delete before trying again:

```
// Delete locally
git tag -d vx.x.x
// Delete remotely
git push --delete origin vx.x.x
```

Once the release has been pushed:
 
1. Raise and merge a PR to master
1. Manually create an explicit release on the GitHub UI

### Reference  
* [lerna version docs](https://github.com/lerna/lerna/tree/master/commands/version#readme).
* [lerna publish docs](https://github.com/lerna/lerna/tree/master/commands/publish#readme). 