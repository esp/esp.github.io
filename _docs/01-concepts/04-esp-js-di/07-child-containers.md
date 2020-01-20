---
title: Child containers
permalink: /concepts/esp-js-di/child-containers/
---

Child containers can be used to manage and scope a set of related objects.
They inherit configuration from the parent however can be re-configured.
They also inherit instances from their parent depending upon the lifetime management of the objects in question. 

Create a child container by calling `createChildContainer` on a parent;
```javascript
var container = new Container();
var childcontainer = container.createChildContainer();
```

### Lifetime management in child containers

Depending upon registration configurations, objects resolved from a child container will either be owned by the child container or the parent.

```javascript
var Foo = { };
var container = new Container();
var childContainer = container.createChildContainer();
container.register('foo', Foo); // defaults to singleton registration
var foo1 = container.resolve('foo');
var foo2 = childContainer.resolve('foo');
console.log(foo1 == foo2); // true, same instance

container.register('fooAgain', Foo).singletonPerContainer();
var foo3 = container.resolve('fooAgain');
var foo4 = childContainer.resolve('fooAgain');
console.log(foo3 == foo4); // false, different instance
var foo5 = childContainer.resolve('fooAgain');
console.log(foo4 == foo5); // true, same instance
```

### Overriding Registrations

The configuration of a child container can be overridden if required.

```javascript
var Foo = { };
var container = new Container();
container.register('foo', Foo); // defaults to singleton registration

var childcontainer = container.createChildContainer();
childcontainer.register('foo', Foo).transient();

var foo1 = container.resolve('foo');
var foo2 = container.resolve('foo');
console.log(foo1 == foo2); // true, same instance

var foo3 = childcontainer.resolve('foo');
console.log(foo2 == foo3); // false, different instance

var foo4 = childcontainer.resolve('foo');
console.log(foo3 == foo4); // false, different instance
```

Output:

```
true
false
false
```

## Resolving the container

Sometimes you have an object that requires the container to be injected. 
While often thought of as an anti pattern, there are scenarios where this makes sense. 
If the object is a 'bootstrapper' of sorts, i.e. it needs fine grained control over child containers and sub object graph resolution, injecting a container makes sense. 
  
When there are child containers at play, you'd expect objects who require a container, to be provide with the same container that build them, i.e. the child container in question. 
 
Lets look at an example:

```javascript
// a class that takes a container as a dependency
class Bootstrapper {
    constructor(container) {
        this._container = container; 
    }
}
```

Lets look at the manual way of doing this:

```javascript
import { Container } from 'esp-js-di'; 
var container = new Container();
container.registerInstance('theRootContainer', container);
container.register('bootstrapper', Bootstrapper).inject('theRootContainer');
// bootstrapper will get injected with instance `container`
let bootstrapper = container.resolve('bootstrapper');
```

This will work, but when there are child container at play it gets a bit messy as you have to register things manually each time a child is created.
Typically you strive to keep child container re-configuration to a minimum for code maintainability reasons. 

The `Container` supports a special injection key exposed as `EspDiConsts.owningContainer`.
This key will ensure an object getting resolved get it's owning container.
Lets re-work the above example:

```javascript
import { Container, EspDiConsts } from 'esp-js-di'; 
var container = new Container();
container
    .register('bootstrapper', Bootstrapper)
    .inject(EspDiConsts.owningContainer);
// bootstrapper will get injected with instance `container`
let bootstrapper = container.resolve('bootstrapper');
```

Objects injected with `EspDiConsts.owningContainer` and resolved from child containers will get the owning child container injected: 

```javascript
import { Container, EspDiConsts } from 'esp-js-di'; 
var container1 = new Container();
container1
    .register('bootstrapper', Bootstrapper)
    .transient() // resolve new `Bootstrapper` instance each time
    .inject(EspDiConsts.owningContainer);

// bootstrapper1 will get injected with `container1`
let bootstrapper1 = container1.resolve('bootstrapper');

// bootstrapper2 will get injected with `container2`
let container2 = container1.createChildContainer();
let bootstrapper2 = container2.resolve('bootstrapper');
```

## Checking what's registered

You can check if a dependency is registered using `.isRegistered(name)`.
A group can be checked using `.isGroupRegistered(groupName):boolean`.
Both these exist on a `container` object and will return a boolean result. 

## Disposal

When you call `.dispose()` on a container, that container will inspect any object it holds and if an object has a `dispose` function, it will be called.
However it will not dispose transient-created objects or objects registered via `registerInstance('aKey', myInstance)`.
Any child containers created from the disposed parent will also be disposed.  These child containers will in turn dispose of their registered instances.

```javascript
class Foo {
    dispose() {
        console.log('foo disposed');
    }
}

var container = new Container();

container.register('foo', Foo).singletonPerContainer();
var foo1 = container.resolve('foo');

var childcontainer = container.createChildContainer();
var foo2 = childcontainer.resolve('foo');

container.dispose();
```

Output:

```
foo disposed
foo disposed
```