---
title: Event bus
permalink: /concepts/esp-js/event-bus/
---

The `EventBus` holds your stores, processes the events you publish to them, and sends each new model to the store's observers.

## Create a bus

```typescript
import { EventBus } from 'esp-js';

const bus = new EventBus();
```

An app usually has one bus.
You register stores on it with `bus.storeBuilder()`: see [store builder](./03-store-builder.md).

## Publish an event

`publishEvent(storeIdOrAddress, eventType, event)` sends an event to one store.

- The first argument is a `storeId`, a `new DefaultStoreAddress(storeId, entityKey)`, or a plain `{ storeId, entityKey }` object. Handlers read the `entityKey` from the event context.
- The event can't be `null` or `undefined`. Use `{}` for an event with no data.
- If the store has no event handler, preview handler, or effect for the event type, the bus logs a warning and drops the event.
- If the store isn't registered, `publishEvent` throws. If you call it from a handler or an effect, that error also [halts the bus](#errors-and-halting).

```typescript
import { EventBus, DefaultStoreAddress } from 'esp-js';

type OrdersModel = { canceledOrderIds: string[] };

const bus = new EventBus();

bus.storeBuilder<OrdersModel>('orders', { canceledOrderIds: [] })
    .withEventHandler('CancelOrder', (draft, event, eventContext) => {
        draft.canceledOrderIds.push(eventContext.entityKey);
    })
    .build();

bus.publishEvent(new DefaultStoreAddress('orders', 'order-1'), 'CancelOrder', {});
bus.publishEvent({ storeId: 'orders', entityKey: 'order-2' }, 'CancelOrder', {});
bus.publishEvent('orders', 'ShipOrder', {});

console.log(bus.getStoreModel<OrdersModel>('orders').canceledOrderIds);
```

Output (the timestamp varies):

```
[20261112][09:49:56.098][W][EventBus] Event [ShipOrder] published to store [orders] was dropped: the store has no handlers for this event type
[ 'order-1', 'order-2' ]
```

