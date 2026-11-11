---
title: Object registration
permalink: /concepts/esp-js-di/object-registration/
---

You register an object with the container under a string identifier, then resolve it by that identifier.

{% capture info_1 %}
Typed languages use the type system to find dependencies.
JavaScript has no types at runtime, so you use strings, called identifiers, to name the objects to build.
{% endcapture %}
{% include callout-info.html content=info_1 title="Why strings?" %}

There are three ways to register an object.

## Register a class or a prototype

`container.register(identifier, item)` registers a class, or an object to use as a prototype, under `identifier`.
Chain calls on the result to change the registration:

```ts
import { Container } from 'esp-js-di';

class Logger {}
class Settings {}
class Item {
    constructor(public logger: Logger, public settings: Settings) {}
}

const container = new Container();
container.register('logger', Logger);
container.register('settings', Settings);

const identifier = 'item';
container
    .register(identifier, Item)
    .inject('logger', 'settings')
    .singletonPerContainer()
    .inGroup('items');
```

This registers `Item` under the value of `identifier`, `'item'`:

- `inject('logger', 'settings')` lists its dependencies, in the order its constructor takes them.
- Its [lifetime](./06-lifetime-management.md) is `singletonPerContainer`.
- You can resolve it by its identifier, or as part of the [group](./04-object-resolution.md#resolve-groups) `items`.

The container can't read a constructor's parameters, so you list the dependencies with `inject()`.
Each argument to `inject()` is usually the identifier of another registration.
The container calls these arguments dependency keys.
A dependency key can also be an object that names a [dependency resolver](./08-dependency-resolvers.md).

`register` throws if the item is a string or a number. Use `registerInstance` for those.

## Register an instance

`container.registerInstance(identifier, instance, isExternallyOwned = true)` registers an object you already created.
It returns nothing, so you can't chain calls on it.

```ts
import { Container } from 'esp-js-di';

const container = new Container();
const settings = { theme: 'dark' };
container.registerInstance('settings', settings);

console.log(container.resolve('settings') === settings); // true
```

By default the container doesn't dispose the instance. See [lifetime management](./06-lifetime-management.md#externally-owned-instances).

## Register a factory

`container.registerFactory(identifier, factory)` registers a function that creates the object.
The container calls the factory with itself as the first argument, then any additional dependencies passed to `resolve`.
The factory returns the new object.

```ts
import { Container } from 'esp-js-di';

class FooDependency {}
class Foo {
    public values: number[];
    constructor(public dependency: FooDependency, ...values: number[]) {
        this.values = values;
    }
}

const container = new Container();
container.register('fooDependency', FooDependency);
container
    .registerFactory('foo', (container, ...additionalDependencies) => {
        const fooDependency = container.resolve<FooDependency>('fooDependency');
        return new Foo(fooDependency, ...additionalDependencies);
    })
    .transient();

const foo = container.resolve<Foo>('foo', 1, 2, 3);
console.log(foo.values); // [ 1, 2, 3 ]
```

The factory resolves `fooDependency`, then passes it and the additional dependencies `1, 2, 3` to the `Foo` constructor.
The registration is `transient`, so each `resolve` calls the factory again and returns a new `Foo`.

If you add `inject()` to a factory registration, the factory gets the container, then the injected dependencies, then the additional dependencies:

```ts
import { Container } from 'esp-js-di';

class FooDependency {}
class Foo {
    constructor(public dependency: FooDependency, public name: string) {}
}

const container = new Container();
container.register('fooDependency', FooDependency);
container
    .registerFactory('foo', (container, fooDependency, name) => new Foo(fooDependency, name))
    .inject('fooDependency')
    .transient();

const foo = container.resolve<Foo>('foo', 'theFoo');
console.log(foo.name); // theFoo
```
