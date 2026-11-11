---
title: Bootstrapping
permalink: /concepts/esp-js-ui/bootstrapping/
---

`AppBuilder` builds an app from its modules, `start()` starts it, and `dispose()` disposes it.

## Build an app

`AppBuilder.create(appName)` returns a builder. `appName` must be a non-empty string.
These methods add to the app:

- `withContainerConfiguration(fn)`: `fn` gets the root container and registers app services in it. See [services](./04-services.md).
- `withModule(moduleOrFactory)`: adds a module that `ModuleBuilder` built, or a function that returns a promise of one. See [lazy modules](#lazy-modules).
- `withInitialisation(fn)`: `fn` gets the app and runs during `start()`, before the modules initialise.
- `withStart(fn)`: `fn` gets the app and runs at the end of `start()`.

You can call each of these methods more than once. The functions run in the order you add them.
The hooks are typed to return a promise, so write them `async`. `start()` awaits whatever a hook returns.

`build()` returns the app.
Calling `build()` a second time, or a `with` method after `build()`, throws `AppBuilder has already been built`.

## What exists when

- After `build()`, `app.eventBus` and `app.container` exist. `app.modules` is `[]`.
- During `start()`, the app registers its bus in the root container as `'bus'`, and loads the modules into `app.modules`.

Render the app with React after `start()`: see [EspApp](../03-esp-js-react/02-esp-app.md).

## Start the app

`start()` returns a promise. It runs these steps in order:

1. Register the bus as `'bus'` in the root container.
2. Run the app's `withContainerConfiguration` functions.
3. Load the modules. The lazy module functions run in parallel.
4. Give each module its own child container, and run the module's `withContainerConfiguration` functions on it.
5. Run the app's `withInitialisation` hooks, one after the other.
6. Run each module's `withInitialisation` hooks. The modules run in parallel.
7. Run each module's `withStart` hooks. The modules run in parallel.
8. Run the app's `withStart` hooks, one after the other.

Step 7 waits until every module has finished step 6.
This sample logs steps 2 to 8:

```ts
import { AppBuilder, ModuleBuilder } from 'esp-js-ui';
import type { Module } from 'esp-js-ui';

const createModule = (name: string): Module => ModuleBuilder
    .create(name)
    .withContainerConfiguration(() => console.log(`${name}: module container configuration`))
    .withInitialisation(async () => console.log(`${name}: module initialise`))
    .withStart(async () => console.log(`${name}: module start`))
    .build();

const app = AppBuilder
    .create('lifecycle-app')
    .withContainerConfiguration(() => console.log('app: container configuration'))
    .withModule(createModule('todo'))
    .withModule(async () => {
        console.log('weather: lazy module loaded');
        return createModule('weather');
    })
    .withInitialisation(async () => console.log('app: initialise'))
    .withStart(async () => console.log('app: start'))
    .build();

await app.start();
```

Output, without the lines esp-js-ui writes through the esp-js [logger](../01-esp-js/07-logging.md):

```
app: container configuration
weather: lazy module loaded
todo: module container configuration
weather: module container configuration
app: initialise
todo: module initialise
weather: module initialise
todo: module start
weather: module start
app: start
```

## Errors during start

- If a lazy module function rejects, `start()` rejects and `app.modules` stays `[]`.
- If an app `withInitialisation` or `withStart` hook throws, `start()` rejects.
- If a module's `withInitialisation` or `withStart` hook throws, the app logs the error and continues. A module whose `withInitialisation` failed still runs its `withStart` hooks.

## Call `start()` again

- A second call returns at once. It doesn't wait for the first call to finish.
- After a failed start, `start()` resolves and does nothing.
- After `dispose()`, `start()` rejects.

## Lazy modules

Pass `withModule` a function that returns a promise of a module, and `start()` calls it in step 3.
With a dynamic `import()`, the bundler can put the module's code in its own file:

```ts
import { AppBuilder } from 'esp-js-ui';
import { todoModule } from './modules/todo/todoModule';

const app = AppBuilder
    .create('todo-app')
    .withModule(todoModule)
    .withModule(() => import('./modules/weather/weatherModule').then(m => m.weatherModule))
    .build();

await app.start();
console.log(app.modules.map(m => m.moduleId));
```

Output:

```
[ 'todo', 'weather' ]
```

`app.modules` keeps the `withModule` order, whichever module loads first.

## Dispose the app

`app.dispose()` disposes, in this order:

1. The modules, last module first. Each module disposes its child container.
2. The bus, which disposes every store. See [dispose the bus](../01-esp-js/02-event-bus.md#dispose-the-bus).
3. The root container.

`dispose()` catches and logs any error.
You can call it at any time, including before `start()`. A second call does nothing.

If `dispose()` runs while `start()` loads or initialises the modules, `start()` logs a warning, stops, and resolves.
