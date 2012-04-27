class Batman.Inflector
  plural: []
  singular: []
  uncountable: []

  @plural: (regex, replacement) -> @::plural.unshift [regex, replacement]
  @singular: (regex, replacement) -> @::singular.unshift [regex, replacement]
  @irregular: (singular, plural) ->
    if singular.charAt(0) == plural.charAt(0)
      @plural new RegExp("(#{singular.charAt(0)})#{singular.slice(1)}$", "i"), "Batman.1" + plural.slice(1)
      @plural new RegExp("(#{singular.charAt(0)})#{plural.slice(1)}$", "i"), "Batman.1" + plural.slice(1)
      @singular new RegExp("(#{plural.charAt(0)})#{plural.slice(1)}$", "i"), "Batman.1" + singular.slice(1)
    else
      @plural new RegExp("#{singular}$", 'i'), plural
      @plural new RegExp("#{plural}$", 'i'), plural
      @singular new RegExp("#{plural}$", 'i'), singular

  @uncountable: (strings...) -> @::uncountable = @::uncountable.concat(strings.map((x) -> new RegExp("#{x}$", 'i')))

  @plural(/$/, 's')
  @plural(/s$/i, 's')
  @plural(/(ax|test)is$/i, 'Batman.1es')
  @plural(/(octop|vir)us$/i, 'Batman.1i')
  @plural(/(octop|vir)i$/i, 'Batman.1i')
  @plural(/(alias|status)$/i, 'Batman.1es')
  @plural(/(bu)s$/i, 'Batman.1ses')
  @plural(/(buffal|tomat)o$/i, 'Batman.1oes')
  @plural(/([ti])um$/i, 'Batman.1a')
  @plural(/([ti])a$/i, 'Batman.1a')
  @plural(/sis$/i, 'ses')
  @plural(/(?:([^f])fe|([lr])f)$/i, 'Batman.1Batman.2ves')
  @plural(/(hive)$/i, 'Batman.1s')
  @plural(/([^aeiouy]|qu)y$/i, 'Batman.1ies')
  @plural(/(x|ch|ss|sh)$/i, 'Batman.1es')
  @plural(/(matr|vert|ind)(?:ix|ex)$/i, 'Batman.1ices')
  @plural(/([m|l])ouse$/i, 'Batman.1ice')
  @plural(/([m|l])ice$/i, 'Batman.1ice')
  @plural(/^(ox)$/i, 'Batman.1en')
  @plural(/^(oxen)$/i, 'Batman.1')
  @plural(/(quiz)$/i, 'Batman.1zes')

  @singular(/s$/i, '')
  @singular(/(n)ews$/i, 'Batman.1ews')
  @singular(/([ti])a$/i, 'Batman.1um')
  @singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, 'Batman.1Batman.2sis')
  @singular(/(^analy)ses$/i, 'Batman.1sis')
  @singular(/([^f])ves$/i, 'Batman.1fe')
  @singular(/(hive)s$/i, 'Batman.1')
  @singular(/(tive)s$/i, 'Batman.1')
  @singular(/([lr])ves$/i, 'Batman.1f')
  @singular(/([^aeiouy]|qu)ies$/i, 'Batman.1y')
  @singular(/(s)eries$/i, 'Batman.1eries')
  @singular(/(m)ovies$/i, 'Batman.1ovie')
  @singular(/(x|ch|ss|sh)es$/i, 'Batman.1')
  @singular(/([m|l])ice$/i, 'Batman.1ouse')
  @singular(/(bus)es$/i, 'Batman.1')
  @singular(/(o)es$/i, 'Batman.1')
  @singular(/(shoe)s$/i, 'Batman.1')
  @singular(/(cris|ax|test)es$/i, 'Batman.1is')
  @singular(/(octop|vir)i$/i, 'Batman.1us')
  @singular(/(alias|status)es$/i, 'Batman.1')
  @singular(/^(ox)en/i, 'Batman.1')
  @singular(/(vert|ind)ices$/i, 'Batman.1ex')
  @singular(/(matr)ices$/i, 'Batman.1ix')
  @singular(/(quiz)zes$/i, 'Batman.1')
  @singular(/(database)s$/i, 'Batman.1')

  @irregular('person', 'people')
  @irregular('man', 'men')
  @irregular('child', 'children')
  @irregular('sex', 'sexes')
  @irregular('move', 'moves')
  @irregular('cow', 'kine')
  @irregular('zombie', 'zombies')

  @uncountable('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans')

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
    for uncountableRegex in @uncountable
      return word if uncountableRegex.test(word)
    for [regex, replace_string] in @plural
      return word.replace(regex, replace_string) if regex.test(word)
    word

  singularize: (word) ->
    for uncountableRegex in @uncountable
      return word if uncountableRegex.test(word)
    for [regex, replace_string] in @singular
      return word.replace(regex, replace_string)  if regex.test(word)
    word
