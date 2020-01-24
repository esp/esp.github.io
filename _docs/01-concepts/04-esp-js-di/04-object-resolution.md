---
title: Object Resolution
permalink: /concepts/esp-js-di/object-resolution/
---

Object resolution is done via :

* `container.resolve(identifier [, additionalDependency1, additionalDependency2, etc. ]);`
  This builds the object registered with the given `identifier`. 
  Any dependencies will also be built and injected.
  Optionally provide additional dependencies which will get passed in after any that were specified via `inject()` at registration time.
  
* `container.resolveGroup(name);`
   Resolving a group returns an array of objects registered against that group name. 
   More below on this.
 
{% capture info_1 %}
Resolution will trigger build up of the object in question. 
Any dependencies the object requires will be resolved and injected.

### Function Constructors / Classes
If the type registered is a constructor function (i.e. typeof registeredObject === 'function') or class it will be initialised accordingly and any dependencies passed in.

### Prototypical Inheritance

If the type registered is not a constructor function it will be assumed a prototype.
At resolve time new object/s will be created using `Object.create(registeredObject)`.
If the object has an `init()` method then this will be called passing any dependencies registered.
{% endcapture %}
{% include callout-info.html content=info_1 title="How does the resolution work?" %}

## Example

Below we have 2 simple classes. 
`Parent` takes `Child` as it's dependency. 
`Child` is registered with the identifier `child` and `Parent` with the identifier `parent`.
Additionally the parent registration injects the `Child` as a dependency.

``` javascript
class Child {
    sayHello() {
        console.log('Hello from the child');
    }
}
class Parent {
    constructor(child) {
        this._child = child;
    }
    sayHello() {
        console.log('Hello from the parent');
        this._child.sayHello();
    }
}
let container = new Container();
container.register('child', Child);
container.register('parent', Parent).inject('child');
let parent = container.resolve('parent');
parent.sayHello();
```

Output:

```
$ node readme.js
Hello from the parent
Hello from the child
```

<a name="resolve-groups"></a>  
# Resolve Groups

You can group objects together at registration time then resolve them using `resolveGroup(name)`.
Typically this is handy when you're objects share a related abstraction.

```javascript
let Foo = {
    name: "theFoo"
};
let Bar = {
    name: "theBar"
};
let container = new Container();
container.register('foo', Foo).inGroup('group1');
container.register('bar', Bar).inGroup('group1');
let group1 = container.resolveGroup('group1');
for (let i = 0, len = group1.length; i < len; i++) {
    console.log(group1[i].name);
}
```

Output:

```
theFoo
theBar
```

### Injecting Groups

If you want to inject a group simply register the injection using the `groupName`.
From example, if you wanted to inject all dependencies in group `group1`, from our example above, you'd do this:

```javascript
class Bazz {
    constructor(group1) {
        // group1 would be an array with dependencies 'foo' and 'bar'
        this._group1 = group1;
    }
};
container.register('bazz', Bazz).inject('group1');
let bazz = container.resolveGroup('bazz');
```

<a name="resolution-with-additional-dependencies"></a>  
## Resolution with Additional Dependencies

When calling `resolve` you can optionally pass additional dependencies.
These will be appended to the dependencies provided to `inject` at registration time (if any).

```javascript
class Foo {
    constructor(fizz, bar, bazz) {
        console.log('%s %s %s', fizz.name, bar.name, bazz.name);
    }
}
let container = new Container();
container.register('fizz', { name: 'fizz'});
container.register('foo', Foo).inject('fizz');
let foo = container.resolve('foo', { name: 'bar'}, { name: 'bazz'});
```

Output

```
fizz bar bazz
```





