---
title: Overview
permalink: /concepts/overview/
---

ESP consists of several packages which enable a developer to build composite decoupled front ends. 
Developers build views that are packaged into modules and can ultimately be deployed and versioned separably yet come together in a single page.
It's entirely possible to have each ESP module deployed separably and downloaded dynamically at runtime.

> #### Info
> ESP doesn't prescribe bundling tools or versioning strategies, rather it provides a means for developers to build views which can be plugged into an overall application. 
> If you're building a 'micro front end' you can use ESP to modularise your application, and use build tools such as [webpack](https://webpack.js.org/) to bundle the modules separately for download.
{: .notice--info}

## Introduction to the ESP Packages

* **esp-js** - 
  provides an event router, a means by which views can communicate with models can which models can communicate with one another. 
  As the first esp library, it also has some tooling for OO modeling and base utilities. 
* **esp-js-polimer** -
  adds functionality to esp so a developer can build immutable models.
  The pattern effectively adds redux like semantics to esp so the model can be broken into states, handles can be assigned to states, and event streams can be used for side effects.
* **esp-js-react** -
  adds [React](https://reactjs.org/) bits to esp so a view can be wired up to a model via the esp `Router`.
  Also adds support for dynamic view binding, a means for a model's view to be created dynamically. 
* **esp-js-di** -
  add an Inversion of Control (IoC / dependency injection) container to esp. 
  esp-js-di is a standalone package, can be used with or without esp.
* **esp-js-ui** -
  adds composite application functionality to esp.
  This includes modules (which bundle views), regions (which build on the dynamic view binding in esp-js-react), and some common utilities.

## A Note About 'Models'

ESP encourages **model first development**, it's entire purpose was to make model first development deterministic.

Some random facts (or aspirations) about models:

* The term model in the general sense, as used thought out this documentation, could be managed using OO or immutable patterns. 
  What ever way you look at it the state still exists in a model.
* 90% of application code will be in models and 99% of business logic exists in models.
* A model can be thought of a a container for related functionality, you may have a model for a view, a trade grid, managing notification, displaying popups. 
* Views should contain no state, the exception being React component only state: for example, 'currently has input focus'.
  Views render props which ultimately get mapped from the model.
* Generally, a models domain is the view.
  State such as validation, errors, visible panels along with all data are all part of a typical view's model. 
* Backend data typically is handed by services, simple objects that talk downstream and expose an API to the rest of the system.
  Results from backend data is pushed to models for evaluation. 
* In an esp application models are isolated off from other models and communicate via events.
  These are published via the esp `Router`, effectively an event bus.
  This keeps models decoupled.
* One or more views can be associated with an instance of a model and those views rendered when the model changes.

Given you mainly build models, it's important to point out esp supports both OO and immutable variants of models.
Both have their trade offs, however over time there is defiantly a move towards immutable models as there is better support in React. 

## Composite application framework

The below box diagram shows most of the moving parts in a complete ESP application.
  
![](/images/esp-overview.png)

Points of note:

* The entire application has access to a container which can store app wide services/object.
* A higher level shell manages common parts of the application and owns bootstrapping modules based on custom logic.
  How to do this isn't prescribed as often applications have specific requirements here (i.e. login first, then load, load via dynamic `import` statements, load at once etc, load based on entitlements).
* The esp module loader can be used to bootstrap modules. 
  This will follow an orchestrated, asynchronous to load modules into the ui.
  Each module gets is't own container which is a child container of the applications.  
* Modules register themselves with the system which allows other unrelated code to interact with them. 
  For example, the shell could build a menu of views which could be opened.
* When a view is to be created, it's `ViewFactory` is invoked. 
  It decides how to build the view (OO, or immutable, or custom if you want).
  Each view gets a container, it's container is a child of the modules (it can see objects scoped to the module or the application).
  Multiple view instances can be created, these operate independently of each other. 
* Views can add or remove themselves from one or more regions. 