---
title: esp-js-ui
permalink: /concepts/esp-js-ui/
---

The `esp-js-ui` package builds an app out of modules, and starts them in a fixed order.

## An app with one module

`ModuleBuilder` builds a module: its services, its stores, and the views it shows.
`AppBuilder` builds the app from its modules, and `start()` runs the modules' hooks.

This sample is based on the todo module of the [example app](https://github.com/esp/esp-js/tree/master/examples/example-app):

```ts
import { AppBuilder, ModuleBuilder } from 'esp-js-ui';
import { registerTodoStore } from './modules/todo/stores/todoStore';
import { TodoView } from './modules/todo/views/todoView';

const todoModule = ModuleBuilder
    .create('todo')
    .withView('todo-store-id', TodoView, 'main')
    .withInitialisation(async ({ eventBus }) => {
        registerTodoStore(eventBus, 'todo-store-id');
    })
    .build();

const app = AppBuilder
    .create('todo-app')
    .withModule(todoModule)
    .build();

await app.start();
```

`registerTodoStore` builds the todo store on the app's bus: see [store builder](../01-esp-js/03-store-builder.md).
`withView` shows `TodoView` in the `main` region, connected to that store.
To render the app with React, see [EspApp](../03-esp-js-react/02-esp-app.md).

## Pages in this section

- [Bootstrapping](./02-bootstrapping.md): `AppBuilder`, and what `start()` and `dispose()` do.
- [Modules](./03-modules.md): `ModuleBuilder` and the context its hooks get.
- [Services](./04-services.md): the app container and the module containers.
- [Views](./05-views.md): bind a view to a store with `withView`.
- [Regions](./06-regions.md): where the views appear in the shell.
