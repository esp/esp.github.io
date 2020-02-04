---
title: Talking to Other Models
permalink: /concepts/esp-js/talking-to-other-models/
---
Typically in a application models are fairly isolated, however sometimes they may need to communicate with one another.
In this case one model can simply publish an event to the other.
To do this the sender needs to know the model ID of the receiver.

For example, a model that displays a list of trades may need to show a notification when a trade is modified. 
You could solve this by having an application wide notification model, other models could publish notifications to it.
The notifications model's API is effectively the events it observes.    
Given it's a piece of application infrastructure, the notification models ID would be well known and could be referenced statically, i.e. imported as a const or resolved from a [container](../04-esp-js-di/01-index.md).

{% capture warning_1 %}
If you obtained a reference directly to another model, and you just modified it on the fly (without publishing an event to it).
ESP's Router would not know that it has changed and therefore would not be able to run it's state change workflow and ultimately notify observers of the change. 
{% endcapture %}
{% include callout-warning.html content=warning_1 title="Why Not Just Take a Reference on the Other Model" %}