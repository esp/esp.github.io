---
title: Installation
classes: wide
permalink: /installation/
---

Install using yarn: `yarn add esp-js`.

If you're using ES6 with a package manager such as [webpack](https://webpack.github.io) you can import `esp` like this:

```javascript
import * as esp from 'esp-js';
var router = new esp.Router();

// or

import { Router } from 'esp-js';
var router = new Router();
```

Alternatively you can reference `dist\esp.js` or `dist\esp.min.js` via a `script` tag. These files expose `esp` using the Universal Module Definition (UMD) format. 

If you're using TypeScript [esp.d.ts](../esp.d.ts) is referenced via the `typings` property in [package.json](../package.json) so the TS compiler can discover it.
