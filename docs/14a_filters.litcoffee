# /api/App Components/Batman.View/Batman.View Filters

Batman filters are evaluated from left to right, with the output of each filter being injected into the next. This allows you to form filter chains for display purposes. Accessor caching does not apply to filter chains. If any component of the chain changes, the entire chain will be recalculated for each binding in the template.

Batman.js ships with many built-in view filters:

Type | Filters
---|----
__Logical Operators__ |  `and`, `or`, `not`
__Comparison Operators__ | `equals`, `eq`, `neq`, `lt`, `gt`, `lteq`, `gteq`
__General Utilities__ | `get`, `[]`, `meta`, `default`
__Number Helpers__ | `ceil`, `floor`, `round`, `precision`, `fixed`, `delimitNumber`, `ordinalize`
__Set Helpers__ |  `join`, `sort`, `map`, `has`, `first`, `toSentence`
__String Helpers__ | `interpolate`, `escape`, `capitalize`, `titleize`, `singularize`, `underscore`, `camelize`, `trim`, `raw`, `matches`, `truncate`, `prepend`, `append`, `replace`, `downcase`, `upcase`, `pluralize`, `humanize`
__Event Helpers__ | `withArguments`, `toggle`, `increment`, `decrement`
__Debuggers__ | `log`, `logStack`


## Custom Filters

