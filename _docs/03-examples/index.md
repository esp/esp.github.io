---
title: Examples
permalink: /examples/
---

# Examples

The esp-js repo has one example app, [example-app](https://github.com/esp/esp-js/tree/master/examples/example-app), which uses all four ESP packages.

## What the example app shows

The app has two modules, each with one store and one view.

The `todo` module is a to-do list in the `main` region:

- a store built with `StoreBuilder`, with a class model that uses `immerable`;
- event handlers that call methods on the draft, or change it directly;
- a view that publishes events with `usePublishStoreEvent`.

The `weather` module shows the current weather in the `weather` region:

- a `WeatherService` registered as a singleton in the module's esp-js-di container;
- an async `withInitialisation` that finds your location, then publishes the first events;
- a preview handler that cancels a fetch while one is already running;
- an effect that calls the weather API and publishes the result as a new event;
- an event subscription that refreshes the weather every 60 seconds.

The weather module asks the browser for your location and looks up its name with OpenStreetMap. It gets the weather from the [Open-Meteo](https://open-meteo.com/) API.
If you don't share your location, it shows the weather for Perth, Western Australia.

## Run the example app

Clone the [esp-js repo](https://github.com/esp/esp-js), then run these commands from its root folder:

```
npm run bootstrap
npm run start-sample
```

`npm run start-sample` builds the four packages, which the app loads from the repo.
Then it starts the Vite dev server and prints the URL to open.
