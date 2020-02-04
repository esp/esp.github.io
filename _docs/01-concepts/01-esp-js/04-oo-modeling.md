---
title: Object Orientated (OO) Modeling
permalink: /concepts/esp-js/oo-modeling/
author_profile: true
---

{% include draftdocs.html %}

You can register an OO model with the ESP router and use it to manage state. 
ESP will hold that model and invoke it when an event is published to it.
You can use standard OO patterns and abstractions to manage your state.

The below TypeScript snippet shows how to do this. 

<p class="codepen" data-height="990" data-theme-id="dark" data-default-tab="js" data-user="KeithWoods" data-slug-hash="JjoQNJq" style="height: 990px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="esp-docs-oo-example">
  <span>See the Pen <a href="https://codepen.io/KeithWoods/pen/JjoQNJq">
  esp-docs-oo-example</a> by Keith (<a href="https://codepen.io/KeithWoods">@KeithWoods</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>
<br />

Some points to note:
* An application can have many models.
* An application can have multiple instances of the same model, as long as the model IDs are different.
  This is handy for applications that have multiple instances of similar views open at the same time, for example trade blotters or order entry screens.
* Models can use the `@observeEvent` decorator to wire up their functions to the router.
* Any changes to the model should be via an event published to the `Router`.
* The `Router` doesn't care that your model is OO.
  Such models can be added alongside existing models in your system.  

## Asynchronous Operations with OO Models 

Draft Doc Notes:
* G-Slide showing async operations
* Discuss Gateways vs Run Action

## To OO or Not to OO
There are some downsides to OO programing in the React world.

The main issue is React is optimised to work with immutable state. 
Specifically, logic used to determine if the virtual DOM should be refreshed, is based on object instance equality check.
JavaScript doesn't have the ability to override the the equality operator (`===`), so it's much easier to just check if instance are the same.  

OO models are inherently mutable.
This means their instance never changes. 
View logic need to work harder to determine if the component should re-render.
In effect that logic needs to inspect leaf nodes of the state and check if the values of those have changed.  
If you use OO models, VDOM that's connected to that particular model will always re-render unless you implement custom 'should component update' logic.
Sometimes this is fine, sometimes it's not. 

On the flip side, immutable models require more plumbing to ensure any change results in a new instance. 
Typically with that pattern the root entity doesn't change, however states that hang off the root do get replaced anytime they are mutated. 
Functions to mutate the state don't typically live on the object holding the state. 
Typically you build code to help you implement this pattern. 
This is effectively what [esp-js-polimer](../02-esp-js-polimer/01-index.md) does. 

{% capture success_1 %}
In reality you 'connect' a model to a given part of your VDOM.
If that model keeps re-rendering it only affects the part of the VDOM that it's connected to, not the entire application.

ESP supports multiple models and they all function independently and connect to the VDOM separately.

That said, the general preference would be to create immutable models using [esp-js-polimer](../02-esp-js-polimer/01-index.md).
{% endcapture %}
{% include callout-success.html content=success_1 title="Is this really that bad?" %}