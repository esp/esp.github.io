---
title: Installation
permalink: /installation/
---

# Installation

This page shows how to install the ESP packages and load them in your app.

## Install the packages

Install the packages you need from npm:

```
npm install esp-js
npm install esp-js-di
npm install esp-js-ui
npm install esp-js-react
```

All four packages share one version number. Some packages need other packages installed too:

| Package | Also install |
|---|---|
| `esp-js` | nothing |
| `esp-js-di` | nothing |
| `esp-js-ui` | `esp-js` and `esp-js-di` |
| `esp-js-react` | `esp-js`, `esp-js-ui`, and React 19 |

## Import a package

Each package works with ESM `import` and CommonJS `require`:

```typescript
import { EventBus } from 'esp-js';
```

```javascript
const { EventBus } = require('esp-js');
```

Each package ships its own TypeScript typings, so you don't need an `@types` package.

## immer and class models

esp-js includes its own copy of [immer](https://immerjs.github.io/immer/), so you don't install it to use esp-js.
If your models are classes, install `immer` yourself to import `immerable`:

```
npm install immer
```

{% capture warning_1 %}Don't put a `Map` or `Set` in a model. The copy of immer inside esp-js can't draft them, and calling `enableMapSet()` from your own `immer` doesn't change that. See [maps and sets](../01-concepts/01-esp-js/03-store-builder.md#maps-and-sets).{% endcapture %}
{% include callout-warning.html content=warning_1 title="No maps or sets in a model" %}

## Load with a script tag

You can load esp-js and esp-js-di without a bundler.
Use `.dist/esp-js.js` and `.dist/esp-js-di.js` from the npm packages, or the `.min.js` files next to them.
esp-js sets the global `espJs`, and esp-js-di sets `espJsDi`.

The esp-js file reads `process.env.NODE_ENV`, which a browser doesn't have.
Define `process` in a script before you load it:

```html
<script>window.process = { env: { NODE_ENV: 'production' } };</script>
<script src="esp-js.min.js"></script>
<script src="esp-js-di.min.js"></script>
<script>
    const bus = new espJs.EventBus();
    const container = new espJsDi.Container();
</script>
```

Use a bundler for esp-js-ui and esp-js-react. They work with React components, and React 19 has no script-tag build.
