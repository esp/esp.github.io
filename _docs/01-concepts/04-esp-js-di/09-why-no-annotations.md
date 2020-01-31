---
title: Why No Annotation?
permalink: /concepts/esp-js-di/why-no-annotations/
---

Often container implementation use [decorators](https://github.com/wycats/javascript-decorators/blob/caf8f28b665333dc39293d5319fe01f01e3e3c0f/README.md) (annotations in Java and attributes in C#) to decorate objects with IoC related concerns. 
For example lifetime management, scoping, dependency information etc.
They are useful in some instances however often an anti-pattern for the following reasons:
* Objects become dependent on their dependencies as they are explicitly declared together.
* It becomes difficult to configure an object for differing usages unless you decorate it for both, if supported.
* It becomes difficult to gain an understanding of how objects play together at runtime.
  Runtime configuration is scattered on objects in different code files and across the entire codebase.
  Runtime configuration of objects is simpler to understand when it's in a single place.
* 90% of the time you'll find you need some runtime configuration. 
  You end up in a place where you have both runtime and declarative (i.e. decorator) configuration.
  This adds confusion.
* It doesn't work when creating shared code, i.e. in libraries. 
  If you hit this you don't want some code using annotation and some using run time configuration (i.e. the above point).

{% capture info_1 %}
That said, they can be usually added as a bolt on.
The features hasn't got to the top of the list.
{% endcapture %}
{% include callout-info.html content=info_1 %}