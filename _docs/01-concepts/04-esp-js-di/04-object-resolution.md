---
title: Object Resolution
permalink: /concepts/esp-js-di/object-resolution/
---

Object resolution is done via :

* `container.resolve(identifier [, additionalDependency1, additionalDependency2, etc. ]);`

  This simply builds the object registered with the given `identifier`. 
  Any dependencies will also be built and injected.
  Optionally provide additional dependencies which will get passed in after any that were specified via `inject()` at registration time.
  
<a name="resolve-groups"></a>  
* `container.resolveGroup(name);`

   Resolving a [group](#resolve-groups) returns an array of objects registered against that group. 
 
<div class="notice--info">
    A call to `resolve` will trigger build up of the object in question. 
    Any [dependencies](#dependencies) the object requires will be resolved and injected.
    
    ### Function constructors
    
    If the type registered is a constructor function (i.e. typeof registeredObject === 'function') it will be initialised accordingly and any [dependencies](#dependencies) passed in.
    {: .notice--info}
    
    ### Prototypical inheritance
    
    If the type registered is not a constructor function it will be assumed a prototype.
    At resolve time new object/s will be created using Object.create(registeredObject).
    If the object has an `init` method then this will be called passing any [dependencies](#dependencies).
</div>

## Example

Below we have 2 simple classes. 
`Parent` takes `Child` as it's dependency. 
`Child` is registered with the identifier 'child' and `Parent` with the identifier 'parent'.
Additionally the parent registration injects the `Child` as a [dependency](#dependencies).

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
var container = new Container();
container.register('child', Child);
container.register('parent', Parent).inject('child');
var parent = container.resolve('parent');
parent.sayHello();
```

Output:

```
$ node readme.js
Hello from the parent
Hello from the child
```

# Resolve groups

You can group objects together at registration time then resolve them using `resolveGroup(name)`.
Typically this is handy when you're objects share a related abstraction.

```javascript
var Foo = {
    name: "theFoo"
};
var Bar = {
    name: "theBar"
};
var container = new Container();
container.register('foo', Foo).inGroup('group1');
container.register('bar', Bar).inGroup('group1');
var group1 = container.resolveGroup('group1');
for (let i = 0, len = group1.length; i < len; i++) {
    console.log(group1[i].name);
}
```

Output:

```
theFoo
theBar
```

### Injecting groups

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
var bazz = container.resolveGroup('bazz');
```

## Resolution with additional dependencies

When calling `resolve` you can optionally pass additional [dependencies](#dependencies).
These will be appended to the dependencies provided to `inject` at registration time (if any).

```javascript
class Foo {
    constructor(fizz, bar, bazz) {
        console.log('%s %s %s', fizz.name, bar.name, bazz.name);
    }
}
var container = new Container();
container.register('fizz', { name: 'fizz'});
container.register('foo', Foo).inject('fizz');
var foo = container.resolve('foo', { name: 'bar'}, { name: 'bazz'});
```

Output

```
fizz bar bazz
```




