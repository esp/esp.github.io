---
title: State Change Workflow
permalink: /concepts/esp-js/state-change-workflow/
---

When an event is published to the `Router` it dispatches the event to event observers using a staged approach.
That is, you can observe the event at any one of 4 `ObservationStages`.
The `Router` first dispatches the event to observer at `ObservationStage.Preview`, then `ObservationStage.Normal` (the default), if committed `ObservationStage.Committed` and finally `ObservationStage.Final`.

The staged workflow exists to allow you go control the flow/propagation, of events throughout your model.
In edge case scenarios one may want to cancel an event, or first apply it to an entity then let other entities react to this (i.e. commit it).

## Observation Stages

### Preview stage
The Preview stage exists to give an observer a chance to cancel the event.
This is done by calling `eventContext.Cancel()` on the `EventContext` passed to the observer callback.
Other preview stage observers will still receive the event (if any), however it won't be delivered to observers at `ObservationStage.Normal` or `ObservationStage.Committed`.

### Normal stage
The normal stage is where **99% of your processing will take place**.
If you subscribe without a stage the `Router` will default the stage to `ObservationStage.Normal`.

An event can not be cancelled at this stage, however it can be committed.
Committing is done by calling `eventContext.Commit()` on the `EventContext` passed to the observe callback.

### Committed stage
Committed stage observers only receive the event if an observer at  `ObservationStage.Normal` calls `eventContext.Commit()`.
You can only commit an event once.
Committing allows a model entity that owns the event to declare the events state has been applied to the model.
It signals to observer at `ObservationStage.Normal` that event has taken place allowing them to make reactive decisions.
For example, a common use case is when a key piece of high level state changes, all lower entities then need to reset.

### Final stage
Final stage observers only receive the event at the very end, this stage will always run.

## Pre and Post Event Processing
In addition to the `ObservationStages` mentioned above, there is also pre and post event dispatch hooks.

### Pre Event Processing
The pre processing stage happens before the event is dispatched to event observer at any of the `ObservationStages`.
Typically this could be done if you need to do some high level stage changes to the model, for example increment a model version, or clear some transient collections.

### Post Event Processing
In a similar fashion to pre event processing, there is also a post event dispatch hook.
This happens after all events (including any subsequently published by event observers) have been dispatched to observers at the various `ObservationStages`.
An example use case for this is validation, or cross cutting aggregate operations on the model.
You should not expand or contract your model in the post processing stage, it's largely intended for performing validation/aggregations etc.

## Programmatically Interacting with the Workflow

The underlying router API allows you to subscribe for events at the given stage. 
In practice you'll wire up events using decorators. 
The [examples](../../03 - examples/index.md) show how to do this.