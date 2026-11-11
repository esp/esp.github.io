---
title: Migrating from v8
permalink: /concepts/overview/migrating-from-v8/
---

This page lists what changed between ESP v8 and v9, and shows the v9 code that replaces each removed API.

## What changed

- The `Router` is now the `EventBus`. A model you registered on the router is now a store, registered under a `storeId`.
- `StoreBuilder` replaces the OO models (`ModelBase` and `@observeEvent`) and the `esp-js-polimer` package. Event handlers change an immer draft of the model.
- Effects replace `@eventTransformFor`. No ESP package uses RxJS.
- `esp-js-ui` is rewritten around `AppBuilder` and `ModuleBuilder`. View factories, region models, and state persistence are gone.
- `esp-js-react` needs React 19. `EspApp` and `RegionView` render an `esp-js-ui` app.
- `esp-js-polimer`, `esp-js-rx`, `esp-js-ui-rxcompat`, and `esp-js-metrics` have no v9 release.

## Renames

### esp-js

| v8 | v9 |
|---|---|
| `Router` | `EventBus` |
| `modelId` | `storeId` |
| `router.addModel(modelId, model)` | `bus.storeBuilder(storeId, initialModel)`, then `build()` |
| `router.getModel(modelId)` | `bus.getStoreModel(storeId)` |
| `router.getModelObservable(modelId)` | `bus.getStoreModelObservable(storeId)` |
| `router.findModel(predicate)` | `bus.findStoreModel(predicate)` |
| `router.removeModel(modelId)` | `bus.removeStore(storeId)` |
| `router.isModelRegistered(modelId)` | `bus.isStoreRegistered(storeId)` |
| `router.isModelDispatchStatus(modelId, status)` | `bus.isStoreDispatchStatus(storeId, status)` |
| `ModelAddress`, `DefaultModelAddress` | `StoreAddress`, `DefaultStoreAddress` |
| `eventContext.modelId` | `eventContext.storeId` |

`publishEvent`, `broadcastEvent`, `executeEvent`, `addOnErrorHandler`, `removeOnErrorHandler`, `isOnDispatchLoopFor`, and `currentStatus` keep their names.
For the whole API, see [event bus](../01-esp-js/02-event-bus.md).

### esp-js-react

| v8 | v9 |
|---|---|
| `RouterProvider`, `EspRouterContextProvider` (prop `router`) | `EspEventBusContextProvider` (prop `bus`) |
| `RouterContext`, `useRouter` | `EventBusContext`, `useEventBus` |
| `EspModelContextProvider` | `EspStoreContextProvider` |
| `useGetModel`, `GetModelContext` | `useGetStoreModel`, `GetStoreModelContext` |
| `useGetModelId`, `GetModelIdContext` | `useGetStoreId`, `GetStoreIdContext` |
| `usePublishModelEvent` | `usePublishStoreEvent` |
| `usePublishModelEventWithEntityKey` | `usePublishStoreEventWithEntityKey` |
| `useSyncModelWithSelector`, `syncModelWithSelectorOptions` | `useSyncStoreModelWithSelector`, `syncStoreModelWithSelectorOptions` |
| the options' `setModelId()` | `setStoreId()` |
| `ConnectableComponent` props `modelId` and `mapModelToProps` | `storeId` and `mapStoreModelToProps` |
| the view's props `modelId` and `router` | `storeId` and `bus` |

## Removed APIs

### esp-js

