---
title: esp-js-react
permalink: /concepts/esp-js-react/
---

The `esp-js-react` package connects React components to the stores on an esp-js `EventBus`.

Its peer dependencies are `esp-js`, `esp-js-ui`, and React 19. It uses `esp-js-ui` for its types only. See [installation](../../02-installation/01-index.md).

## With esp-js-ui

If you build your app with esp-js-ui, each module binds its views to regions with `withView`.

- [`EspApp`](./02-esp-app.md) wraps your React tree and gives it the app's bus and modules.
- [`RegionView`](./03-region-view.md) renders the views bound to one region.

## On its own

Without esp-js-ui, you create the bus and register the stores yourself.

- [`EspEventBusContextProvider`](./02-esp-app.md#espeventbuscontextprovider) gives the bus to the components below it.
- [`ConnectableComponent`](./04-rendering-a-view.md) renders a view with the model of one store, and renders it again each time the model changes.

```tsx
import type { ComponentType } from 'react';
import { createRoot } from 'react-dom/client';
import { EventBus } from 'esp-js';
import { ConnectableComponent, EspEventBusContextProvider, usePublishStoreEvent } from 'esp-js-react';

type CounterModel = { count: number };

const bus = new EventBus();

bus.storeBuilder<CounterModel>('counter', { count: 0 })
    .withEventHandler('Increment', (draft) => {
        draft.count++;
    })
    .build();

const CounterView = ({ model }: { model: CounterModel }) => {
    const publishStoreEvent = usePublishStoreEvent();
    return (
        <button onClick={() => publishStoreEvent('Increment', {})}>
            Count: {model.count}
        </button>
    );
};

createRoot(document.getElementById('root')!).render(
    <EspEventBusContextProvider bus={bus}>
        <ConnectableComponent storeId="counter" view={CounterView as ComponentType} />
    </EspEventBusContextProvider>
);
```

1. The `counter` store is registered before React renders, so `ConnectableComponent` finds it.
2. `ConnectableComponent` passes the store's model to `CounterView` as the `model` prop.
3. A click publishes `Increment` to the `counter` store. The view renders again with the new count.

If TypeScript's `strict` option is on, `view` needs the cast: see [the view prop type](./04-rendering-a-view.md#the-view-prop-type).

## Pages in this section

- [EspApp](./02-esp-app.md): render an esp-js-ui app, and get the bus from React.
- [RegionView](./03-region-view.md): render the views bound to a region.
- [Rendering a view](./04-rendering-a-view.md): connect a view to a store, and the hooks that read and publish.
