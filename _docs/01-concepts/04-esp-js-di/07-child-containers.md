---
title: Child containers
permalink: /concepts/esp-js-di/child-containers/
---

A child container scopes a set of related objects: it resolves its parent's registrations, adds its own, and disposes its objects when you dispose it.

Create a child container with `createChildContainer()`:

```ts
import { Container } from 'esp-js-di';

const container = new Container();
const childContainer = container.createChildContainer();
```

## Lifetimes in child containers

The registration's [lifetime](./06-lifetime-management.md) sets which container builds and holds the object:

- A singleton is built and held by the container that has the registration, so a parent and its children share it.
- A singleton per container is built and held by each container that resolves it.
- A transient object is built by the container that resolves it, and no container holds it.

```ts
import { Container } from 'esp-js-di';

const foo = {};
const container = new Container();
const childContainer = container.createChildContainer();

container.register('foo', foo); // a singleton by default
const foo1 = container.resolve('foo');
const foo2 = childContainer.resolve('foo');
console.log(foo1 === foo2); // true, the same instance

container.register('fooAgain', foo).singletonPerContainer();
const foo3 = container.resolve('fooAgain');
const foo4 = childContainer.resolve('fooAgain');
console.log(foo3 === foo4); // false, a different instance
const foo5 = childContainer.resolve('fooAgain');
console.log(foo4 === foo5); // true, the same instance
```

## Override a registration

A child container can register an identifier again. The new registration applies to the child only:

```ts
import { Container } from 'esp-js-di';

const foo = {};
const container = new Container();
container.register('foo', foo); // a singleton by default

const childContainer = container.createChildContainer();
childContainer.register('foo', foo).transient();

const foo1 = container.resolve('foo');
const foo2 = container.resolve('foo');
console.log(foo1 === foo2);

const foo3 = childContainer.resolve('foo');
console.log(foo2 === foo3);

const foo4 = childContainer.resolve('foo');
console.log(foo3 === foo4);
```

Output:

```
true
false
false
```

If you register an identifier again in the same container after it was resolved, the container keeps returning the instance it already holds.

## Groups in child containers

A child container resolves its parent's groups.
If the child adds a registration to a group with `inGroup()`, it starts a new group of the same name in the child.
That group holds only the child's registrations, and the parent's group doesn't change.

## Inject the owning container

Some objects need the container itself, for example an object that creates child containers.
Inject `EspDiConsts.owningContainer` to get the container that built the object:

```ts
import { Container, EspDiConsts } from 'esp-js-di';

class Bootstrapper {
    constructor(public container: Container) {}
}

const container1 = new Container();
container1
    .register('bootstrapper', Bootstrapper)
    .transient()
    .inject(EspDiConsts.owningContainer);

const bootstrapper1 = container1.resolve<Bootstrapper>('bootstrapper');
console.log(bootstrapper1.container === container1); // true

const container2 = container1.createChildContainer();
const bootstrapper2 = container2.resolve<Bootstrapper>('bootstrapper');
console.log(bootstrapper2.container === container2); // true
```

A child container injects itself only if the registration is `transient()` or `singletonPerContainer()`.
A singleton is built by the container that has the registration, so it gets that container, even when you resolve it from a child.

## Check what's registered

`isRegistered(identifier)` and `isGroupRegistered(groupName)` return `true` if the container or one of its parents has the registration.
Pass `{ searchParentContainers: false }` to check the container only:

```ts
import { Container } from 'esp-js-di';

const container = new Container();
container.register('foo', {}).inGroup('fooGroup');
const childContainer = container.createChildContainer();

console.log(childContainer.isRegistered('foo')); // true
console.log(childContainer.isRegistered('foo', { searchParentContainers: false })); // false
console.log(childContainer.isGroupRegistered('fooGroup', { searchParentContainers: false })); // false
```

## Disposal

`dispose()` disposes the objects the container holds, then disposes its child containers.
For which objects a container disposes, see [disposal](./06-lifetime-management.md#disposal).

```ts
import { Container } from 'esp-js-di';

class Foo {
    dispose() {
        console.log('foo disposed');
    }
}

const container = new Container();
container.register('foo', Foo).singletonPerContainer();
container.resolve('foo');

const childContainer = container.createChildContainer();
childContainer.resolve('foo');

container.dispose();
console.log(childContainer.isDisposed); // true
```

Output:

```
foo disposed
foo disposed
true
```

Disposing a child container doesn't dispose its parent.
The `isDisposed` property is `true` once a container is disposed.
After that, its methods, such as `resolve` and `register`, throw `Container has been disposed`.

## Container events

`on(eventType, handler)` adds a handler, and `off(eventType, handler)` removes it.
The container calls the handler with a notification that has the `name`, the `instance`, and the `eventType`:

- `instanceRegistered`: `registerInstance` added an instance.
- `instanceCreated`: the container built an instance.

The handlers are shared by the whole container tree, so a handler added on the root container also gets the events of every child container:

```ts
import { Container } from 'esp-js-di';

class Foo {}

const container = new Container();
container.on('instanceCreated', notification => console.log('created:', notification.name));

const childContainer = container.createChildContainer();
childContainer.register('foo', Foo).transient();
childContainer.resolve('foo');
```

Output:

```
created: foo
```
