---
title: Object Orientated (OO) Modeling
permalink: /concepts/esp-js/oo-modeling/
---

{% include draftdocs.html %}

You can register an OO model with the ESP router and use it to manage your state. 
ESP will hold that model and invoke it when an event is published to it.
You an use the usual OO patterns model your state.

{% capture warning_1 %}
There are downsides to OO programing in the React world, see the pros and cons below.
{% endcapture %}
{% include callout-warning.html content=warning_1 %}



Draft notes:

* why oo
* registering an model
* observing events 
  * the event delegate 
  * event workflow 
* Pros and Cons of OO