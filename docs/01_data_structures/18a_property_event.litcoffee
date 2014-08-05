# /api/Data Structures/Batman.Event/Batman.PropertyEvent

`Batman.PropertyEvent` extends `Batman.Event`.

## ::eachHandler(iterator: Function)

Passes `iterator` to `eachObserver`, where the iterator will be invoked with each observer on the `PropertyEvent`.

## ::handlerContext()

Returns the `PropertyEvent`'s `base`.
