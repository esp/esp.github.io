---
title: Dependency Resolvers
permalink: /concepts/esp-js-di/dependency-resolvers/
---

Dependency resolvers alters the default way a dependency is created.
They are effectively a custom hook that is called to get the dependency being built. 

A dependency resolver is simply an object with a `resolve(container, resolverKey)` method.
You can create these and add them to the container.
Then when registering an object you tell the container to use the custom resolver to build the object.

Here is an example where rather than registering a `class` or `object` to build, a `resolverKey` is used.
The `DomResolver` resolver will be used to resolve the object.

```javascript
class DomResolver {
    resolve(container, resolverKey) {
        // return a pretend dom element,
        return {
            get description() {
                return 'Fake DOM element - ' + resolverKey.domId ;
            }
        };
    }
}
let container = new Container();
container.addResolver('domResolver', new DomResolver());
// When using a resolve key to create the registered item we need to add a 'isResolverKey' property. 
// This lets the container know the object you're passing to `register` isn't what should be returned when something calls resolve, 
// rather it'll use this object to create the object in question and return that to the caller. 
container.register('view', { resolver: 'domResolver', domId : 'theDomId', isResolverKey: true });
let view = container.resolve('view');
console.log(view.description);
```

Output:

```
Fake DOM element - theDomId
```

Here is an example where an object injected into a dependency is resolved using a custom resolver.

```javascript
class DomResolver {
    resolve(container, resolverKey) {
        // return a pretend dom element,
        return {
            get description() {
                return 'Fake DOM element - ' + resolverKey.domId ;
            }
        };
    }
}
let container = new Container();
container.addResolver('domResolver', new DomResolver());
class Controller {
    constructor(view) {
        console.log(view.description);
    }
}
// Note we don't need to specify the 'isResolverKey' property on the resolverKey.
// The container assumes it is as it's being used via `inject`.
container.register('controller', Controller).inject({ resolver: 'domResolver', domId : 'viewId' });
let controller = container.resolve('controller');
```

Output:

```
Fake DOM element - viewId
```

## Built in Resolvers
There are 3 built in resolvers.

### Delegate

The `delegate` resolver simply defers object creation to a delegate provided by the `resolverKey`.

```javascript
class Foo  {
    constructor(bar) {
        console.log('bar is : [%s]', bar);
    }
}
let container = new Container();
container.register('foo', Foo)
    .inject(
    {
        // Internally the container registers a resolver by key 'delegate'
        resolver: 'delegate',
        // use this function to create the dependency 
        resolve: (container, resolveKey) => {
            return 'barInstance';
        }
    });
let foo = container.resolve('foo');
```

Output:

```
bar is : [barInstance]
```

### Injection Factory

The factories discussed under [Object Factories](./05-object-factories.md) are implemented using the built in `factory` dependency resolver.

### External Factory

Under the covers `registerFactory` uses a built in `externalFactory` dependency resolver to invoke the factory registered against an identifier.