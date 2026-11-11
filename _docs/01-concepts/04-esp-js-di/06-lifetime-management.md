---
title: Lifetime management
permalink: /concepts/esp-js-di/lifetime-management/
---

A registration's lifetime sets whether `resolve` returns a new object or one the container already holds.

## Singleton

The container builds the object once, holds it, and returns the same instance on each `resolve`.

```ts
import { Container } from 'esp-js-di';

const container = new Container();
container.register('theFoo', {}).singleton();

const foo1 = container.resolve('theFoo');
const foo2 = container.resolve('theFoo');
console.log(foo1 === foo2); // true
```

Singleton is the default lifetime, so the call to `.singleton()` is optional.

## Singleton per container

Like a singleton, but each [child container](./07-child-containers.md) builds and holds its own instance.

```ts
import { Container } from 'esp-js-di';

const container = new Container();
container.register('theBar', {}).singletonPerContainer();

const bar1 = container.resolve('theBar');
const bar2 = container.resolve('theBar');
const childContainer = container.createChildContainer();
const bar3 = childContainer.resolve('theBar');
const bar4 = childContainer.resolve('theBar');
console.log(bar1 === bar2); // true
console.log(bar2 === bar3); // false
console.log(bar3 === bar4); // true
```

## Transient

The container builds a new object on each `resolve` or `resolveGroup`, and doesn't hold it.

```ts
import { Container } from 'esp-js-di';

const container = new Container();
container.register('theBaz', {}).transient();

const baz1 = container.resolve('theBaz');
const baz2 = container.resolve('theBaz');
console.log(baz1 === baz2); // false
```

## Disposal

`container.dispose()` calls `dispose()` on each object the container holds that has a `dispose` method.
The container holds singletons and singletons per container, so it disposes those.
It doesn't dispose transient objects, or instances that are externally owned.

## Externally owned instances

`registerInstance(identifier, instance, isExternallyOwned = true)` registers an object you created.
By default the instance is externally owned: the container returns it like a singleton, but doesn't dispose it.
Pass `false` as `isExternallyOwned` to have the container dispose it.

```ts
import { Container } from 'esp-js-di';

class Connection {
    isDisposed = false;
    dispose() {
        this.isDisposed = true;
    }
}

const container = new Container();
container.registerInstance('connection1', new Connection());
container.register('connection2', Connection);

const connection1 = container.resolve<Connection>('connection1');
const connection2 = container.resolve<Connection>('connection2');
container.dispose();
console.log(connection1.isDisposed); // false
console.log(connection2.isDisposed); // true
```

`connection1` is externally owned, so the container doesn't dispose it.
`connection2` is a singleton the container built, so the container disposes it.