You can define custom filters by setting them on the `Batman.Filters` object. For example, a batman.js view filter that formats a date with [moment.js](http://momentjs.com):

```coffeescript
# `moment` is the moment.js object
Batman.Filters.dateFormat = (date, format) ->
  moment(date).format(format)
```

You can also define custom filters when defining custom views with [`Batman.View.filter`](docs/api/batman.view.html#class_function_filter).

## equals(left, right) or eq(left, right): Boolean

Checks if left content is equal to right content:

```html
<span data-showif="title | equals 'Batman Views'"></span>
<span data-showif="value | eq 10"></span>
<span data-showif="value | eq true"></span>
```

__Note__: there is actually _one_ difference between `eq` and `equals`: `equals` rejects undefined values, but `eq` allows them.

## lt(left, right) : Boolean

Checks if left content is `less than` the right content.

```html
<span data-showif="posts.length | lt 10"></span>
```

## gt(left, right) : Boolean

Checks if left content is `greater than` the right content.

```html
<span data-showif="posts.length | gt 10"></span>
```

## lteq(left, right) : Boolean

Checks if left content is `less than or equal to` the right content.

```html
<span data-showif="posts.length | lteq 10"></span>
```

## gteq(left, right) : Boolean

Checks if left content is `greater than or equal to` the right content.

```html
<span data-showif="posts.length | gteq 10"></span>
```

## neq(left, right) : Boolean

Checks if left content is `is NOT equal to` the right content.

```html
<span data-showif="posts.length | neq 10"></span>
```

## ceil(value) : string

The `ceil` filter will run `Math.ceil` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | ceil"></span>
```

## floor(value) : string

The `floor` filter will run `Math.floor` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | floor"></span>
```

## round(value) : string

The `round` filter will run `Math.round` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | round"></span>
```

## percision(value, toPlace) : string

The `precision` filter will run `toPrecision()` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | precision"></span>
<span data-bind="someValue | precision 3"></span>
```

## fixed(value, toPlace) : string

The `fixed` filter will run `toFixed()` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | fixed"></span>
<span data-bind="someValue | fixed 3"></span>
```

## delimitNumber(value) : string

The `delimitNumber` filter will comma delimit a 'number'. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | delimitNumber"></span>
```

## raw(value) : string

The `raw` filter renders the unescaped value.

```html
<span data-bind="someHTMLyString | raw"></span>
```

## get(value, key) : value

Calls the get function on the input value with the specified key. Can be used with `Batman.Accessible` and `Batman.TerminalAccessible`:

```html
<span data-bind="accessibleFunction | get 'item'"></span>
```

## value[key] : value

Shorthand for the `get` filter.

## and(inputValue, otherValue) : boolean

Returns `true` if `inputValue` and `otherValue` are truthy:

```html
<p data-showif='post.published | and currentUser.loggedIn'></p>
```

## or(inputValue, otherValue) : boolean

Returns `true` if either `inputValue` or `otherValue` are truthy:

```html
<p data-showif='post.published | or currentUser.isAdmin'></p>
```

## not(value) : boolean

Inverts the truthiness of the input value:

```html
<span data-hideif="title | equals 'Batman Views' | not | and action | equals 'show'"></span>
```

## matches(value, string) : boolean

Tests a string against the input value:

```html
<span data-showif="title | matches 'Bat'"></span>
```

## truncate(value, length, end = '...') : string

Limits the length of output to the specified length and appends the specified text if over the limit:

```html
<span data-bind="page.title | truncate 5, '…'"></span>
```
Would result in:
```html
<span data-bind="page.title | truncate 5, '…'">About…</span>
```

## default(value, defaultValue) : value

Provides a default value if the keypath is falsy:

```html
<input type="text" data-bind="page.title | default 'About Us'"></input>
```

## prepend(value, string) : string

Prepends the string to the input value:

```html
<span data-bind-class="page.tag | prepend 'ico-'"></span>
```
If page.tag is 'about' this would result in:
```html
<span data-bind-class="page.tag | prepend 'ico-'" class="ico-about"></span>
```

## append(value, string) : string

Appends the string to the input value:

```html
<span data-bind-class="page.tag | append '-ico'"></span>
```
If page.tag is 'about' this would result in:
```html
<span data-bind-class="page.tag | append '-ico'" class="about-ico"></span>
```

## replace(value, searchString, replaceString[, flags]) : string

Replaces content in the input value matching the `searchString` with the `replaceString` value:

```html
<span data-bind="page.title | replace 'html', 'HTML'"></span>
```

## downcase(value) : string

Downcases the input value:

```html
<span data-bind="page.title | downcase"></span>
```

## upcase(value) : string

Upcases the input value:

```html
<span data-bind="page.title | upcase"></span>
```

## pluralize(value, count, includeCount[=true]) : string

Pluralizes the input value based on the patterns specified in `Batman.helpers.inflector` and the count provided:

```coffeescript
( ->
  @singular /(analysis)$/i, '$1'
  @singular /(analy)ses$/i, '$1sis'
).call(Batman.helpers.inflector)
```

```html
<span data-bind="'analysis' | pluralize page.comments.count"></span>
```

## singularize(string) : string

Returns the singular inflection of `string`.

## humanize(string) : string

Takes a string and makes it human readable, for example 'an_underscored_string' would become 'An underscored string'.

```html
<span data-bind="'about_us_page' | humanize"></span>
```
Would result in:
```html
<span data-bind="'about_us_page' | humanize">About us page</span>
```

## titleize(value) : string

Humanizes `string` and capitalizes each word. For example,

```html
<span data-bind="'about_us_page' | titleize"></span>
```
Would result in:
```html
<span data-bind="'about_us_page' | titleize">About Us Page</span>
```

## underscore(string) : string

Converts `string` to underscore case.

## camelize(string, firstLetterLower[=false]) : string

Converts `string` to camel case. if `firstLetterLower` is true, the first letter will be lowercase.

## ordinalize(numberOrString) : string

Turns `numberOrString` into an ordinalized number, for example, `4 | ordinalize` becomes `4th`.

## join(array, separator = '') : string

Joins `array` into a single string with `separator`:

```html
<span data-bind="page.comments | map 'title' | join ', '"></span>
```

## toSentence(array) : string

Joins `array` with `, ` and ` and`, as appropriate. See [helpers.toSentence](/docs/api/batman.helpers.html#class_function_tosentence).

## sort(value) : value

Sorts an `array` using the default comparison:

```html
<span data-foreach-comment="page.comments | sort" data-bind="comment.title"><span>
```

## map(iterable) : value

Maps the specified keypath from an `array` of objects:

```html
<span data-foreach-author="page.comments | map 'author'" data-bind="author"><span>
```

## has(iterable, item) : boolean

Calls the `iterable`'s `has` function to check for the existence of the specified `item`.

```coffeescript
class Sample.FirstController extends Batman.Controller
  index: ->
    @set('things', new Batman.Set('thing1', 'thing2'))
```

```html
<input type="checkbox" data-bind-checked="things | has 'thing1'"></input>
```
If you were to dispatch `first#index`:
```html
<input type="checkbox" data-bind-checked="things | has 'thing1'" checked="true"></input>
```

## first(iterable) : value

Returns the first value from an `array`:

```html
<span data-context-firstComment="page.comments | first"></span>
```

## meta(value, keypath) : value

Looks up `keypath` on `value.meta`. The `value` must have a `meta` property to look up against.

## interpolate(string, valuesObject) : string

Allows you to use string interpolation:

```html
<span data-bind="'The page title is %{title}' | interpolate {'title': 'page.title'}"></span>
```

## withArguments(function, curriedArguments...) : function

Ensures that the function is called with the supplied arguments in addition to the arguments it would normally be called with. This is a form of currying. The argument order will be the curried arguments (those passed to withArguments) first, then the regular arguments. In the case of a click event, the regular arguments are node, event, view.

```coffeescript
class Sample.CloseWindowView extends Batman.View
  html: '<span data-event-click="closeWindow | withArguments true"></span>'

  closeWindow: (actuallyClose) ->
    window.close() if actuallyClose
```

```html
<div data-view="CloseWindowView"></div>
```

## escape(value) : string

Escapes HTML in the input value:

```html
<textarea data-bind="page.body_html | escape"></textarea>
```

## toggle(keypath) : function 

Returns a handler for toggling `keypath`. Clicking this button will toggle `showMeMore` between `true` and `false`:

```html
<button data-event-click='showMeMore | toggle'></button>
```

## increment(keypath, change[=1]) : function

Returns a handler that increments `keypath` by `change`. If `keypath` 's value isn't set, it will be treated as 0.

```html
<button data-event-click='totalScore | increment'>Add 1</button>
```

## decrement(keypath, change[=1]) : function

Returns a handler that decrements `keypath` by `change`. If `keypath` 's value isn't set, it will be treated as 0.

```html
<button data-event-click='totalScore | decrement 3'>Subtract 3</button>
```
