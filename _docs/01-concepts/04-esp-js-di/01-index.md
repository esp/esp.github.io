---
title: esp-js-di
permalink: /concepts/esp-js-di/
---

[`esp-js-di`](https://www.npmjs.com/package/esp-js-di) is a small dependency injection container for JavaScript and TypeScript.

You register each object under a string, called an identifier, and say which other identifiers it needs.
When you resolve an identifier, the container builds the object and its dependencies:

```ts
import { Container } from 'esp-js-di';

class Logger {
    log(message: string) {
        console.log(message);
    }
}

class OrderService {
    constructor(private logger: Logger) {}
    placeOrder() {
        this.logger.log('Order placed');
    }
}

const container = new Container();
container.register('logger', Logger);
container.register('orderService', OrderService).inject('logger');

const orderService = container.resolve<OrderService>('orderService');
orderService.placeOrder(); // Order placed
```

`esp-js-ui` uses `esp-js-di` for an app's services. See [services](../05-esp-js-ui/04-services.md).

## Pages in this section

- [Creating a container](./02-creating-a-container.md)
- [Object registration](./03-object-registration.md): `register`, `registerInstance`, and `registerFactory`.
- [Object resolution](./04-object-resolution.md): `resolve`, `resolveGroup`, and `resolveMany`.
- [Object factories](./05-object-factories.md): inject a function that resolves an object.
- [Lifetime management](./06-lifetime-management.md): singleton, singleton per container, and transient.
- [Child containers](./07-child-containers.md): scope a set of objects, and dispose them together.
- [Dependency resolvers](./08-dependency-resolvers.md): change how a dependency is built.
- [Why no annotations?](./09-why-no-annotations.md)
