---
title: Modeling Approaches
permalink: /concepts/esp-js/modeling-approaches/
---

ESP encourages **model first development**, how you use the `Router` to build a model-first, event based system is the focus of this section.
Here we discuss some concepts worth noting, then go into detail on approaches.

Generally the decisions you face are these:

* How to route events to your model for processing
* How to structure your model
* How your model should react to cross cutting, or wide scoping, events

The following sections go into more details on these points using different approaches.

> ##### Tip
> Note the current recommended guidance is to use the [reactive domain model](reactive-domain-model.md#reactive-model) approach.


## Mutable 

## Immutable 




# Domain model

With the *Domain Model* approach, you structure you model like an aggregate root.
A single `EventProcessor` object observes all events from the router and calls various top level methods on your domain entity.
You top level domain entity handles updating all internal state, from the root of the object graph to the leaf nodes.
This includes interacting with [asynchronous](../advanced-concepts/asynchronous-operations.md) services to fetch or push data, model persistence, model validation etc.
Your domain entity exposes a read-only interface for model observers consumption.

![](../../images/esp-basic-domain-model.png)

This approach is useful for models that don't have very deep object graphs.
It can be come problematic when you have large object graphs that may need to react to common cross cutting events.

# Event Processor Domain Model

With the *Event Processor Domain Model* you have an event processor that's scoped to a particular node or branch of the model.
The event processor contains the logic on how to update that branch of the model.
This includes interacting with [asynchronous](../advanced-concepts/asynchronous-operations.md) services to fetch or push data, model persistence, model validation etc.
Your model is read/write allowing the event processor to make changes.
For many events, the parent object need not be concerned with changes happening to it's children (the parent may have it's own event processor managing it).

Below we see the moving parts.
Note the `Model` never receives the event for the `SubModel`.
While `Model` would hold reference to `SubModel`, updating `SubModel` is the responsibility of the `SubModelEventProcessor`.

![](../../images/esp-basic-event-processor-domain-model.png)

This approach allows you to use the [event workflow](../advanced-concepts/complete-event-workflow.md) to propagate changes throughout you model.
For example, one event processor can receive an event, apply it to the model and call `Commit()` on the `EventsContext` received during event observation.
This allows other event processors, which are not responsible for the particular events state, to react.

The down side to this approach is your model is fully writable from anywhere.
You have to be very diligent so your event processors write only to the part they own.
The learning curve is also harder for new comers as the implicit relationships between the event processors and the model is non obvious.

> ##### Note
> This approach draws parallels with an [anemic domain model pattern](http://www.martinfowler.com/bliki/AnemicDomainModel.html).
> In essence you should never split your business logic for a single model entity into several unrelated types as it becomes hard to understand the implicit relations between these.
> If you do use this approach it's recommended to keep event processors inline with the model, i.e. if you have an `Order` entity, you'd have an `OrderEventProcessor`.
> If you end up with `UpdateOrderEventProcessor`, `ChangeQuantityEventProcessor` etc, you are truly on the way to an anemic modeling approach, it's not recommended.


<a name="reactive-model"></a>

# Reactive Domain Model

The *Reactive Domain Model* merges the previous two approaches.
The model entities take ownership of event observation, they are responsible for all logic related to the given entity.
This includes interacting with [asynchronous](../advanced-concepts/asynchronous-operations.md) services to fetch or push data, model persistence, model validation, business logic etc.
The models public interface is read-only.
If necessary the model entity (i.e. event observers) can propagate events through the model using the [event workflow](../advanced-concepts/complete-event-workflow.md).
This allows entities to react to events in stages and somewhat decouples entities from the root object.

The below diagram shows the moving parts.
Events flow from the publisher, via the `Router` directly to the entity responsible for the given event type.
When all events have been processed the model is then dispatched to observers.
Given the model exposes a read only API, observers can interrogate it but not change it.

![](../../images/esp-basic-reactive-model.png)

Not every model entity observes events.
The very leaf node entities (which may be collections, or simple model types) would still be manipulated by their parent.
For example, the below class diagram shows a model with 3 entities: `ChatScreenModel`, `FriendList` and `InputField`.
Some properties on the entities are themselves complex entities (e.g. the `SearchInput` which is an `InputField`).
The 2 main entities, `ChatScreenModel` and `FriendList` would observe events on the `Router` and update their state, `FriendList` would update state of `SearchInput`.
Their children would expose a sensible API to ensure their state is safely updated by the parent (i.e. they are not just read/write).
Which entities take the `Router` is really up to you.
A general rule is start off with 1-2 main entities then break them down as you identify self contained state and associated business logic.

![](../../images/esp-reactive-model-class-diagram.png)

> ##### Note
> It's worth noting the [event observation signature](../router-api/event-pub-sub.md#event-observation-signature).
> When the model dispatches an event to observers, one the parameters passed by the `Router` is the model root.
> This means any entity in the hierarchy has access to root model (which as discussed above should be designed as read only) for reference.
> Be diligent using the root model, if you find yourself relying on this, or end up using the train wreak pattern (for.bar.baz.value.foo.final.value) to get access to other nodes of the model, it's likely you have a modeling deficiency elsewhere.

## Source code examples
There are [examples](../examples/index.md) checked into both .Net and JS implementations using this approach, specifically:

* [ESP agile board](../examples/index.md#espaagileboard)
* [JS React chat app (port from flux)](../examples/index.md#fbchat)