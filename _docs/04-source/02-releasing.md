---
title: Releasing
permalink: /source/releasing/
---

This document describes how to push the esp packages to npm.
It's a reference for the maintainers.

The project is published using [Lerna](https://github.com/lerna/lerna).

There is explicit configuration for the lerna publish command in `lerna.json` so the below should be read with that in mind.

The root `package.json`  has script targets for the most common publishing scenarios:

```json
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
  

### Reference  
* [lerna version docs](https://github.com/lerna/lerna/tree/master/commands/version#readme).
* [lerna publish docs](https://github.com/lerna/lerna/tree/master/commands/publish#readme). 