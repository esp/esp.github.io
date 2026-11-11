---
title: Regions
permalink: /concepts/esp-js-ui/regions/
---

A region is a named place in the app's shell, where the views bound to that name appear.

## Region names

A region name is a plain string. You don't register it anywhere.
A module names the region in `withView(storeId, Component, region)`, and the shell shows that region with `<RegionView regionName="..." />`.
If no `RegionView` uses a region name, the views bound to it don't appear.

## The shell

The shell is a React component that places the regions.
This is a shorter version of the shell of the [example app](https://github.com/esp/esp-js/tree/master/examples/example-app). The todo module binds its view to `main`, and the weather module to `weather`:

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

Render the shell inside `EspApp`: see [EspApp](../03-esp-js-react/02-esp-app.md).
For what `RegionView` renders, see [RegionView](../03-esp-js-react/03-region-view.md).

## View order

When more than one view is bound to a region, `RegionView` shows them in this order:

1. By module, in the order the app adds the modules with `withModule`.
2. Within a module, in the order of its `withView` calls.

## Bindings are fixed

A module's bindings are fixed when its `build()` runs. Calling `withView` after `build()` throws.
You can't add a view to a region, or remove one, while the app runs.
