# batman.js API Documentation

The API documentation is the primary reference for batman.js. It contains a
listing and description of public functionality, along with tests to serve as
usage examples.

The current version is readable [here](http://batmanjs.org/docs/api/).

## Heading Format

Second-level headings (i.e. `##` in markdown) must follow a certain format to
allow for parsing metadata. If the heading is intended to document a function,
property, or accessor, it should follow this specification:

```
## XYname(args)[= default] : type
```

- `X` is `@` for a class-level member, and `::` for a prototype-level member
- `Y` is `.` for a property, `%` for a batman accessor, and empty for a function
- `name` is the name of the member
- `(args)` is used for functions only, and is a comma separated list of arguments
  - e.g. `## ::remove(index, offset)`
- `[= default]` is optional, and documents the default value of a property
  - e.g. `## ::.disabled[= false]`
- ` : type` is optional, and documents the return type if a function/accessor, or the type if a property
  - e.g. `## ::add(x) : number`


For documenting method signatures, follow these guidelines:

- Add the expected type of arguments separated by a colon if they're not obvious
  - e.g. `## @filter(filter : string)`
  - e.g. `## ::filter(filter : [string|Function|RegExp])`
- When documenting multiple accepted signatures, use the square-brackety way:
  - e.g. `## ::forEach(iterator : Function[, context: Object])`
  - e.g. `## @encode(keys...[, encoder : [Object|Function]])`
  - e.g. `## @beforeAction([options : [string|Object], ]filter : [string|Function])`
  - If the signatures are different enough, use a third level heading (###) within the description, with a bit more description of why it exists


Example:

```coffee
class X extends Batman.Object
  @someClassProperty: false

  @classAccessor 'classAccess', -> @someClassProperty
  @accessor 'instanceAccess', -> @someInstanceString

  method: (a, b) ->
    @someInstanceString = a
    @someInstanceFunction = b if b
    @someInstanceBoolean

```

```markdown
# X

## Regular second-level headings are still OK

## @.someProperty : boolean

You'll set this in the class declaration and access it by `X.someProperty`.

## @%classAccess : boolean

This is a class accessor. It will be defined in the class declaration and accessed by `X.get("classAccess")`.

## ::%instanceAccess : String

This is also defined in the class declaration, but will be accessed from an instance of the class, like:
```coffeescript
new_x = new X
new_x.get('instanceAccess')
```

## ::method(a : String[, b : Function]) : boolean

This is an instance method. It's defined in the class declaration and called on the instance directly, like:

```coffeescript
new_x = new X
new_x.method(
  "some string",
  (arg) -> (console.log("some function", arg))
)
```

If you're (rightfully) confused, look to the existing API docs for further examples.

The parsing code is [here](https://github.com/batmanjs/batmanjs.github.io/blob/master/bin/generate_docs#L22-L45) if you'd like to take a look.