| v8 | v9 |
|---|---|
| `ModelBase`, `@observeEvent`, `@observeEventEnvelope`, `router.observeEventsOn()` | `StoreBuilder`: see [ModelBase and @observeEvent](#modelbase) |
| `router.runAction()` | Publish an event and handle it: see [runAction](#runaction) |
| `router.getEventObservable()`, `router.getAllEventsObservable()` | `withEventHandler`, `withPreviewHandler`, and `withEffect` |
| Observing the committed or final stage | No replacement: see [stages](../01-esp-js/05-state-change-workflow.md#stages) |
| The `EventProcessors` argument of `addModel` | `withPreEventProcessor` and `withPostEventProcessor`: see [event processors](#event-processors) |
| `eventDispatchProcessor`, `eventDispatchedProcessor` | No replacement |
| `router.getAllModelsObservable()` | No replacement. Subscribe to each store with `getStoreModelObservable`. |
| `Observable`, `Subject`, `RouterObservable`, `RouterSubject`, `router.createObservableFor()`, `router.createSubject()` | No replacement. `getStoreModelObservable` returns a `Subscribable`, whose `subscribe` returns a `Disposable`. |
| `router.createModelRouter()`, `SingleModelRouter` | No replacement. Pass the `storeId` to the bus. |
| `Health`, `HealthIndicator`, `router.health()` | No replacement |

### esp-js-polimer

| v8 | v9 |
|---|---|
| `router.modelBuilder()`, `withInitialModel()`, `registerWithRouter()` | `bus.storeBuilder(storeId, initialModel)`, then `build()`: see [polimer models](#polimer) |
| `withStateHandlers(state, handlers)` | `withEventHandler` on the whole model |
| `@eventTransformFor`, `withEventTransforms()` | `withEffect` and `withEventSubscription`: see [@eventTransformFor](#eventtransformfor) |
| `PolimerModel`, `getImmutableModel()` | No wrapper. `getStoreModelObservable` sends the model itself. |
| `withViewBindings()` | `withView` in `esp-js-ui`, or the `view` prop: see [@viewBinding](#viewbinding) |
| `enableReduxDevTools()` | See [Redux DevTools](../01-esp-js/02-event-bus.md#redux-devtools) |
| `withStateHandlerModel()`, `withStateSaveHandler()` | No replacement |

### esp-js-ui

| v8 | v9 |
|---|---|
| `ModuleBase`, `@espModule` | `ModuleBuilder`: see [modules and the app](#modules) |
| `Shell`, `SingleModuleLoader`, `ModuleProvider`, `PrerequisiteRegister` | `AppBuilder`. Put slow setup in a `withInitialisation` hook. |
| `ViewFactoryBase`, `@viewFactory` | `withView`. Each binding shows one view. |
| `RegionManager`, `Region`, `SingleItemRegionView`, `MultiItemRegionView`, `SelectableMultiItemView` | `RegionView` in `esp-js-react`: see [RegionView](../03-esp-js-react/03-region-view.md) |
| The `'router'` container key (`SystemContainerConst.router`) | `'bus'` |
| `ModelBase` | `StoreBuilder` |
| `Logger` and the logging types | Import them from `esp-js`: see [logging](../01-esp-js/07-logging.md) |
| `StateService`, saved view state | No replacement |
| `SchedulerService`, `Decimal`, `DecimalFormat`, the health types | No replacement |

### esp-js-react

| v8 | v9 |
|---|---|
| `@viewBinding`, `ViewBinder`, `createViewForModel`, `DEFAULT_VIEW_KEY`, the `viewContext` prop | `withView`, or the `view` prop of `ConnectableComponent`: see [@viewBinding](#viewbinding) |
| `connect`, `ConnectableComponentFactory` | `ConnectableComponent` with `mapStoreModelToProps` and `createPublishEventProps` |
| The options' `setTryPreSelectPolimerImmutableModel()` | No replacement. The model is a plain object. |

## Behaviour changes

- Publishing an event to a store with no handler for it logs a warning. See [publish an event](../01-esp-js/02-event-bus.md#publish-an-event).
- Models are frozen. Change them only in event handlers, through the draft.
- `esp-js` bundles its own copy of immer, so a Map or Set in a model doesn't work. See [maps and sets](../01-esp-js/03-store-builder.md#maps-and-sets).
- Effects run after the event handlers, each with a snapshot of the model taken right after its own event. See [state change workflow](../01-esp-js/05-state-change-workflow.md#effects).

## Before and after

The v8 samples show the old API, so they don't run against v9.

### ModelBase and @observeEvent {#modelbase}

v8:

```typescript
class CounterModel extends ModelBase {
    count = 0;

    constructor(router: Router) {
        super('counter', router);
        this.observeEvents();
    }

    @observeEvent('Increment')
    private _onIncrement(event: { by: number }) {
        this.count += event.by;
    }
}

const router = new Router();
const model = new CounterModel(router);
router.getModelObservable<CounterModel>('counter').subscribe(m => console.log(m.count));
router.publishEvent('counter', 'Increment', { by: 1 });
```

v9:

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

A preview handler replaces `@observeEvent` with `ObservationStage.preview`. See [store builder](../01-esp-js/03-store-builder.md).

### runAction {#runaction}

v8:

```typescript
router.runAction('settings', (model: SettingsModel) => {
    model.darkMode = true;
});
```

v9:

```typescript
import { EventBus } from 'esp-js';

type SettingsModel = { darkMode: boolean };

const bus = new EventBus();

bus.storeBuilder<SettingsModel>('settings', { darkMode: false })
    .withEventHandler('DarkModeChanged', (draft, event: { darkMode: boolean }) => {
        draft.darkMode = event.darkMode;
    })
    .build();

bus.publishEvent('settings', 'DarkModeChanged', { darkMode: true });

console.log(bus.getStoreModel<SettingsModel>('settings')!.darkMode);
```

### Event processors {#event-processors}

v8:

```typescript
router.addModel('counter', model, {
    preEventProcessor: m => console.log('before:', m.count),
    postEventProcessor: (m, eventsProcessed) => console.log('after:', eventsProcessed),
});
```

v9:

```typescript
import { EventBus } from 'esp-js';

type CounterModel = { count: number };

const bus = new EventBus();

bus.storeBuilder<CounterModel>('counter', { count: 0 })
    .withPreEventProcessor(model => console.log('before:', model.count))
    .withEventHandler('Increment', (draft) => {
        draft.count++;
    })
    .withPostEventProcessor((model, eventsProcessed) => console.log('after:', eventsProcessed))
    .build();

bus.publishEvent('counter', 'Increment', {});
```

The processors run at the start and the end of each round. See [rounds](../01-esp-js/05-state-change-workflow.md#rounds).

### Polimer models {#polimer}

In `esp-js-polimer`, each state handler object changed one part of the model.
In v9, an event handler gets a draft of the whole model.

v8:

```typescript
class InputsStateHandlers {
    @observeEvent('NotionalChanged')
    _onNotionalChanged(draft: InputsState, event: { notional: number }) {
        draft.notional = event.notional;
    }
}

router
    .modelBuilder<TileModel>()
    .withInitialModel(initialModel)
    .withStateHandlers('inputs', new InputsStateHandlers())
    .registerWithRouter();
```

v9:

```typescript
import { EventBus } from 'esp-js';

type TileModel = {
    inputs: { ccyPair: string; notional: number };
    quote: { price: number | null };
};

const bus = new EventBus();

bus.storeBuilder<TileModel>('tile', {
    inputs: { ccyPair: 'EURUSD', notional: 1000 },
    quote: { price: null },
})
    .withEventHandler('NotionalChanged', (draft, event: { notional: number }) => {
        draft.inputs.notional = event.notional;
        draft.quote.price = null;
    })
    .build();

bus.publishEvent('tile', 'NotionalChanged', { notional: 5000 });

console.log(bus.getStoreModel<TileModel>('tile')!.inputs.notional);
```

The v9 model has no `modelId` field: the `storeId` is the first argument of `storeBuilder`.

### @eventTransformFor {#eventtransformfor}

An `@eventTransformFor` method took a stream of events and returned a stream of new events.
In v9, an effect calls a service and publishes the result as a new event.

v8:

```typescript
class QuoteEventTransforms {
    constructor(private _quoteService: QuoteService) {
    }

    @eventTransformFor('RequestQuote')
    onRequestQuote(inputEventStream: InputEventStream<QuoteModel, {}>): OutputEventStream<{ price: number }> {
        return inputEventStream.pipe(
            switchMap(inputEvent => this._quoteService.getPrice(inputEvent.model.ccyPair)),
            map(price => ({ eventType: 'QuoteReceived', event: { price } }))
        );
    }
}
```

v9:

```typescript
import { EventBus } from 'esp-js';

type QuoteModel = { ccyPair: string; isLoading: boolean; price: number | null };

interface QuoteService {
    getPrice(ccyPair: string): Promise<number>;
}

const quoteService: QuoteService = {
    getPrice: async () => 1.08,
};

const bus = new EventBus();

bus.storeBuilder<QuoteModel>('quote', { ccyPair: 'EURUSD', isLoading: false, price: null })
    .withEventHandler('RequestQuote', (draft) => {
        draft.isLoading = true;
    })
    .withEffect('RequestQuote', (model, event, eventContext, publish) => {
        quoteService.getPrice(model.ccyPair)
            .then(price => publish('QuoteReceived', { price }))
            .catch(() => publish('QuoteFailed', {}));
    })
    .withEventHandler('QuoteReceived', (draft, event: { price: number }) => {
        draft.isLoading = false;
        draft.price = event.price;
    })
    .withEventHandler('QuoteFailed', (draft) => {
        draft.isLoading = false;
    })
    .build();

bus.getStoreModelObservable<QuoteModel>('quote')
    .subscribe(model => console.log('isLoading:', model.isLoading, 'price:', model.price));

bus.publishEvent('quote', 'RequestQuote', {});
```

Output:

```
isLoading: false price: null
isLoading: true price: null
isLoading: false price: 1.08
```

For a source of events that isn't a reply to an event, such as a timer or a socket, use `withEventSubscription`. See [effects](../01-esp-js/04-effects.md).

### Modules and the app {#modules}

A v8 module was a class that extended `ModuleBase` and registered view factories.
A v9 module is built with `ModuleBuilder`: it registers its stores in a hook, and binds a view to each store with `withView`.

v8:

```typescript
@espModule('counter-module', 'Counter module')
export class CounterModule extends ModuleBase {
    constructor(container: Container) {
        super(container);
    }

    configureContainer() {
        this.container
            .register('counterViewFactory', CounterViewFactory)
            .inject(EspDiConsts.owningContainer, SystemContainerConst.router)
            .singleton();
    }

    getViewFactories() {
        return [this.container.resolve<CounterViewFactory>('counterViewFactory')];
    }

    registerPrerequisites(register: PrerequisiteRegister) {
    }

    protected get isOnNewStateApi() {
        return true;
    }
}
```

v9:

```tsx
import { createRoot } from 'react-dom/client';
import { AppBuilder, ModuleBuilder } from 'esp-js-ui';
import { EspApp, RegionView, usePublishStoreEvent } from 'esp-js-react';

type CounterModel = { count: number };

const CounterView = ({ model }: { model: CounterModel }) => {
    const publishStoreEvent = usePublishStoreEvent();
    return <button onClick={() => publishStoreEvent('Increment', {})}>Count: {model.count}</button>;
};

const counterModule = ModuleBuilder
    .create('counter-module')
    .withView('counter', CounterView, 'main')
    .withInitialisation(async ({ eventBus }) => {
        eventBus.storeBuilder<CounterModel>('counter', { count: 0 })
            .withEventHandler('Increment', (draft) => {
                draft.count++;
            })
            .build();
    })
    .build();

const app = AppBuilder
    .create('counter-app')
    .withModule(counterModule)
    .build();

await app.start();

createRoot(document.getElementById('root')!).render(
    <EspApp app={app}>
        <RegionView regionName="main" />
    </EspApp>
);
```

See [esp-js-ui](../05-esp-js-ui/01-index.md) and [bootstrapping](../05-esp-js-ui/02-bootstrapping.md).

### @viewBinding {#viewbinding}

In v8, `@viewBinding` put the view on the model class, and `ConnectableComponent` found it there.
In v9, an `esp-js-ui` module binds the view with `withView`, as in the sample above.
Without `esp-js-ui`, pass the view to `ConnectableComponent`.

v8:

```tsx
@viewBinding(CounterView)
class CounterModel extends ModelBase {
    // ...
}

<ConnectableComponent modelId="counter" />
```

v9:

```tsx
import type { ComponentType } from 'react';
import { ConnectableComponent } from 'esp-js-react';

type CounterModel = { count: number };

const CounterView = ({ model }: { model: CounterModel }) => <p>Count: {model.count}</p>;

export const Counter = () => (
    <ConnectableComponent storeId="counter" view={CounterView as ComponentType} />
);
```

For the cast, see [the view prop type](../03-esp-js-react/04-rendering-a-view.md#the-view-prop-type).

### Selector options {#selector-options}

`syncStoreModelWithSelectorOptions()` returns the options object itself. There is no `build()` call.

v8:

```tsx
const count = useSyncModelWithSelector(
    (model: CounterModel) => model.count,
    syncModelWithSelectorOptions<number>()
        .setModelId('counter')
);
```

v9:

```tsx
import { syncStoreModelWithSelectorOptions, useSyncStoreModelWithSelector } from 'esp-js-react';

type CounterModel = { count: number };

export const CountLabel = () => {
    const count = useSyncStoreModelWithSelector(
        (model: CounterModel) => model.count,
        syncStoreModelWithSelectorOptions<number>()
            .setStoreId('counter')
    );
    return <p>Count: {count}</p>;
};
```

See [select part of a model](../03-esp-js-react/04-rendering-a-view.md#select-part-of-a-model).
