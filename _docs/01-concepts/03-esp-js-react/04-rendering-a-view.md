---
title: Rendering a view
permalink: /concepts/esp-js-react/rendering-a-view/
---

`ConnectableComponent` renders a view with the model of one store, and the hooks on this page read the model and publish events from inside the view.

{% capture info_1 %}
`ConnectableComponent` is the lower-level way to show a view.
In an esp-js-ui app, you bind a view to a store with `withView`, and `RegionView` renders a `ConnectableComponent` for it.
See [views](../05-esp-js-ui/05-views.md).
{% endcapture %}
{% include callout-info.html content=info_1 title="If you use esp-js-ui" %}

## `ConnectableComponent`

`ConnectableComponent` subscribes to a store's model and renders your view each time the model changes.
`RegionView` renders one for each view binding. You can also render one yourself.

It takes these props:

- `storeId`: the store to connect to. If you leave it out, it uses the storeId of the enclosing `EspStoreContextProvider`.
- `view`: the component to render.
- `createPublishEventProps`: a function that gets a `publishEvent(eventType, event)` function for the store, and returns props for the view. It runs once for each bus and storeId, so it must not use props that change.
- `mapStoreModelToProps`: a function that gets the model and the props from `createPublishEventProps`, and returns props for the view.
- Any other prop, which is passed on to the view.

The view gets these props:

- `storeId` and `bus`.
- `model`: the store's current model.
- The other props you passed, and the props from `createPublishEventProps`.
- The props from `mapStoreModelToProps`. These come last, so they can replace any of the others, `model` included.

`ConnectableComponent` also wraps the view in an `EspStoreContextProvider`, so the [store hooks](#hooks-for-the-connected-store) work inside it.

```tsx
import { ConnectableComponent } from 'esp-js-react';
import type { TodoModel } from '../stores/todoModel';

type NewTodoProps = {
    text: string;
    onTextChange: (text: string) => void;
    onAdd: () => void;
};

const NewTodo = ({ text, onTextChange, onAdd }: NewTodoProps) => (
    <div>
        <input value={text} onChange={e => onTextChange(e.target.value)} />
        <button onClick={onAdd}>Add</button>
    </div>
);

export const NewTodoContainer = () => (
    <ConnectableComponent
        storeId="todo-store-id"
        view={NewTodo}
        createPublishEventProps={publishEvent => ({
            onTextChange: (text: string) => publishEvent('UpdateNewItemText', { text }),
            onAdd: () => publishEvent('AddTodo', {}),
        })}
        mapStoreModelToProps={(model: TodoModel) => ({
            text: model.newItemText,
        })}
    />
);
```

`NewTodo` gets `text` from the model, and two callbacks that publish to the `todo-store-id` store.
The store is the todo store from [store builder](../01-esp-js/03-store-builder.md#classes-as-models).

### A store that isn't registered yet

If the store isn't registered when `ConnectableComponent` mounts, it renders nothing until the store is registered, then renders the view.

After `bus.removeStore(storeId)`, the view stays on screen with the last model it got.

## Hooks for the connected store

`EspStoreContextProvider` takes two props, `storeId` and `model`, and gives them to the components below it.
`ConnectableComponent` renders one around each view, so these hooks work anywhere inside a view:

- `useGetStoreId()` returns the storeId.
- `useGetStoreModel()` returns the `model` prop of the provider. It doesn't subscribe to the store. Inside a `ConnectableComponent`, it returns the same `model` the view gets.
- `usePublishStoreEvent()` returns a function that publishes to the store. Call it with `(eventType, event)` or with one object `{ eventType, event }`.
- `usePublishStoreEventWithEntityKey()` returns a function that publishes to the store with an entity key. Call it with `(entityKey, eventType, event)` or with one object `{ entityKey, eventType, event }`.

Outside an `EspStoreContextProvider`, each hook returns `null`.

This view, based on the one in the example app, publishes with `usePublishStoreEvent`, so it doesn't need to know its storeId:

```tsx
import { usePublishStoreEvent } from 'esp-js-react';
import type { TodoModel } from '../stores/todoModel';

export const TodoView = ({ model }: { model: TodoModel }) => {
    const publishStoreEvent = usePublishStoreEvent();
    return (
        <div>
            <input
                value={model.newItemText}
                onChange={e => publishStoreEvent('UpdateNewItemText', { text: e.target.value })}
            />
            <button onClick={() => publishStoreEvent('AddTodo', {})}>Add</button>
            <ul>
                {model.items.map((item, i) => <li key={i}>{item.text}</li>)}
            </ul>
        </div>
    );
};
```

## Select part of a model

`useSyncStoreModelWithSelector(selector, options?)` subscribes to a store and returns what `selector` picks from the model.
The component renders again only when the selected value changes.

Build the options with `syncStoreModelWithSelectorOptions()`:

- `setStoreId(storeId)` sets the store. Without it, the hook uses the storeId of the enclosing `EspStoreContextProvider`.
- `setEqualityFn((last, next) => boolean)` sets how the hook compares the last and next selected values. The default is `last === next`.

```tsx
import { syncStoreModelWithSelectorOptions, useSyncStoreModelWithSelector } from 'esp-js-react';
import type { TodoModel } from '../stores/todoModel';

const sameTexts = (last: string[], next: string[]) =>
    last.length === next.length && last.every((text, i) => text === next[i]);

export const TodoTexts = () => {
    const texts = useSyncStoreModelWithSelector(
        (model: TodoModel) => model.items.map(item => item.text),
        syncStoreModelWithSelectorOptions<string[]>()
            .setStoreId('todo-store-id')
            .setEqualityFn(sameTexts)
    );
    return <p>{texts.join(', ')}</p>;
};
```

The selector returns a new array each time the model changes, so with `===` the component would render again on every change. `sameTexts` compares the items instead.

The hook uses the latest selector on each render, so the selector can use the component's props.
If the store isn't registered yet, the hook returns `null` until it is.
