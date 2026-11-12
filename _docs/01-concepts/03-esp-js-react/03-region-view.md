---
title: RegionView
permalink: /concepts/esp-js-react/region-view/
---

`RegionView` renders the views that esp-js-ui modules bind to one region.

## Place a region

`RegionView` takes one prop, `regionName`.
It needs an [`EspApp`](./02-esp-app.md) above it, which gives it the app's modules.

This is a shorter version of the shell of the [example app](https://github.com/esp/esp-js/tree/master/examples/example-app), with a `main` region and a `weather` region:

{% raw %}
```tsx
import { RegionView } from 'esp-js-react';

export const AppShell = () => (
    <div style={{ display: 'flex', gap: '24px' }}>
        <div style={{ flex: 1 }}>
            <RegionView regionName="main" />
        </div>
        <div style={{ width: '360px' }}>
            <RegionView regionName="weather" />
        </div>
    </div>
);
```
{% endraw %}

A module binds a view to a region with `withView(storeId, Component, region)`. See [views](../05-esp-js-ui/05-views.md).

## What it renders

For each `withView` binding whose region equals `regionName`, `RegionView` renders a [`ConnectableComponent`](./04-rendering-a-view.md) with the binding's storeId and view.
The views appear in the order described in [regions](../05-esp-js-ui/06-regions.md).

`RegionView` renders nothing if no binding matches `regionName`, or if there is no `EspApp` above it.

Two bindings in a region can use the same storeId. Each shows its own view of that store.
