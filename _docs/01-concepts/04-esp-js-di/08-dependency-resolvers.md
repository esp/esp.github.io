---
title: Dependency resolvers
permalink: /concepts/esp-js-di/dependency-resolvers/
---

A dependency resolver changes how the container builds a dependency: the container calls the resolver to get the value to inject.

To use a resolver, pass an object with a `resolver` property to `inject()`.
The container calls this object the dependency key:

```ts
container
    .register('myClass', MyClass)
    .inject(
        { resolver: 'literal', value: 'the-string-to-inject' }, // a dependency key for the built-in literal resolver
        'my-other-object-key', // a plain string dependency key
    );
```

There are four built-in resolvers, and you can add your own.
The `ResolverNames` export holds the built-in names: `ResolverNames.literal`, `ResolverNames.delegate`, `ResolverNames.factory`, and `ResolverNames.externalFactory`.

## Built-in resolvers

### Literal

The `literal` resolver injects the `value` from the dependency key, for example a string:

```ts
import { Container } from 'esp-js-di';

class MyClass {
    constructor(public name: string) {}
    hello() {
        console.log(`Hello ${this.name}`);
    }
}

const container = new Container();
container
    .register('myClass', MyClass)
    .inject({ resolver: 'literal', value: 'world' });

const myClass = container.resolve<MyClass>('myClass');
myClass.hello(); // Hello world
```

If `value` is `null` or `undefined`, `resolve` throws.

### Delegate

The `delegate` resolver calls the `resolve(container)` function on the dependency key, and injects what it returns:

```ts
import { Container } from 'esp-js-di';

class Foo {
    constructor(bar: string) {
        console.log(`bar is: [${bar}]`);
    }
}

const container = new Container();
container
    .register('foo', Foo)
    .inject({
        resolver: 'delegate',
        resolve: (container: Container) => 'barInstance',
    });

container.resolve<Foo>('foo');
```

Output:

```
bar is: [barInstance]
```

### Factory

The `factory` resolver injects a function that resolves an object. See [object factories](./05-object-factories.md).

### External factory

`registerFactory` uses the `externalFactory` resolver to call the factory you registered. See [object registration](./03-object-registration.md#register-a-factory).

## Custom resolvers

A resolver is an object with a `resolve(container, dependencyKey)` method:

- `container` is the container that `resolve()` was called on, which can be a child container.
- `dependencyKey` is the object passed to `inject()`.

Add a resolver to a container with `addResolver(name, resolver)`, then name it in the dependency key's `resolver` property.

### Inject with a custom resolver

Here a custom resolver builds the `view` dependency of `Controller`:

```ts
import { Container } from 'esp-js-di';

class DomResolver {
    resolve(container: Container, dependencyKey: { domId: string }) {
        // return a pretend DOM element
        return {
            description: `Fake DOM element - ${dependencyKey.domId}`,
        };
    }
}

class Controller {
    constructor(view: { description: string }) {
        console.log(view.description);
    }
}

const container = new Container();
container.addResolver('domResolver', new DomResolver());
container
    .register('controller', Controller)
    .inject({ resolver: 'domResolver', domId: 'viewId' }); // this object is the dependency key

container.resolve<Controller>('controller');
```

Output:

```
Fake DOM element - viewId
```

### Register with a custom resolver

You can also pass a dependency key to `register()`, so the resolver builds the registered object itself.
Add `isResolverKey: true` to the key.
Without it, the container treats the key as a prototype, like any other registered object.

```ts
import { Container } from 'esp-js-di';

class DomResolver {
    resolve(container: Container, dependencyKey: { domId: string }) {
        // return a pretend DOM element
        return {
            description: `Fake DOM element - ${dependencyKey.domId}`,
        };
    }
}

const container = new Container();
container.addResolver('domResolver', new DomResolver());
container.register('view', { resolver: 'domResolver', domId: 'theDomId', isResolverKey: true });

const view = container.resolve<{ description: string }>('view');
console.log(view.description);
```

Output:

```
Fake DOM element - theDomId
```
