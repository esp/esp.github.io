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

<p class="codepen" data-height="664" data-theme-id="dark" data-default-tab="js,result" data-user="KeithWoods" data-slug-hash="JjoQNJq" style="height: 664px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="esp-docs-oo-example">
  <span>See the Pen <a href="https://codepen.io/KeithWoods/pen/JjoQNJq">
  esp-docs-oo-example</a> by Keith (<a href="https://codepen.io/KeithWoods">@KeithWoods</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

Draft notes:

* why oo
* registering an model
* observing events 
  * the event delegate 
  * event workflow 
* Pros and Cons of OO