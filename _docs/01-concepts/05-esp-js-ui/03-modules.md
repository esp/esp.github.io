---
title: Modules
permalink: /concepts/esp-js-ui/modules/
---

A module groups the services, stores, and views of one part of an app, and `ModuleBuilder` builds it.

## Build a module

`ModuleBuilder.create(moduleId)` returns a builder. `moduleId` must be a non-empty string.
These methods add to the module:

- `withContainerConfiguration(fn)`: `fn` gets the module's own container and registers the module's services in it. See [services](./04-services.md).
- `withView(storeId, Component, region)`: shows `Component` in `region`, connected to the store `storeId`. See [views](./05-views.md).
- `withInitialisation(fn)`: `fn` gets the [module context](#the-module-context) and runs while the app starts. Register the module's stores here.
- `withStart(fn)`: `fn` gets the module context and runs after every module has initialised.

You can call each of these methods more than once. The functions run in the order you add them.
Write the hooks `async`, as for the app hooks.

`build()` returns the module.
Calling `build()` a second time, or a `with` method after `build()`, throws `ModuleBuilder has already been built`.

This is a shorter version of the weather module of the [example app](https://github.com/esp/esp-js/tree/master/examples/example-app):

```ts
import { ModuleBuilder } from 'esp-js-ui';
import { registerWeatherStore } from './stores/weatherStore';
import { WeatherService } from './services/weatherService';
import { WeatherView } from './views/weatherView';

export const weatherModule = ModuleBuilder
    .create('weather')
    .withContainerConfiguration(container => {
        container.register('weatherService', WeatherService).singleton();
    })
    .withView('weather-store-id', WeatherView, 'weather')
    .withInitialisation(async ({ moduleContainer, eventBus }) => {
        const service = moduleContainer.resolve<WeatherService>('weatherService');
        registerWeatherStore(eventBus, service, 'weather-store-id');
        eventBus.publishEvent('weather-store-id', 'FetchWeather', {});
    })
    .build();
```

`registerWeatherStore` builds the weather store: see [async work through a service](../01-esp-js/04-effects.md#async-work-through-a-service).
Add the module to the app with `withModule`: see [bootstrapping](./02-bootstrapping.md).
For when each hook runs, see [start the app](./02-bootstrapping.md#start-the-app).

## The module context

The `withInitialisation` and `withStart` hooks get a `ModuleContext` with three fields:

- `app`: the app.
- `moduleContainer`: the module's own container, a child of the app's root container.
- `eventBus`: the app's bus, the same as `app.eventBus`.

`moduleContainer` resolves the module's own services and the root container's services, such as `'bus'`.
It can't resolve another module's services, and other modules can't resolve its services.

## Lazy modules

The app can load a module during `start()`, from a function that returns a promise of the module.
See [lazy modules](./02-bootstrapping.md#lazy-modules).

## Slow hooks

`start()` waits for every `withInitialisation` hook, so a slow `await` in one delays `start()` and the first render.
For example, the example app's weather module waits for the browser's location in its `withInitialisation` hook.
To fetch data without delaying `start()`, publish an event and fetch in an effect, as the sample above does with `FetchWeather`.

