## Batman.EventEmitter

`EventEmitter` is a mixin which can be applied to any object to give it the ability to fire events and accept listeners for those events.

### on(key, handler)

Attaches a function `handler` to the event with name `key`. This function will be executed every time the event fires.

    test 'event handlers execute when attached with on', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      ok dynamite.on 'detonate', -> console.log "detonated"

### fire(key, arguments...)

Calls all previously attached handlers on the event with name `key`. All handlers will receive the passed `arguments`.

_Note_: Calling `fire` doesn't guarantee the event will fire since firing can be prevented with `prevent` or `preventAll`.

    test 'event handlers are fired', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', (noise) -> results.push "detonated with noise #{noise}"
      dynamite.fire 'detonate', "BOOM!"
      equal results[0], "detonated with noise BOOM!"

### hasEvent(key) : boolean

Asks if the `EventEmitter` has an event with the given `key`.

    test 'events can be tested for presence', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> log "detonated"
      ok dynamite.hasEvent('detonate')
      equal dynamite.hasEvent('click'), false


### oneShot : boolean

Events can be set to fire only once, and then fire subsequently attached handlers immediately if they are attached after the initial firing. This is useful for events similar to `window.onload` where they really only happen once in the lifespan of the application, but you don't want to check if they have happened already when attaching event handlers.

Access the `Event` object to set the `oneShot` property on them using `EventEmitter::event`.

    test 'one shot events fire handlers attached after they have fired for the first time', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.event('detonate').oneShot = true
      dynamite.fire('detonate')
      dynamite.on 'detonate', -> results.push "detonated immediately!!"
      equal results[0], "detonated immediately!!", "The handler was called as soon as it was attached."

### prevent(key) : EventEmitter

Prevents the event with name `key` from firing, even if `.fire` is called. This is useful if you need to guarantee a precondition has been fulfilled before allowing event handlers to execute. Returns the event emitting object.

Undo event prevention with `allow` or `allowAndFire`.

_Note_: `prevent` can be called more than once to effectively "nest" preventions. `allow` or `allowAndFire` must be called the same number of times or more for events to fire once more.


    test 'events can be prevented', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.prevent('detonate')
      dynamite.on 'detonate', -> results.push "This shouldn't fire"
      dynamite.fire('detonate')
      equal results[0], undefined, "The event handler wasn't fired."

    test 'prevent returns the event emitter', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      equal dynamite, dynamite.prevent('detonate')

### allow(key) : EventEmitter

Allows the event with name `key` to fire once more, after `prevent` had been called previously. `allow` will not fire the event when called, regardless of whether or not the event can now be fired or if an attempt to fire it was made while the event was prevented. Returns the event emitting object.

_Note_: `prevent` can be called more than once to effectively "nest" preventions. `allow` or `allowAndFire` must be called the same number of times or more for events to fire once more.

    test 'events can be allowed after prevention', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.prevent('detonate')
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler wasn't fired."
      dynamite.allow('detonate')
      dynamite.fire('detonate')
      equal results.length, 1, "The event handler was fired."

    test 'events must be allowed the same number of times they have been prevented', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.prevent('detonate')
      dynamite.prevent('detonate')
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler wasn't fired, the prevent count is at 2."
      dynamite.allow('detonate')
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler still wasn't fired, but the prevent count is now at 1."
      dynamite.allow('detonate')
      dynamite.fire('detonate')
      equal results.length, 1, "The event handler was fired."

    test 'allow returns the event emitter', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      equal dynamite, dynamite.allow('detonate')

### allowAndFire(key)

Allows the event with name `key` to fire once more, and tries to fire it. `allowAndFire` may fail to fire the event if `prevent` has been called more times than `allow` or `allowAndFire` have previous.

    test 'events can be allowed and fired after prevention', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.prevent('detonate')
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler wasn't fired."
      dynamite.allowAndFire('detonate')
      equal results.length, 1, "The event handler was fired."

    test 'events must be allowed and fired the same number of times they have been prevented', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.prevent('detonate')
      dynamite.prevent('detonate')
      dynamite.allowAndFire('detonate')
      equal results.length, 0, "The event handler wasn't fired."
      dynamite.allowAndFire('detonate')
      equal results.length, 1, "The event handler was fired."
