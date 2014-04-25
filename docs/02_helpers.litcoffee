# Batman.helpers

`Batman.helpers` is a namespace for Batman's helpful string manipulation helpers.

_Note_: Batman's pluralization functions mirror those of Rails' exactly.

## @ordinalize(value : [number|string]) : string

`ordinalize` converts a given integer into an ordinal string for describing position in a list, like 1st, 2nd, or 20th.

    test 'ordinalize converts numbers to their ordinal form', ->
      equal Batman.helpers.ordinalize(1), "1st"
      equal Batman.helpers.ordinalize("2"), "2nd"
      equal Batman.helpers.ordinalize(1002), "1002nd"
      equal Batman.helpers.ordinalize("1003"), "1003rd"
      equal Batman.helpers.ordinalize(-11), "-11th"
      equal Batman.helpers.ordinalize(-1021), "-1021st"

## @singularize(pluralString : string) : string

`singularize` converts the plural form of a word to a singular form.

    test 'singularize converts plural words to singular words', ->
      equal Batman.helpers.singularize("posts"), "post"
      equal Batman.helpers.singularize("octopi"), "octopus"
      equal Batman.helpers.singularize("sheep"), "sheep"
      equal Batman.helpers.singularize("word"), "word"
      equal Batman.helpers.singularize("CamelOctopi"), "CamelOctopus"

## @pluralize(singularString : string) : string

`pluralize` converts the singular form of a word to the plural form.

    test 'pluralize converts plural words to singular words', ->
      equal Batman.helpers.pluralize("post"), "posts"
      equal Batman.helpers.pluralize("octopus"), "octopi"
      equal Batman.helpers.pluralize("sheep"), "sheep"
      equal Batman.helpers.pluralize("words"), "words"
      equal Batman.helpers.pluralize("CamelOctopus"), "CamelOctopi"

## @camelize(name [, lowercaseFirstLetter = false]) : string

`camelize` converts the passed `name` to UpperCamelCase. If the second argument is passed as `true`, then lowerCamelCase is returned.

    test 'camelize returns the CamelCase version of an under_scored word', ->
      equal Batman.helpers.camelize("batman_object"), "BatmanObject"
      equal Batman.helpers.camelize("batman_object", true), "batmanObject"

## @underscore(string) : string

`underscore` returns the underscored version of a CamelCase word.

    test 'underscore converts CamelCase to under_scores', ->
      equal Batman.helpers.underscore("BatmanObject"), "batman_object"

## @titleize(string) : string

`titleize` does a word-wise capitalization of a phrase or word.

    test 'titleize makes the first letter of each word in the string uppercase', ->
      equal Batman.helpers.titleize("batmanObject"), "BatmanObject"
      equal Batman.helpers.titleize("batman object"), "Batman Object"
      equal Batman.helpers.titleize("AlreadyCapitalized"), "AlreadyCapitalized"

## @capitalize(string) : string

Deprecated alias of `titleize`.

## @trim(string) : string

`trim` trims a string getting rid of extra white space around the string or returning an empty string if it is null.

    test 'trim gets rid of space around a string', ->
      equal Batman.helpers.trim("TrimRight "), "TrimRight"
      equal Batman.helpers.trim(" TrimLeft"), "TrimLeft"
      equal Batman.helpers.trim(" TrimBothSides "), "TrimBothSides"
      equal Batman.helpers.trim("AlreadyTrimmed"), "AlreadyTrimmed"

    test 'trim turns a null or undefined string into an empty string', ->
      equal Batman.helpers.trim(null), ""
      equal Batman.helpers.trim(undefined), ""

## @interpolate(stringOrObject, keys) : string

`interpolate` interpolates a string, filling it in with values matching interpolation keys, similar to printf variants.

    test 'interpolate fills in key values globally in a string', ->
      equal Batman.helpers.interpolate("%{field} must be at least %{count} characters in order for %{field} to be valid", count: "3", field: "name"), "name must be at least 3 characters in order for name to be valid"

    test 'interpolate fills in key values globally in an object-embedded string', ->
      equal Batman.helpers.interpolate({'other': "%{field} must be at least %{count} characters in order for %{field} to be valid"}, count: "3", field: "name"), "name must be at least 3 characters in order for name to be valid"

    test 'interpolate fills in key values globally in an object-embedded string, embedded by key count', ->
      equal Batman.helpers.interpolate({3: "%{field} must be at least %{count} characters in order for %{field} to be valid"}, count: "3", field: "name"), "name must be at least 3 characters in order for name to be valid"

## @humanize(string) : string

`humanize` reformats a string that has a programmatic meaning (camelcased, underscored, "_id" suffixed) to make human-readable by separating concatenated words and/or getting rid of the "_id" suffix.

    test 'humanize replaces underscores and dashes with empty space', ->
      equal Batman.helpers.humanize('underscored_string'), 'Underscored string'
      equal Batman.helpers.humanize('dash-separated-string'), 'Dash separated string'

    test 'humanize splits camel cased words by empty space', ->
      equal Batman.helpers.humanize('CamelCasedString'), 'Camel cased string'

    test 'humanize title-cases the first word', ->
      equal Batman.helpers.humanize('lower case sentence'), 'Lower case sentence'

    test 'humanize lower-cases all words after the first one', ->
      equal Batman.helpers.humanize('Mixed Case SENTENCE'), 'Mixed case sentence'

    test 'humanize gets rid of _id suffix', ->
      equal Batman.helpers.humanize('identifying_string_id'), 'Identifying string'

## @toSentence(array) : string

`toSentence` joins the items in the array with commas or "and", as appropriate:

    test 'toSentence joins array items with commas or "and"', ->
      equal Batman.helpers.toSentence(["The Joker"]), "The Joker"
      equal Batman.helpers.toSentence(["The Joker", "Scarecrow"]), "The Joker and Scarecrow"
      equal Batman.helpers.toSentence(["The Joker", "Scarecrow", "Poison Ivy"]), "The Joker, Scarecrow, and Poison Ivy"
      equal Batman.helpers.toSentence(["The Joker", "Scarecrow", "Poison Ivy", "Penguin"]), "The Joker, Scarecrow, Poison Ivy, and Penguin"
