---
title: ESP-JS
permalink: /concepts/esp-js/
---

The main export in the esp-js package is the `Router`.
This object effectively has a one responsibility - to deterministically manage how state changes are applied to the model.
It's API allows for:

* **event publishing** - provides a means to publish a event (aka a JS object) to change a models state.
* **event delivery** - provides the ability to subscribe to events and apply event state to the model.
* **model observation**  - provides the ability to be notified when a model changes. 

The `Router` doesn't know about React, OO models or immutable models, it just knows how to take an event and apply it to a handler you register for that model. 

{% capture info_1 %}
In reality the various bits in esp packages provide means you don't directly observe a model, or directly wire up a handler to have state changed.
It's useful to know that a simple event bus is a play under the coves.
It is however, common to publish events directly to a model so you can changes it's state.

The [api example](https://github.com/esp/esp-js/tree/master/examples/esp-js-api) show these lower APIs at work.
{% endcapture %}
{% include callout-info.html content=info_1 %}

