---
title: Object Factories
permalink: /concepts/esp-js-di/object-factories/
---

Sometimes you want your object to receive a factory, that when called will `resolve` and return the dependency in question.

{% capture info_1 %}
This feature uses the built in factory [Dependency Resolver](./08-dependency-resolvers.md). 
{% endcapture %}
{% include callout-info.html content=info_1 %}

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
let container = new Container();
container.register('item', Item).transient();
container.register('manager', Manager).inject({ resolver: 'factory', key: 'item'});
let manager = container.resolve('manager');
let item1 = manager.createItem();
let item2 = manager.createItem();
```

Output:

```
creating an item
creating an item

```

{% capture info_1 %}
Injected factories are different from factories you use to create objects (via `container.registerFactory`). 
A factory registered via `registerFactory` is simply used to create your instance. 
An injected factory lets the container create the instance but it wraps this creation in a factory and injects the factory. 
It's typically used for lazy resolution of objects or when an object needs to create many other objects but doesn't want to take a dependency on the container itself. 
{% endcapture %}
{% include callout-info.html content=info_1 %}

## Additional Dependencies in Factories
You can pass arguments to the factory and they forwarded as discussed under the [`resolve(..)`](./04-object-resolution.md#resolution-with-additional-dependencies) section.

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
let container = new Container();
container.registerInstance('otherDependencyA', 'look! a string dependency');
container.register('item', Item).inject('otherDependencyA').transient();
container.register('manager', Manager).inject({ resolver: 'factory', key: 'item'});
let manager = container.resolve('manager');
let fooItem = manager.createItem('Foo');
let barItem = manager.createItem('Bar');
```

Output:

```
Hello Bob
Hello Mick
```
