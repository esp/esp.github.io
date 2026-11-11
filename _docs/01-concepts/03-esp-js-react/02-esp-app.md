---
title: EspApp
permalink: /concepts/esp-js-react/esp-app/
---

`EspApp` connects an esp-js-ui app to React, and `EspEventBusContextProvider` gives any component the bus.

## Render an app with `EspApp`

`EspApp` takes two props: `app`, the app that `AppBuilder` built, and `children`.
It gives the components below it the app's bus and its modules, so [`RegionView`](./03-region-view.md) and the hooks work.

Render `EspApp` after `await app.start()`.
`EspApp` reads `app.modules` when it renders, and `app.modules` is empty until `start()` loads the modules.
Nothing renders `EspApp` again when `start()` finishes, so if you render it first, its regions stay empty.

This is the entry point of the [example app](https://github.com/esp/esp-js/tree/master/examples/example-app):

```tsx
import { createRoot } from 'react-dom/client';
import { AppBuilder } from 'esp-js-ui';
import { EspApp } from 'esp-js-react';
import { todoModule } from './modules/todo/todoModule';
import { weatherModule } from './modules/weather/weatherModule';
import { AppShell } from './shell/appShell';

const app = AppBuilder
    .create('todo-app')
    .withModule(weatherModule)
    .withModule(todoModule)
    .build();

await app.start();

createRoot(document.getElementById('root')!).render(
    <EspApp app={app}>
        <AppShell />
    </EspApp>
);
```

`AppShell` places the regions: see [RegionView](./03-region-view.md).
For what `start()` does, see [bootstrapping](../05-esp-js-ui/02-bootstrapping.md).

## `EspEventBusContextProvider`

`EspEventBusContextProvider` takes one prop, `bus`, and gives that bus to the components below it.
`EspApp` renders one for you. Without esp-js-ui, render it yourself, as in the [esp-js-react](./01-index.md#on-its-own) sample.

Two hooks read from it:

- `useEventBus()` returns the bus.
- `usePublishEvent()` returns a function that publishes an event to any store.

```tsx
import { usePublishEvent } from 'esp-js-react';

export const AddTodoButton = () => {
    const publishEvent = usePublishEvent();
    return (
        <button onClick={() => publishEvent('todo-store-id', 'AddTodo', {})}>
            Add
        </button>
    );
};
```

The function takes the same arguments as `bus.publishEvent`: a storeId or a store address, the event type, and the event.
It also takes one object: `publishEvent({ address: 'todo-store-id', eventType: 'AddTodo', event: {} })`.
See [event bus](../01-esp-js/02-event-bus.md) for what publishing does.

Outside an `EspEventBusContextProvider`, both hooks return `null`.
To publish to the store a view is connected to, without naming its storeId, use [`usePublishStoreEvent`](./04-rendering-a-view.md#hooks-for-the-connected-store).
