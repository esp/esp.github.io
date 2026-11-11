---
title: Services
permalink: /concepts/esp-js-ui/services/
---

An esp-js-ui app registers its services in [esp-js-di](../04-esp-js-di/01-index.md) containers: one root container for the app, and one child container for each module.

## The app container

Register services that more than one module uses with `AppBuilder.withContainerConfiguration`. They go in the root container, `app.container`.
The app registers its bus in the root container as `'bus'`, so a service can take the bus with `inject('bus')`:

```ts
import type { EventBus } from 'esp-js';

export class NotificationService {
    constructor(private readonly bus: EventBus) {
    }

    notifyAll(text: string): void {
        this.bus.broadcastEvent('Notification', { text });
    }
}
```

```ts
import { AppBuilder } from 'esp-js-ui';
import { NotificationService } from './notificationService';

const app = AppBuilder
    .create('todo-app')
    .withContainerConfiguration(container => {
        container.register('notificationService', NotificationService).inject('bus');
    })
    .build();
```

`broadcastEvent` sends the event to every registered store: see [broadcast an event](../01-esp-js/06-talking-to-other-models.md#broadcast-an-event).

## A module's container

Register a module's own services with `ModuleBuilder.withContainerConfiguration`. They go in the module's container, a child of the root container.
In the module's hooks, resolve them from `moduleContainer`.
The [weather module](./03-modules.md#build-a-module) registers `WeatherService` this way, and passes it to its store.

A module's container also resolves the root container's services, such as `'bus'` and `notificationService`.
Other modules can't resolve its services, and neither can the root container.
For how a child container resolves, see [child containers](../04-esp-js-di/07-child-containers.md).

## Disposal

`app.dispose()` disposes each module's container, then the root container. See [dispose the app](./02-bootstrapping.md#dispose-the-app).
A container calls `dispose()` on the singletons it created that have a `dispose` method.
For which objects a container disposes, see [lifetime management](../04-esp-js-di/06-lifetime-management.md).
