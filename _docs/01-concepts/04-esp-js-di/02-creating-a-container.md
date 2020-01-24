---
title: Creating a Container
permalink: /concepts/esp-js-di/creating-a-container/
---

You can import and create a container like this:

```javascript
import {Container} from 'esp-js-di';
const container = new Container();
```

Typically you'll have 1 base container in your application.
There internal shared state so that's not a hard or fast rule.