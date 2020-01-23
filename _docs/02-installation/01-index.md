---
title: Installation
permalink: /installation/
---

# Installation

Install using npm or yarn, for example: `yarn add esp-js`.

If you're using ES6 with a package manager such as [webpack](https://webpack.github.io) you can import `esp` like this:

```javascript
import * as esp from 'esp-js';
var router = new esp.Router();

// or

import { Router } from 'esp-js';
var router = new Router();
```

Alternatively you can reference `dist\esp.js` or `dist\esp.min.js` via a `script` tag. These files expose `esp` using the Universal Module Definition (UMD) format. 

## TypeScript Typings

All packages have a corresponding `.d.ts` file which is correctly referenced via the `typings` property in each repos package.json.
This allows the TypeScript compiler to find it.