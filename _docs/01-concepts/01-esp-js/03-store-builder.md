---
title: Store builder
permalink: /concepts/esp-js/store-builder/
---

A store holds a model and the handlers that change it, and you create one with `bus.storeBuilder()`.

## Stores and models

`bus.storeBuilder<TModel>(storeId, initialModel)` returns a `StoreBuilder`.
You add handlers to it, then call `build()` to register the store on the bus.

- The `storeId` must be unique on the bus. Calling `build()` for a `storeId` that is already registered throws `The store with id [todo] is already registered`.
- The model is the store's state. The bus deep-freezes the initial model in place, so the object you pass can't be changed after `build()`. Every later model is frozen too.
- `build()` sends the initial model to observers.

To change a model, publish an event to its store.
The bus runs the store's handlers for that event, makes the new model, and sends it to the observers.

## Event handlers

`withEventHandler(eventType, handler)` adds a handler that changes the model.
The handler gets a draft of the model, the event, and the [event context](./02-event-bus.md#event-context).
Change the draft as if it were a normal object: the bus uses [immer](https://immerjs.github.io/immer/) to turn your changes into a new frozen model.

You can add more than one handler for the same event type. They run in the order you add them.

```typescript
import { EventBus } from 'esp-js';

type TodoItem = { text: string; completed: boolean };
type TodoModel = { items: TodoItem[]; newItemText: string };

const bus = new EventBus();

bus.storeBuilder<TodoModel>('todo', { items: [], newItemText: '' })
    .withEventHandler('UpdateNewItemText', (draft, event: { text: string }) => {
        draft.newItemText = event.text;
    })
    .withPreviewHandler('AddTodo', (model, event, eventContext) => {
        if (model.newItemText.trim() === '') {
            eventContext.cancel();
        }
    })
    .withEventHandler('AddTodo', (draft) => {
        draft.items.push({ text: draft.newItemText, completed: false });
    })
    .withEventHandler('AddTodo', (draft) => {
        draft.newItemText = '';
    })
    .withPostEventProcessor((model, eventsProcessed) => {
        console.log('processed:', eventsProcessed);
    })
    .build();

bus.publishEvent('todo', 'AddTodo', {});
bus.publishEvent('todo', 'UpdateNewItemText', { text: 'Buy milk' });
bus.publishEvent('todo', 'AddTodo', {});

console.log(bus.getStoreModel<TodoModel>('todo'));
```

Output:

```
processed: [ 'AddTodo' ]
processed: [ 'UpdateNewItemText' ]
processed: [ 'AddTodo' ]
{ items: [ { text: 'Buy milk', completed: false } ], newItemText: '' }
```

The first `AddTodo` adds nothing: the preview handler cancels it because the text is empty.

## Preview handlers

`withPreviewHandler(eventType, handler)` adds a handler that runs before the event handlers.
It gets the model, the event, and the event context.
If it calls `eventContext.cancel()`, the event handlers and effects for that event don't run. Other preview handlers for the event still run.

## Pre and post event processors

`withPreEventProcessor(processor)` runs at the start of each [round](./05-state-change-workflow.md#rounds), before the round's events.
`withPostEventProcessor(processor)` runs at the end of the round. It also gets the event types the round processed, including canceled events.
Both get the same draft as the event handlers, typed as `Readonly<TModel>`.
A store has one of each: calling the method again replaces the processor.

## Effects and event subscriptions

`withEffect` and `withEventSubscription` add code that runs outside the model change, such as network calls and timers.
See [effects](./04-effects.md).

## Classes as models

A model can be a plain object or a class.
For a class, add `[immerable] = true` so immer can make a draft of it. Methods on the class can then change the draft.
`immerable` comes from the `immer` package, which you install yourself.

```typescript
import { immerable } from 'immer';

export type TodoItem = { text: string; completed: boolean };

export class TodoModel {
    [immerable] = true;

    items: TodoItem[] = [];
    newItemText: string = '';

    addTodo(): void {
        const text = this.newItemText.trim();
        if (!text) {
            return;
        }
        this.items.push({ text, completed: false });
        this.newItemText = '';
    }
}
```

```typescript
import type { EventBus } from 'esp-js';
import { TodoModel } from './todoModel';

export const registerTodoStore = (bus: EventBus, storeId: string): void => {
    bus.storeBuilder<TodoModel>(storeId, new TodoModel())
        .withEventHandler('UpdateNewItemText', (draft, event: { text: string }) => {
            draft.newItemText = event.text;
        })
        .withEventHandler('AddTodo', (draft) => {
            draft.addTodo();
        })
        .build();
};
```

## Maps and sets

A model can hold a `Map` or a `Set`.
esp-js turns on immer's `Map` and `Set` support, so an event handler changes them on the draft like any other value.
You don't call `enableMapSet()` yourself.

## Test a store in Node

A store needs no view, so you can test it with a bus, some events, and `getStoreModel`.
This test uses [Vitest](https://vitest.dev/) and the `registerTodoStore` function above.

```typescript
import { describe, it, expect } from 'vitest';
import { EventBus } from 'esp-js';
import type { TodoModel } from './todoModel';
import { registerTodoStore } from './todoStore';

describe('todo store', () => {
    it('adds the new item text as a todo', () => {
        const bus = new EventBus();
        registerTodoStore(bus, 'todo');

        bus.publishEvent('todo', 'UpdateNewItemText', { text: 'Buy milk' });
        bus.publishEvent('todo', 'AddTodo', {});

        const model = bus.getStoreModel<TodoModel>('todo');
        expect(model.items).toEqual([{ text: 'Buy milk', completed: false }]);
        expect(model.newItemText).toBe('');
    });
});
```
