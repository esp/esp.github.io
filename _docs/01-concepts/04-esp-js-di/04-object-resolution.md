---
title: Object resolution
permalink: /concepts/esp-js-di/object-resolution/
---

You resolve an object by its identifier, and the container builds it and its dependencies.

The container has three methods to resolve objects:

- `container.resolve(identifier, ...additionalDependencies)` builds the object registered under `identifier`. It resolves each dependency listed with `inject()` and passes them in, followed by any additional dependencies.
- `container.resolveGroup(groupName, ...additionalDependencies)` returns an array with the objects registered in the group. See [resolve groups](#resolve-groups).
- `container.resolveMany(...specs)` resolves several identifiers into one object. See [resolve several objects](#resolve-several-objects).

## How the container builds an object

- If the registered item is a class or a constructor function, the container calls it with `new` and passes the dependencies to the constructor.
- Otherwise the container uses the item as a prototype: it creates the object with `Object.create(item)`. If the object has an `init()` method, the container calls it with the dependencies. If `init()` returns a value, `resolve` returns that value instead of the object.

## Resolve an object with a dependency

`Parent` takes a `Child` as its dependency.
`Child` is registered as `child`, and `Parent` as `parent`.
The `parent` registration injects `child`:

```ts
import { Container } from 'esp-js-di';

class Child {
    sayHello() {
        console.log('Hello from the child');
    }
}

class Parent {
    constructor(private child: Child) {}
    sayHello() {
        console.log('Hello from the parent');
        this.child.sayHello();
    }
}

const container = new Container();
container.register('child', Child);
container.register('parent', Parent).inject('child');

const parent = container.resolve<Parent>('parent');
parent.sayHello();
```

Output:

```
Hello from the parent
Hello from the child
```

## Resolve groups

Add registrations to a group with `inGroup(groupName)`, then resolve them all with `resolveGroup(groupName)`.
Use a group for objects that do the same kind of job.

```ts
import { Container } from 'esp-js-di';

const foo = { name: 'theFoo' };
const bar = { name: 'theBar' };

const container = new Container();
container.register('foo', foo).inGroup('group1');
container.register('bar', bar).inGroup('group1');

const group1 = container.resolveGroup<{ name: string }>('group1');
for (const item of group1) {
    console.log(item.name);
}
```

Output:

```
theFoo
theBar
```

`resolveGroup(groupName, ...additionalDependencies)` passes the additional dependencies to each object in the group.

### Inject a group

To inject a group, pass the group name to `inject()`. The object gets an array:

```ts
import { Container } from 'esp-js-di';

class Bazz {
    constructor(public group1: { name: string }[]) {}
}

const container = new Container();
container.register('foo', { name: 'theFoo' }).inGroup('group1');
container.register('bar', { name: 'theBar' }).inGroup('group1');
container.register('bazz', Bazz).inject('group1');

const bazz = container.resolve<Bazz>('bazz');
console.log(bazz.group1.map(item => item.name)); // [ 'theFoo', 'theBar' ]
```

If a name is both a group and an identifier, `inject()` injects the group.

## Additional dependencies

When you call `resolve`, you can pass additional dependencies.
The container passes them after the dependencies listed with `inject()`:

```ts
import { Container } from 'esp-js-di';

class Foo {
    constructor(fizz: { name: string }, bar: { name: string }, bazz: { name: string }) {
        console.log(`${fizz.name} ${bar.name} ${bazz.name}`);
    }
}

const container = new Container();
container.register('fizz', { name: 'fizz' });
container.register('foo', Foo).inject('fizz');

container.resolve<Foo>('foo', { name: 'bar' }, { name: 'bazz' });
```

Output:

```
fizz bar bazz
```

The container uses additional dependencies only when it builds a new object.
If the container already holds the instance, for example a singleton, `resolve` with additional dependencies throws.
To pass different dependencies on each call, register the item as `transient()`. See [lifetime management](./06-lifetime-management.md).

## Resolve several objects

`container.resolveMany(...specs)` resolves several objects and returns them in one object, keyed by identifier.
Each spec is an identifier, or an object `{ name, additionalDependencies }`:

```ts
import { Container } from 'esp-js-di';

class Logger {}
class Report {
    constructor(public logger: Logger, public title: string) {}
}

const container = new Container();
container.register('logger', Logger);
container.register('report', Report).inject('logger').transient();

const { logger, report } = container.resolveMany<{ logger: Logger, report: Report }>(
    'logger',
    { name: 'report', additionalDependencies: ['Monthly'] },
);
console.log(report.title); // Monthly
console.log(report.logger === logger); // true
```

`resolveMany` calls `resolve` for each spec in order.
If one fails, it throws, and the objects it already resolved stay resolved.
