---
title: Dependency Resolvers
permalink: /concepts/esp-js-di/dependency-resolvers/
---

Dependency resolvers alters the default way a dependency is created.
A dependency resolver is simply an object with a `resolve(container, resolverKey)` method.
You can create your own resolvers and add them to the container.
When registering an object, a `resolverKey` can be used as a [dependency](#dependencies).
This enables the container to resolve the dependency using the resolver specified.
A `resolverKey` can can also be specified as a replacement for the object or construction function that is to be built.
At resolve time the container will call the dependency resolver specified by the `resolverKey` to create the object in question.
The `container` and the `resolverKey` specified via `inject()` will be passed to the resolvers `resolve` method.
This sounds a bit more complicated than it actually is, it's easier to demonstrate with some code.

Here is an example where rather than registering a concrete object to build, a `resolverKey` is used.
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
var container = new Container();
container.addResolver('domResolver', new DomResolver());
// Note the usage of 'isResolverKey' so the container can distinguish this from a normal object.
// This is only required when you don't register a constructor function or prototype.
container.register('view', { resolver: 'domResolver', domId : 'theDomId', isResolverKey: true });
var view = container.resolve('view');
console.log(view.description);
```

Output:

```
Fake DOM element - theDomId

```

Here is an example where a concrete object is registered and a resolverKey is used to resolve a dependency of the registered item.

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
var container = new Container();
container.addResolver('domResolver', new DomResolver());
class Controller {
    constructor(view) {
        console.log(view.description);
    }
}
// Note we don't need to specify the 'isResolverKey' property on the resolverKey.
// The container assumes it is as it appears in the dependency list.
container.register('controller', Controller).inject({ resolver: 'domResolver', domId : 'viewId' });
var controller = container.resolve('controller');
```

Output:

```
Fake DOM element - viewId
```

### Built in resolvers
There are 3 built in resolvers.

#### Delegate

The `delegate` resolver simply defers object creation to a delegate provided by the `resolverKey`.

```javascript
class Foo  {
    constructor(bar) {
        console.log('bar is : [%s]', bar);
    }
}
var container = new Container();
container.register('foo', Foo)
    .inject(
    {
        resolver: 'delegate',
        resolve: (container, resolveKey) => {
            return 'barInstance';
        }
    });
var foo = container.resolve('foo');
```

Output:

```
bar is : [barInstance]
```

#### Injection factory

Discussed [above](#injection-factories), injection factories use the `factory` dependency resolver to wrap the creation call in a function for later invocation.

#### External factory

Under the covers `registerFactory` uses a built in `externalFactory` dependency resolver to invoke the factory registered against an identifier.