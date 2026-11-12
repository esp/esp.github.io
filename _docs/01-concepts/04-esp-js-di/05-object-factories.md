---
title: Object factories
permalink: /concepts/esp-js-di/object-factories/
---

An object can take a factory: a function that resolves a dependency each time you call it.

To inject a factory, pass `{ resolver: 'factory', key: identifier }` to `inject()`.
This uses the built-in `factory` [dependency resolver](./08-dependency-resolvers.md).

```ts
import { Container } from 'esp-js-di';

class Item {
    constructor() {
        console.log('creating an item');
    }
}

class Manager {
    constructor(private itemFactory: () => Item) {}
    createItem() {
        return this.itemFactory();
    }
}

const container = new Container();
container.register('item', Item).transient();
container.register('manager', Manager).inject({ resolver: 'factory', key: 'item' });

const manager = container.resolve<Manager>('manager');
manager.createItem();
manager.createItem();
```

Output:

```
creating an item
creating an item
```

The factory calls `container.resolve('item')`, so the lifetime of `item` still applies.
`item` is registered as `transient()`, so each call builds a new `Item`.
Without `transient()`, `item` is a singleton: the first call builds it, and the second call returns the same instance.

{% capture info_1 %}
`registerFactory` registers the function that creates the object.
An injected factory lets the container create the object, and injects a function that resolves it.
Use it to resolve an object later, or to create many objects without taking a dependency on the container.
{% endcapture %}
{% include callout-info.html content=info_1 title="Injected factories and registered factories" %}

## Additional dependencies in factories

The factory passes its arguments to `resolve` as [additional dependencies](./04-object-resolution.md#additional-dependencies).
Here `Item` takes an injected dependency, then a name passed to the factory:

```ts
import { Container } from 'esp-js-di';

class Item {
    constructor(otherDependencyA: string, name: string) {
        console.log(`Hello ${name}. Other dependency: ${otherDependencyA}`);
    }
}

class Manager {
    constructor(private itemFactory: (name: string) => Item) {}
    createItem(name: string) {
        return this.itemFactory(name);
    }
}

const container = new Container();
container.registerInstance('otherDependencyA', 'look! a string dependency');
container.register('item', Item).inject('otherDependencyA').transient();
container.register('manager', Manager).inject({ resolver: 'factory', key: 'item' });

const manager = container.resolve<Manager>('manager');
manager.createItem('Foo');
manager.createItem('Bar');
```

Output:

```
Hello Foo. Other dependency: look! a string dependency
Hello Bar. Other dependency: look! a string dependency
```

Here `transient()` is required.
Without it, the second call passes an additional dependency to the singleton that already exists, and `resolve` throws.
