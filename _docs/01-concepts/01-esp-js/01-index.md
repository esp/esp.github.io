---
title: esp-js
permalink: /concepts/esp-js/
---

The `esp-js` package holds the `EventBus`: you register stores on it, publish events to them, and observe the models they produce.

## A counter

```typescript
import { EventBus } from 'esp-js';

type CounterModel = { count: number };

const bus = new EventBus();

bus.storeBuilder<CounterModel>('counter', { count: 0 })
    .withEventHandler('Increment', (draft, event: { by: number }) => {
        draft.count += event.by;
    })
    .build();

bus.getStoreModelObservable<CounterModel>('counter')
    .subscribe(model => console.log(model.count));

bus.publishEvent('counter', 'Increment', { by: 1 });
```

Output:

```
0
1
```

1. `storeBuilder` registers a store with the `storeId` `'counter'` and the initial model `{ count: 0 }`.
2. `withEventHandler` adds a handler that changes the model when an `Increment` event arrives.
3. `subscribe` prints `0` straight away, because the observable sends the current model to each new observer.
4. `publishEvent` sends `Increment` to the store. The handler runs, and the observer prints the new model, `1`.

## Pages in this section

- [Event bus](./02-event-bus.md): publish events, read models, and handle errors.
- [Store builder](./03-store-builder.md): register a store and its handlers.
- [Effects](./04-effects.md): do async work and talk to services.
- [State change workflow](./05-state-change-workflow.md): the order in which the bus runs handlers, effects, and observers.
- [Talking to other stores](./06-talking-to-other-models.md): publish events from one store to another.
- [Logging](./07-logging.md): the logger, levels, and sinks.
