---
title: Overview
permalink: /concepts/overview/
---

This page lists the ESP packages, defines a store and a model, and shows how an ESP app fits together.

## The packages

ESP is four packages. They share one version number.

| Package | What it does | Needs |
|---|---|---|
| [`esp-js`](../01-esp-js/01-index.md) | The `EventBus`. You register stores on it, publish events to them, and observe their models. | nothing |
| [`esp-js-di`](../04-esp-js-di/01-index.md) | A dependency injection container. | nothing |
| [`esp-js-ui`](../05-esp-js-ui/01-index.md) | Builds an app out of modules, each with its own container, stores, and views. | `esp-js`, `esp-js-di` |
| [`esp-js-react`](../03-esp-js-react/01-index.md) | React components and hooks that render a store's model. | `esp-js`, `esp-js-ui`, React 19 |

You can use `esp-js` or `esp-js-di` on its own.
For the install commands, see [installation](../../02-installation/01-index.md).

## Stores and models

A **store** is what you register on the bus under a `storeId`.
It holds the event handlers, effects, and other parts that [`StoreBuilder`](../01-esp-js/03-store-builder.md) adds.

A store's **model** is its state: a frozen object that the bus replaces each time the store's handlers change it.
Observers get the new model after the store's events are handled.

## An app

An `esp-js-ui` app has a root container, one or more modules, and a shell that shows the modules' views.

![An esp-js-ui app: the root container holds the bus and the app services; each module has a child container, stores on the bus, and view bindings; RegionViews in the shell show the views](../../images/app-structure.svg){: .align-center}

- The root container holds the `EventBus`, registered as `'bus'`, and the services the whole app uses. See [services](../05-esp-js-ui/04-services.md).
- Each module has a child container. It registers its stores on the bus, and binds a view to each store with `withView`. See [modules](../05-esp-js-ui/03-modules.md) and [views](../05-esp-js-ui/05-views.md).
- The shell is a React component. Its `RegionView` components show the views bound to each region. See [regions](../05-esp-js-ui/06-regions.md).
- `AppBuilder` builds the app, and `start()` runs the modules' hooks in a fixed order. See [bootstrapping](../05-esp-js-ui/02-bootstrapping.md).

If you're moving an app from ESP v8, see [migrating from v8](./02-migrating-from-v8.md).
