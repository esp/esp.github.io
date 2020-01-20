---
permalink: /
layout: splash
---

# Event State Processor (ESP) Documentation

{% include draftdocs %}

ESP gives you the ability to manage changes to a model in a deterministic event driven manner.
It does this by adding specific processing workflow around changes to a model's state. 
It was born out of the need to manage complex UI and/or server state.

At its core is a `Router` which typically sits between a view and the model.
The view publish events to the model via the `Router`.
The `Router` dispatches the event to the model for state to be changed.
When all events are processed the model is then pushed back to the view so new state can be applied.
It's lightweight, easy to apply and puts the model at the forefront of your design.

Over time additional libraries have been added to ESP to to add support to build very large composite Single Page Apps in React. 
Some high level features include:
* Multiple models - a single `Router` can host multiple dependent or independent models with corresponding views and their own render cycles.
* Different state management patterns - use either object orientated or functional/immutable paradigms. 
* View creation functionality - gives the ability to host multiple instances of the same type of view.
* Dynamic view binding via regions - ability to display a view in a region without that region having a hard reference to the view.
* Application modules - collections of views which can be loaded separately and dynamically.
* View/Module/Object scoping and lifecycle management via dependency injection

> #### How Does ESP Relate to Redux or Flux Architectures? 
> The core ESP pattern was created before Redux or Flux were widely popular, as it turns out it's a very similar pattern. 
> ESP could be thought of as an implementation of the uni directional message flow pattern.
> It's core use case was to build complex real time SPAs with multiple independent views.
> Overtime it's evolved but the core use case has not changed.
> This use case has steered the additional ESP libraries which provide many features for large composite application development.  
{: .notice--info}

## Do you need ESP?

ESP tends to work well if you have these sorts of requirements:

* You're building large composite application, potentially with multiple development teams. 
* You're application needs be multi teared and decoupled - views can be grouped into modules, services can be reused amongst modules/views.
* You building a 'micro front end' Single Page Application application and want to release different parts of it independently. 
* You are dealing with a large amount of state, complex screens with 20-200+ inputs, various workflows or maybe different representations of the same data.
* Your have real time requirements and need reactive modeling APIs to manage complex business logic.

## Where can it be used?

ESP can be used on both client and servers; anywhere you have complex real-time and in-memory state that requires modelling.

Within your application you may have several independent areas that manage complex state, each of these could be candidates for ESP.

*	On the client it can be used to process state for a complex screen or a set of related and complex screens.
*	It can be used to model things to that don't have a screen - log in flows, app bootstraping, notifications.
*	On the server you might use it to model push-based user state and general internal server state. 
    It provides a deterministic method to modify and observe such state.

## Talks

While a bit dated, the below 25min talk on ESP at the [React London Meetup](https://meetup.react.london/) covers core concepts which are still valid today.

{% include video id="Pj-RakjfHDI?start=333" provider="youtube" %}

Slides for the talk are available [here](http://goo.gl/40jie4).

