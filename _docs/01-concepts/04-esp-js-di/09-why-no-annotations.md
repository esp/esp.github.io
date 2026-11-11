---
title: Why no annotations?
permalink: /concepts/esp-js-di/why-no-annotations/
---

`esp-js-di` has no decorators: you configure every registration in code, with `register()` and `inject()`.

Many containers use [decorators](https://github.com/wycats/javascript-decorators/blob/caf8f28b665333dc39293d5319fe01f01e3e3c0f/README.md) (annotations in Java, attributes in C#) to put container settings, such as lifetime and dependencies, on the objects.
They help in some cases, but they cause these problems:

- An object and its dependencies are declared together, so the object depends on them.
- It's hard to configure an object for two different uses, unless you decorate it for both, if the container supports that.
- It's hard to see how objects work together at runtime. The configuration is spread over the objects, across the whole codebase. Configuration in one place is easier to understand.
- Most apps need some runtime configuration anyway. You end up with both runtime and decorator configuration, which is confusing.
- It doesn't work for shared code, such as libraries. You don't want some code configured with decorators and the rest at runtime.

{% capture info_1 %}
Decorators could be added on top of the container, but `esp-js-di` doesn't have them.
{% endcapture %}
{% include callout-info.html content=info_1 %}
