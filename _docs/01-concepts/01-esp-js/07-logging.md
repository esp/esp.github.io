---
title: Logging
permalink: /concepts/esp-js/logging/
---

esp-js has a small logger that writes to the console, and you can change its level and send its output to your own sinks.

## Create a logger

`Logger.create(name, config?)` returns a logger with that name.
The config can set `level` and `dumpAdditionalDetailsToConsole`.
`Logger.create` reads the config only the first time you create a logger with that name.

A logger has the methods `verbose`, `debug`, `info`, `warn`, and `error`.

- The message is the first argument. An optional markers object can come before it.
- The console shows markers and extra arguments only when `dumpAdditionalDetailsToConsole` is on.
- `error(message, err)` always shows the error and the markers.

```typescript
import { Logger, Level } from 'esp-js';

const log = Logger.create('TodoStore');

log.debug('Store registered');
log.info({ storeId: 'todo' }, 'Item added');
log.verbose('Not shown: the default level is debug');
log.error('Save failed', new Error('Network down'));

const detailedLog = Logger.create('WeatherStore', { level: Level.verbose, dumpAdditionalDetailsToConsole: true });
detailedLog.verbose('Weather received', { temperatureCelsius: 21 });
```

Output (the timestamps and the stack trace vary):

```
[20261112][09:55:05.007][D][TodoStore] Store registered
[20261112][09:55:05.009][I][TodoStore] Item added
[20261112][09:55:05.009][E][TodoStore] Save failed Error: Network down
    at ...
[20261112][09:55:05.010][V][WeatherStore] Weather received { temperatureCelsius: 21 }
```

Each line shows the date, the time, the first letter of the level, and the logger name.

## Levels

`Level` has the values `verbose`, `debug`, `info`, `warn`, `error`, and `none`.
A logger writes a message only if the message's level is at or above the logger's level.
The default level is `debug`.

## Configure logging

`LoggingConfig` sets the level and the sinks for every logger.

- `LoggingConfig.setLevel(level)` sets the level for every logger that has no level of its own.
- `LoggingConfig.getLoggerConfig(name).level = level` sets the level for one logger.
- `LoggingConfig.addSinks(...sinks)` adds sinks. Every log message goes to every sink.
- `LoggingConfig.clearSinks()` removes all sinks, including the console sink.
- `LoggingConfig.captureConsoleLogs()` sends calls to `console.log`, `console.info`, `console.warn`, and `console.error` through the sinks too, under the logger name `Console`.

In a browser, `window._esp.LoggingConfig` is `LoggingConfig`, so you can change the level from the browser console.

## Write a sink

A sink is an object with a `log(logEvent)` method.
The `LogEvent` has the `logger` name, the `level`, the `message` array (its first item is the text), the `markers`, the `error`, and a `timestamp`.

This sample sets the level to `warn`, gives `TodoStore` its own level, and adds a sink that collects warnings and errors.

```typescript
import { Logger, LoggingConfig, Level } from 'esp-js';
import type { LogEvent, Sink } from 'esp-js';

const log = Logger.create('TodoStore');

LoggingConfig.setLevel(Level.warn);
log.info('Not shown: the level is now warn');

LoggingConfig.getLoggerConfig('TodoStore').level = Level.debug;
log.info('Shown: this logger has its own level');

const problems: string[] = [];
const problemSink: Sink = {
    log(logEvent: LogEvent) {
        if (logEvent.level === Level.warn || logEvent.level === Level.error) {
            problems.push(`${logEvent.logger}: ${logEvent.message[0]}`);
        }
    },
};
LoggingConfig.addSinks(problemSink);

log.warn('Item text is empty');
console.log(problems);
```

Output:

```
[20261112][09:55:05.052][I][TodoStore] Shown: this logger has its own level
[20261112][09:55:05.054][W][TodoStore] Item text is empty
[ 'TodoStore: Item text is empty' ]
```
