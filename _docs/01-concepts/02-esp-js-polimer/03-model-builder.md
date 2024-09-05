---
title: Model Builder
permalink: /concepts/esp-js-polimer/model-builder/
---

{% include draftdocs.html %}


{% comment %}
table docs at: https://idratherbewriting.com/documentation-theme-jekyll/mydoc_tables.html
{% endcomment %}

<table>
    <tbody>
    <tr>
        <td>

        </td>
        <td markdown="span">
             **For non-Map type states**
        </td>
        <td markdown="span" >
            **For Map type states**
        </td>
        <td>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td>
        </td>
        <td>
            <p>Registered without `entityKey`</p>
        </td>
        <td>
            <p>Registered with `entityKey`</p>
        </td>
    </tr>
    <tr>
        <td>
            <p>Publishing without `entityKey`</p>
        </td>
        <td>
            <p><strong>State Handlers</strong></p>

            <p>Default esp-js-polimer behaviour, any state handler will receive the event.</p>

            <p><strong>Event Transforms</strong></p>

            <p>
                Default esp-js-polimer behaviour.
                Event transforms receive the entire model as `InputEvent.model`,
                `InputEvent.state` and `InputEvent.entity` will be `undefined`.
            </p>

        </td>
        <td>
            <p><strong>State Handlers</strong></p>
            <p>
                Default ESP Polimer behaviour.
                In this case the state will receive the map as their draft.
            </p>
            <p><strong>Event Transforms</strong></p>
            <p>Default esp-js-polimer behaviour.</p>
        </td>
        <td>
            <p><strong>State Handlers</strong></p>

            <p>The registered state handler will receive the entity from the Map as its draft.</p>

            <p><strong>Event Transforms</strong></p>

            <p>
                The registered event transform will receive the entire model as `InputEvent.model`, the state in
                question as `InputEvent.state` and the entity in question as `InputEvent.entity`.
            </p>

            <p>
                This differs from the box on the left such that a more generic event (for example &lsquo;reset&rsquo;)
                can be sent to a more entity specific handler.
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <p>Publishing with an `entityKey`</p>
        </td>
        <td>
            <p><strong>State Handlers</strong></p>

            <p>
                As above with the addition of the `entityKey` being on the `EventEnvelope`.
                You can use this new key as you need to help identify sub areas of your model.
            </p>

            <p><strong>Event Transforms</strong></p>

            <p>As above.</p>
        </td>
        <td>
            <p><strong>State Handlers</strong></p>

            <p>State handlers will receive the entity from the Map as its draft.</p>

            <p><strong>Event Transforms</strong></p>

            <p>Default esp-js-polimer behaviour.</p>
        </td>
        <td>
            <p><strong>State Handlers</strong></p>

            <p>State handlers will receive the entity from the Map as it's draft.</p>

            <p>Only the specific instance of the state handler registered for the `entityKey` will be invoked. </p>

            <p><strong>Event Transforms</strong></p>

            <p>
                Event transforms receive the entire model as `InputEvent.model`, the state in question as
                `InputEvent.state` and the entity in question as `InputEvent.entity`.
            </p>

            <p>Only the specific instance of the event transform registered for the `entityKey` will be invoked.</p>

        </td>
    </tr>
    <tr>
        <td>
            <p>When To use?</p>
        </td>
        <td>
            <p>Default scenarios, 95% of the time.</p>

            <p>
                Your event streams and handlers can process any events and have not specific edge cases for certain
                graphs of your model / store.
            </p>
        </td>
        <td>
            <p>
                When you want more granular state handlers. That is state handlers that receive and operate on sub
                entities of your store&rsquo;s state, specifically, entities in your states map.
            </p>
        </td>
        <td>
            <p>
                When you have highly specialised state handlers and event transforms, and you only want specific
                instances of these invoked for specific entities in your states map.
                Perhaps your handlers or event transforms take specific strategies or backing reference data.
            </p>

            <p>
                When you want more granular control on how handlers and even transforms are registered. It may be
                confusing with large dynamic models to register everything up front. This pattern allows you to register
                / deregister handlers and transforms as your model grows and contracts.
            </p>

            <p>
                For example, you may have a store with a Map type state called &ldquo;products&rdquo;.
                Each of those products may be different. As such, you register different sets of state handlers and
                event streams per product instance in your stores map. Some of the handlers, while common in nature, may
                take strategies or backing data that is specific to the product in question. This allows for very
                specific APIs that don&rsquo;t interfere with each other and only receive very targeted events, for
                specific entities.
            </p>
        </td>
    </tr>
    </tbody>
</table>