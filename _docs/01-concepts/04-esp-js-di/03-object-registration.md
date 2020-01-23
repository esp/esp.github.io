---
title: Object Registration 
permalink: /concepts/esp-js-di/object-registration/
---

JavaScript doesn't have a type system which makes containers a little cumbersome to use. 
Typically in typed languages you'd utilise information provided by the type system to aid in dependency resolution and injection.
However without such a system all is not lost, we can simply use strings (i.e. '**identifiers**') to identify objects to construct.
{: .notice--info} 

You can register an object using one of three methods:

* `container.register(identifier, Item)`.

  This registers either a constructor function OR an object prototype `Item` using the given string `identifier`.

  You can chain calls to alter the registration settings:
  
  ```javascript
    var identifier = 'itemKey1';
    container
        .register('identifier', Item)
        .inject('otherDependencyIdentifier1', 'otherDependencyIdentifier1')
        .singletonPerContainer()
        .inGroup('mySimilarObjects');
  ```

  Here we register `Item` using the string `identifier`. 
  We state that it requires dependencies `otherDependencyIdentifier1` and `otherDependencyIdentifier1`. 
  It's [lifetime management](./06-lifetime-management.md) is `singletonPerContainer`.
  It can be resolved using the `identifier` or as part of the [group](#resolve-groups) `mySimilarObjects`. 
  
* `container.registerInstance(identifier, objectInstance)`.

  You can use `registerInstance` to register an existing instance with the given string `identifier`.
    
* `container.registerFactory(identifier, factory)`.

  This registers a creation factory using the given string `identifier`. 
  The factory is a function that must return a new object instance. 
  The factory will receive the current container as a first parameter.
  Any additional arguments passed during the `resolve` call will be passed to the factory.
  
  ```javascript
    container
        .registerFactory('fooId', (container, ...additionalDependencies) => {
              let fooDependency = container.resolve('fooDependencyId');  
              return new Foo(fooDependency, ...additionalDependencies);
        })
        .transient();
    
    let foo = container.resolve('fooId', 1, 2, 3);
  ```
  
  Here we register a factory that will resolve a `Foo`. 
  We then resolve an instance (`foo`) passing some additional arguments. 
  Our creation factory resolves an additional dependency, then passes this dependency, plus the additional dependencies `1, 2, 3` to `Foo`s constructor and returns it.
  It's registered using a transient scope so each time you resolve it, the factor will be invoked to resolve a new `Foo` instance. 
  
  
We need to manually specify objects dependencies at registration time. 
This is because there are no means available to inspect arguments required for `constructors` or `init` methods at object instantiation/initialisation time.
We specify dependencies via `inject`
{: .notice--info} 