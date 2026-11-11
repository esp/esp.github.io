---
title: Creating a container
permalink: /concepts/esp-js-di/creating-a-container/
---

Import `Container` and create one with `new`:

```ts
import { Container } from 'esp-js-di';

const container = new Container();
```

An app usually has one root container.
To scope a set of objects, create a [child container](./07-child-containers.md) from it.

## The default export

In JavaScript, you can also import the default export.
It holds `Container`, `RegistrationModifier`, `ResolverContext`, `EspDiConsts`, and `ResolverNames`:

```javascript
import espDi from 'esp-js-di';

const container = new espDi.Container();
```

The TypeScript typings don't declare the default export, so in TypeScript import the named exports.
