# Using This Reference

The API Reference contains specific documentation for individual components of
the framework. You may also find tests included, which serve as
an example for correct usage as well as an assertion that the API has not
changed.

## How to Read API Entries

Entries for __functions__ take the form:

```coffeescript
 "#{classOrPrototype}#{name}(#{arguments}) : #{returnType}"
```

- `arguments` may include the _type_ or _default value_ for each argument
- `returnType` may be omitted if it is unpredictable or irrelevant

Entries for __properties__ take the form:

```coffeescript
 "#{classOrPrototype}#{name}[=#{defaultValue}] : #{returnType}"
```

- `defaultValue` may be omitted if there isn't one
- `returnType` may be omitted if it is unpredictable or irrelevant


### Class Properties

If the entry is preceded with `@`, it is defined on the _class_. This means you should call (or `get`) it on the class. For example, `Model.find` is a class function:

```coffeescript
Model.find 1, (err, record) -> # ...
```

And `Model.loaded` is a class accessor:

```coffeescript
Model.get('loaded')
```

Also, class properties are defined in class definitions with `@`. For example, to define `Model.resourceName` and call `Model.persist`:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @resourceName: "my_model"
  @persist(Batman.RestStorage)
```

### Prototype Properties

If an entry is _not_ preceded with `@`, it is defined on the _prototype_. This means you should call (or `get`) it on instances of that class. For example, `View::lookupKeypath` is a prototype function:

```coffeescript
myView = new Batman.View(myOptions)
myView.lookupKeypath("myRecord.name")
```

Similarly, `View::node` is a prototype accessor:

```coffeescript
myView = new Batman.View
myView.get('node')
```

Prototype properties can be defined in class definitions. For example, to override the `View::viewDidAppear` hook:

```coffeescript
class MyApp.MyView extends Batman.View
  viewDidAppear: ->
    alert("Welcome to my great app!")
```

