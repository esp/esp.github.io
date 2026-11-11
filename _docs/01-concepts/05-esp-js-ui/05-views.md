---
title: Views
permalink: /concepts/esp-js-ui/views/
---

A module binds a React component to a store with `withView`, and the app shows that view in a region.

## Bind a view to a store

`withView(storeId, Component, region)` takes three arguments:

- `storeId`: the store the view shows.
- `Component`: the React component that renders the model.
- `region`: the name of the region to show the view in. See [regions](./06-regions.md).

Build the store under the same storeId in the module's `withInitialisation` hook.
This is the todo module from the [example app](https://github.com/esp/esp-js/tree/master/examples/example-app):

```ts
import { ModuleBuilder } from 'esp-js-ui';
import { registerTodoStore } from './stores/todoStore';
import { TodoView } from './views/todoView';

export const todoModule = ModuleBuilder
    .create('todo')
    .withView('todo-store-id', TodoView, 'main')
    .withInitialisation(async ({ eventBus }) => {
        registerTodoStore(eventBus, 'todo-store-id');
    })
    .build();
```

`withInitialisation` runs during `start()`, so the store exists before the app renders.
If no store is registered under the storeId when the view mounts, the view renders nothing: see [register the store before the view mounts](../03-esp-js-react/04-rendering-a-view.md#register-the-store-before-the-view-mounts).

## What the view gets

The view gets the store's model as its `model` prop, and renders again each time the model changes.
For every prop the view gets, and the hooks it can use, see [rendering a view](../03-esp-js-react/04-rendering-a-view.md).

## One binding, one view

Each `withView` call shows one view, connected to one store.
To show the same component for two stores, call `withView` twice, with a different storeId each time.
