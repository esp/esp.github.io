---
title: Object Factories
permalink: /concepts/esp-js-di/object-factories/
---

Sometimes you want your object to receive a factory, that when called will `resolve` and return the dependency in question.

```javascript
class Item {
    constructor() {
        console.log("creating an item");
    }
}
class Manager{
    constructor(itemFactory) {
        this._itemFactory = itemFactory;
    }
    createItem(name) {
        return this._itemFactory(name);
    }
}
var container = new Container();
container.register('item', Item).transient();
container.register('manager', Manager).inject({ resolver: 'factory', key: 'item'});
var manager = container.resolve('manager');
var item1 = manager.createItem();
var item2 = manager.createItem();
```

output:

```
creating an item
creating an item

```

> **Note**
>
> Injected factories are different from factories you use to create objects (via `container.registerFactory`). 
> A factory registered via `registerFactory` is simply used to create your instance. 
> An injected factory lets the container create the instance but it wraps this creation in a factory and injects the factory. 
> It's typically used for lazy resolution of objects or when an object needs to create many other objects but doesn't want to take a dependency on the container itself. 

### Additional dependencies in factories

You can pass arguments to the factory and they forwarded as discussed [above](#resolution-with-additional-dependencies).

Lets modify the sample from above to demonstrate this:

```javascript
class Item {
    constructor(otherDependencyA, name) {
        console.log('Hello ' + name + '. Other dependency: ' + otherDependencyA);
    }
}
class Manager{
    constructor(itemFactory) {
        this._itemFactory = itemFactory;
    }
    createItem(name) {
        return this._itemFactory(name);
    }
}
var container = new Container();
container.registerInstance('otherDependencyA', 'look! a string dependency');
container.register('item', Item).inject('otherDependencyA').transient();
container.register('manager', Manager).inject({ resolver: 'factory', key: 'item'});
var manager = container.resolve('manager');
var fooItem = manager.createItem('Foo');
var barItem = manager.createItem('Bar');
```

output:

```
Hello Bob
Hello Mick
```
