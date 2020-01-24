---
title: Lifetime Management
permalink: /concepts/esp-js-di/lifetime-management/
---

An object’s lifetime can be controlled by the container in a number of ways.

### Singleton

A singleton registration specifies the container will hold onto the object instance.
Multiple calls to `resolve` with the same key will yield the same instance.
When the container is disposed, the container will, for any registered instances with a `dispose` function, invoke that function.


```javascript
let Foo = {};
container.register('theFoo', Foo).singleton();
let foo1 = container.resolve('theFoo');
let foo2 = container.resolve('theFoo');
console.log(foo1 == foo2); // true
```

Note this is the default lifetime used and so the call to `.singleton()` is optional.

### Singleton Per Container

This is similar to a singleton however you get a single instance per [child container](./07-child-containers.md).

```javascript
let Bar = {};
container.register('theBar', Bar).singletonPerContainer();
let bar1 = container.resolve('theBar');
let bar2 = container.resolve('theBar');
let childContainer = container.createChildContainer();
let bar3 = childContainer.resolve('theBar');
let bar4 = childContainer.resolve('theBar');
console.log(bar1 == bar2); // true
console.log(bar2 == bar3); // false
console.log(bar3 == bar4); // true
```

### Transient

This creates a new instance each time a call to `resolve(identifier)` or `resolveGroup(groupName)` is made.
The container will not hold a reference to the instances created.

```javascript
let Baz = {};
container.register('theBaz', Baz).transient();
let baz1 = container.resolve('theBaz');
let baz2 = container.resolve('theBaz');
console.log(baz1 == baz2); // false
```

### External

Like a singleton however the container won't dispose the object when it's disposed.

```javascript
let Disposable = {
    init() {
        this.isDisposed = false;
        return this;
    },
    dispose() {
        this.isDisposed = true;
    }
};
// Note registerInstance internally sets the lifetime type as 'external', 
// You can pass false as the last argument if you want to change this. 
// The container will then manage it as 'singleton' and dispose the instance at disposal time 
container.registerInstance('disposable1', Object.create(Disposable).init());
container.register('disposable2', Disposable);
let disposable1 = container.resolve('disposable1');
let disposable2 = container.resolve('disposable2');
container.dispose();
console.log(disposable1.isDisposed); // false
console.log(disposable2.isDisposed); // true
```