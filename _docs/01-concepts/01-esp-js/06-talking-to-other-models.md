---
title: Talking to other stores
permalink: /concepts/esp-js/talking-to-other-models/
---

A store changes another store by publishing an event to it, either to one store by its `storeId` or to every store with `broadcastEvent`.

## Publish to another store

To publish to another store, call `bus.publishEvent` with that store's `storeId`.
The `publish` function an effect gets only sends events to its own store, so use the bus.
Capture the bus in a closure, as below, or resolve it from a [container](../04-esp-js-di/01-index.md).

Give a store that other stores talk to a well-known `storeId`, and export it as a constant.
The events that store handles are its API.

```typescript
import { EventBus } from 'esp-js';

export const NOTIFICATIONS_STORE_ID = 'notifications';

type NotificationsModel = { messages: string[] };
type TodoModel = { items: string[] };

const bus = new EventBus();

bus.storeBuilder<NotificationsModel>(NOTIFICATIONS_STORE_ID, { messages: [] })
    .withEventHandler('AddNotification', (draft, event: { message: string }) => {
        draft.messages.push(event.message);
    })
    .withEventHandler('Reset', (draft) => {
        draft.messages = [];
    })
    .build();

bus.storeBuilder<TodoModel>('todo', { items: [] })
    .withEventHandler('AddTodo', (draft, event: { text: string }) => {
        draft.items.push(event.text);
    })
    .withEffect('AddTodo', (model, event: { text: string }) => {
        bus.publishEvent(NOTIFICATIONS_STORE_ID, 'AddNotification', { message: `Added ${event.text}` });
    })
    .withEventHandler('Reset', (draft) => {
        draft.items = [];
    })
    .build();

bus.publishEvent('todo', 'AddTodo', { text: 'Buy milk' });
console.log(bus.getStoreModel<NotificationsModel>(NOTIFICATIONS_STORE_ID).messages);

bus.broadcastEvent('Reset', {});
console.log(bus.getStoreModel<NotificationsModel>(NOTIFICATIONS_STORE_ID).messages, bus.getStoreModel<TodoModel>('todo').items);
```

Output:

```
[ 'Added Buy milk' ]
[] []
```

## Broadcast an event

`broadcastEvent(eventType, event)` sends the event to every registered store.
A store with no event handler, preview handler, or effect for the event type doesn't get it, and the bus logs no warning.
In the sample above, `Reset` clears both stores.

{% capture warning_1 %}
Don't change another store's model directly. Models are frozen, so the change throws. Publish an event to that store instead.
{% endcapture %}
{% include callout-warning.html content=warning_1 title="Publish an event, don't change the model" %}
