---
title: Dependency Resolvers
permalink: /concepts/esp-js-di/dependency-resolvers/
---

Dependency resolvers alter the default way a dependency is created.
They are effectively a custom hook that will be invoked to get the dependency being built. 

When registering items in the `Container` you can reference dependency resolvers via the `inject()` function. 
For example:

```javascript
class MyClass {
    constructor(myStringValue, someOtherObject) {}
}
container
    .register('myClass', MyClass)
    .inject(
        { resolver: 'literal', value : 'the-string-to-inject' }, // a dependency key referencing a build in literal resolver
        'my-other-object-key' // plain old string dependency key
    );
```

There are 4 built in resolvers and you can create your own if required.

## Built in Resolvers

### Literal

This is handy if you want to inject a literal value, for example a `string`, into a dependency.

```javascript
class MyClass {
    constructor(name) {
        this.name = name;
    }
    hello() {
        console.log(`Hello ${this.name}`);
    }
}
let container = new Container();
container
    .register('myClass', MyClass)
    .inject({ resolver: 'literal', value : 'world' });
let myClassInstance = container.resolve('myClass');
myClassInstance.hello(); // prints 'Hello world'
```

### Delegate

The `delegate` resolver defers object creation to a delegate provided by the `dependencyKey`.

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

## Custom Resolvers

A dependency resolver is simply an object with a `resolve(container, dependencyKey)` method.
The `container` argument will be the current container (i.e. the container or child container which `resolve()` was called on), and the `dependencyKey` argument is the object passed to the `inject(dependencyKey)` function.
You can create your own resolvers and add them to the container.

### Example 1

Here is an example where an object injected into a dependency is resolved using a custom resolver.

```javascript
class DomResolver {
    resolve(container, dependencyKey) {
        // return a pretend dom element,
        return {
            get description() {
                return 'Fake DOM element - ' + dependencyKey.domId ;
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
container
    .register('controller', Controller)
    .inject(
        { resolver: 'domResolver', domId : 'viewId' } // this object is the 'dependencyKey'
    );
let controller = container.resolve('controller');
```

Output:

```
Fake DOM element - viewId
```

### Example 2

This is a much more edge case example whereby you don't know the type of the object you're registering.
Rather than registering a `class` or `object` to build, we pass a `dependencyKey` to the `register()` API.
In this example, we emulate the fetching of a DOM node when resolving the dependency `view`. 

```javascript
class DomResolver {
    resolve(container, dependencyKey) {
        // return a pretend dom element,
        return {
            get description() {
                return 'Fake DOM element - ' + dependencyKey.domId ;
            }
        };
    }
}
let container = new Container();
container.addResolver('domResolver', new DomResolver());
// When using a resolve key to create the registered item we need to add a 'isdependencyKey' property. 
// This lets the container know the object you're passing to `register` isn't what should be returned when something calls resolve, 
// rather it'll use this object to create the object in question and return that to the caller. 
container.register('view', { resolver: 'domResolver', domId : 'theDomId', isdependencyKey: true });
let view = container.resolve('view');
console.log(view.description);
```

Output:

```
Fake DOM element - theDomId
```