`broadcastEvent(eventType, event)` sends an event to every registered store: see [talking to other stores](./06-talking-to-other-models.md#broadcast-an-event).

## Execute an event

`executeEvent(eventType, event)` runs an event on the current store straight away, instead of queueing it.

- You can call it only from a pre or post event processor or an event handler. It throws if you call it from an effect, a model observer, or outside a dispatch.
- The handlers of the executed event can't publish events.

```typescript
import { EventBus } from 'esp-js';

type CartModel = { items: string[]; total: number };

const bus = new EventBus();

bus.storeBuilder<CartModel>('cart', { items: [], total: 0 })
    .withEventHandler('AddItem', (draft, event: { name: string }) => {
        draft.items.push(event.name);
        bus.executeEvent('UpdateTotal', {});
        console.log('total after executeEvent:', draft.total);
    })
    .withEventHandler('UpdateTotal', (draft) => {
        draft.total = draft.items.length * 10;
    })
    .build();

bus.publishEvent('cart', 'AddItem', { name: 'book' });
```

Output:

```
total after executeEvent: 10
```

## Event context

Every handler and effect gets an `EventContext` with these members:

| Member | What it is |
|---|---|
| `storeId` | The store the event was sent to. |
| `eventType` | The event type. |
| `entityKey` | The `entityKey` the event was published with, or `undefined`. |
| `currentStage` | The current `ObservationStage`. |
| `isCanceled` | Whether `cancel()` was called. |
| `cancel()` | Cancels the event. Call it from a preview handler. |

Calling `cancel()` twice on the same event throws.
The [state change workflow](./05-state-change-workflow.md#stages) page explains the stages.

## Read a model

- `getStoreModelObservable(storeId)` returns an object with a `subscribe(onNext, onCompleted?)` method, which returns a `Disposable`.
  - It sends you the current model as soon as you subscribe.
  - You can subscribe before the store is registered. You get the first model when the store is built.
  - It can send the same model object again, for example after a canceled event. Compare models by reference to skip work.
- `getStoreModel(storeId)` returns the current model. It returns `null` for an unknown store, and throws for a store that is observed but not yet registered.
- `findStoreModel(predicate)` returns the first model that matches, or `null`.
- `isStoreRegistered(storeId)` returns `true` if the store is registered.

Models are frozen. To change one, publish an event to its store.

```typescript
import { EventBus } from 'esp-js';

type CounterModel = { count: number };

const bus = new EventBus();

// You can subscribe before the store is registered
bus.getStoreModelObservable<CounterModel>('counter').subscribe(
    model => console.log('model:', model.count),
    () => console.log('completed'),
);

bus.storeBuilder<CounterModel>('counter', { count: 0 })
    .withEventHandler('Increment', (draft) => {
        draft.count++;
    })
    .build();

bus.publishEvent('counter', 'Increment', {});

console.log(bus.getStoreModel<CounterModel>('counter').count);
console.log(bus.findStoreModel((model: CounterModel) => model.count > 0));
console.log(bus.isStoreRegistered('counter'));
console.log(bus.getStoreModel('unknown'));

bus.removeStore('counter');
console.log(bus.isStoreRegistered('counter'));
```

Output:

```
model: 0
model: 1
1
{ count: 1 }
true
null
completed
false
```

## Remove a store

`removeStore(storeId)` removes the store, disposes its event subscriptions, and completes its observers.
If you register a store with the same `storeId` again, subscribe again to get its models.

## Event queues {#event-queues}

Each store has its own event queue.
An event published while the bus is processing goes to the back of its store's queue, so a handler only deals with the current event and the current model.
The [state change workflow](./05-state-change-workflow.md) page lists the steps the bus takes for each queue.

## Dispatch loop {#dispatch-loop}

Publishing an event starts the dispatch loop.
The loop processes one store's queue, sends that store's update, then moves to the next store with queued events, until every queue is empty.
These members tell you where the loop is:

- `currentStatus`: the current `Status` value, for example `idle` or `halted`.
- `isStoreDispatchStatus(storeId, status)`: `true` if the loop is processing that store with that status.
- `isOnDispatchLoopFor(storeId)`: `true` if the loop is processing that store.

## Errors and halting

If a handler, effect, processor, or observer throws, the bus halts.
The bus logs the error and calls the handlers added with `addOnErrorHandler(handler)`, but only for the first error that halts it. Then it throws the error to the code that published the event.

After a halt:

- `publishEvent`, `broadcastEvent`, `executeEvent`, `build()`, and `subscribe` throw.
- `getStoreModel`, `findStoreModel`, `isStoreRegistered`, `removeStore`, and `dispose` still work.
- The store whose handler threw keeps its last good model. The bus discards the changes from the round that failed.

```typescript
import { EventBus } from 'esp-js';

type CounterModel = { count: number };

const bus = new EventBus();

bus.addOnErrorHandler(error => console.log('error handler:', error.message));

bus.storeBuilder<CounterModel>('counter', { count: 0 })
    .withEventHandler('Increment', (draft) => {
        draft.count++;
    })
    .withEventHandler('Fail', () => {
        throw new Error('Something broke');
    })
    .build();

try {
    bus.publishEvent('counter', 'Fail', {});
} catch (error) {
    console.log('caught:', (error as Error).message);
}

try {
    bus.publishEvent('counter', 'Increment', {});
} catch (error) {
    console.log('caught:', (error as Error).message);
}

console.log(bus.isStoreRegistered('counter'));
```

Output, after the bus's own error log:

```
error handler: Something broke
caught: Something broke
caught: ESP event bus halted due to previous unhandled error [Error: Something broke]
true
```

The bus doesn't catch a rejected promise in an effect: see [errors in effects](./04-effects.md#errors-in-effects).

## Dispose the bus

`bus.dispose()` disposes every store and its event subscriptions, and completes the observers.
Calling it twice is safe. After `dispose()`, `publishEvent` throws `ESP event bus has been disposed`.

## Redux DevTools

The bus can send its events and models to the [Redux DevTools](https://github.com/reduxjs/redux-devtools) browser extension.
Install the extension, then add `?espReduxDevToolsEnabled` to the page URL and load the page.
The bus only sends data: it ignores actions you dispatch from the extension.
