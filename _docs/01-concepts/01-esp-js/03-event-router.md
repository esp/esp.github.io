---
title: Event Router
permalink: /concepts/esp-js/event-router/
classes: wide
---

The event router is the heart of an esp application. 
There is typically 1 instance of the router and it's used by all models.

It easy to create.

```typescript
import { Router } from 'esp-js';
const router = new Router();
```

All models in an application are registered with the `Router`.

```typescript
const myModel = {};
router.addModel('myModelId', myModel);
```

Handlers can be wire up to the `Router`.

```typescript
router
    .getEventObservable('myModelId', 'someEvent')
    .subscribe(({model, context} = envelope)=> {
        // modify/replace model state by handling the 'someEvent'
    });
```

Events can be published to the model.

```typescript
router.publishEvent('myModelId', 'someEvent', { data: 'some-data' });
```

Observers can observe the model:

```typescript
router
    .getModelObservable('myModelId')
    .subscribe(model => {
       // map to props and re-render
    });
```

> #### Note
> In practice you tend not to directly interact with the `Router.getModelObservable(...)` and `Router.getEventObservable(...)` APIs, framework code will do that for you.
> You can the `@observeEvent(observeAtStage)` decorator to wire up functions or OO objects to the router via `Router.getEventObservable(...)`.
> The `RouterProvider` and `ConnectableComponent` (or `connect` function) in esp-js-react can wire a view up via `Router.getEventObservable(...)`.
> The [examples](../../03 - examples/index.md) show how to do this.
{: .notice--success}

The `Router` needs to manage how the above interactions happen deterministically. 
Given any handler or observer registered with the `Router` could itself publish events or observe other models, the `Router` needs an internal event queue and processing loop. 
This loop is called the Dispatch Loop. 

## Dispatch Loop

The dispatch loop exists to make event processing deterministic.
All code that changes model state **must** run within the dispatch loop for that model otherwise ESP won't know the object has changed.

The dispatch loop kicks off once an event is published to the `Router` via `Router.PublishEvent(...)` or an action is run via `Router.RunAction(...)`.
Any time control flow leaves the router, for example to an event or model observation callback, it's possible that further events could be raised.
Such events go onto a backing queue for their respective model.
The dispatch loop continues until all events for all models are processed.

<a name="event-queues"></a>

### Event Queues

Each model added to the router has its own event queue.
Every time a call to `Router.PublishEvent(...)` occurs the event is placed on the queue for the model in question.
Subsequent events could be raised anytime during the dispatch loop, such events get placed on the back of the model's event queue.
This means events published during the dispatch loop are are not processed immediately, they're processed in turn.
This allows the router to finish dealing with the current event, and allows event observers to assume the model state is fit for the event currently being processed.
Event observers need not be concerned with what is in the backing queue, only with the current event and the current state, this makes execution deterministic, you're only dealing with state change one event at a time.
When the current model's event queue is empty, the router will check the queues for other models and continue until all are empty.

### Model Updates
The `Router` pushes the model updates to observers from within the dispatch loop.
If any model observer publishes an event it will go onto the event queue for the model in question.
Again, the dispatch loop continues until all events are processed.

> #### Tip
> The specific workflow the `Router` does on the dispatch loop is called the [state change workflow](./02 - state-change-workflow.md).
{: .notice--success}

## Reactive API

Both `router.getEventObservable()` and `router.getModelObservable()` return an observable object.
This is modeled on [RxJs's](https://github.com/Reactive-Extensions/RxJS) observable API but with only a few observable methods included, additionally `onError` semantics are not applicable.

> #### Why not use Rx? <a name="reactive-api-why-not-rx"></a>
>
> The push based model of Rx is ideal for pub/sub scenarios where state needs to be combined from many differing streams.
> However the full Rx API isn't suitable as introduction of asynchronicity and other methods that would result in state being held in observable streams would break the deterministic staged workflow that the `Router` owns.
> For example, a deferred model change by way of an asynchronous operation would happen outside of the [state change workflow](./02 - state-change-workflow.md).
> Then there is no guarantee the model would be still in a state suitable once the deferred event arrives.
> Similarly, relational operators combine event streams and store state in observable objects/closures, when a final result yields the underlying model may not be in a state suitable for the target result.
{: .notice--success}