class Batman.Inflector
  plural:   (regex, replacement) -> @_plural.unshift [regex, replacement]
  singular: (regex, replacement) -> @_singular.unshift [regex, replacement]
  human:    (regex, replacement) -> @_human.unshift [regex, replacement]
  uncountable: (strings...) -> @_uncountable = @_uncountable.concat(strings.map((x) -> new RegExp("#{x}$", 'i')))
  irregular: (singular, plural) ->
    if singular.charAt(0) == plural.charAt(0)
      @plural new RegExp("(#{singular.charAt(0)})#{singular.slice(1)}$", "i"), "$1" + plural.slice(1)
      @plural new RegExp("(#{singular.charAt(0)})#{plural.slice(1)}$", "i"), "$1" + plural.slice(1)
      @singular new RegExp("(#{plural.charAt(0)})#{plural.slice(1)}$", "i"), "$1" + singular.slice(1)
    else
      @plural new RegExp("#{singular}$", 'i'), plural
      @plural new RegExp("#{plural}$", 'i'), plural
      @singular new RegExp("#{plural}$", 'i'), singular

  constructor: ->
    @_plural = []
    @_singular = []
    @_uncountable = []
    @_human = []

  ordinalize: (number) ->
    absNumber = Math.abs(parseInt(number))
    if absNumber % 100 in [11..13]
      number + "th"
    else
      switch absNumber % 10
        when 1
          number + "st"
        when 2
          number + "nd"
        when 3
          number + "rd"
        else
          number + "th"

  pluralize: (word) ->
    for uncountableRegex in @_uncountable
      return word if uncountableRegex.test(word)
    for [regex, replace_string] in @_plural
      return word.replace(regex, replace_string) if regex.test(word)
    word

  singularize: (word) ->
    for uncountableRegex in @_uncountable
      return word if uncountableRegex.test(word)
    for [regex, replace_string] in @_singular
      return word.replace(regex, replace_string)  if regex.test(word)
    word

  humanize: (word) ->
    for [regex, replace_string] in @_human
      return word.replace(regex, replace_string) if regex.test(word)
    return word
