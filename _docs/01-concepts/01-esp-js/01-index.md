---
title: ESP-JS
permalink: /concepts/esp-js/
---

The main export in the esp-js package is the `Router`.
This object effectively has a 1 responsibility - to deterministically manage how state changes are applied to the model.
It's API allows for:

* **event publishing** 
* **event delivery**
* **model observation**   

It doesn't know about React, OO models or immutable models, it just knows how to take an event and apply it to a handler you register for that model. 

In reality the various bits provide means you don't directly observe a model, or directly wire up a handler to have state changed.
It's useful to know that a simple event bus is a play under the coves.
It is however, common to publish events directly to a model so you can changes it's state.
{: .notice--success} 

The [api example](https://github.com/esp/esp-js/tree/master/examples/esp-js-api) show these lower APIs at work.