#= require ./inflector

camelize_rx = /(?:^|_|\-)(.)/g
titleize_rx = /(^|\s)([a-z])/g
underscore_rx1 = /([A-Z]+)([A-Z][a-z])/g
underscore_rx2 = /([a-z\d])([A-Z])/g
humanize_rx1 = /_id$/
humanize_rx2 = /_|-|\./g
humanize_rx3 = /^\w/g

Batman.helpers =
  ordinalize: -> Batman.helpers.inflector.ordinalize.apply Batman.helpers.inflector, arguments
  singularize: -> Batman.helpers.inflector.singularize.apply Batman.helpers.inflector, arguments
  pluralize: (count, singular, plural, includeCount = true) ->
    if arguments.length < 2
      Batman.helpers.inflector.pluralize count
    else
      result = if +count is 1 then singular else (plural || Batman.helpers.inflector.pluralize(singular))
      if includeCount
        result = "#{count || 0} " + result
      result

  camelize: (string, firstLetterLower) ->
    string = string.replace camelize_rx, (str, p1) -> p1.toUpperCase()
    if firstLetterLower then string.substr(0,1).toLowerCase() + string.substr(1) else string

  underscore: (string) ->
    string.replace(underscore_rx1, '$1_$2')
          .replace(underscore_rx2, '$1_$2')
          .replace('-', '_').toLowerCase()

  titleize: (string) ->
    string.replace titleize_rx, (m, p1, p2) -> p1 + p2.toUpperCase()

  capitalize: (string) ->
    Batman.developer.deprecated('capitalize', 'Renamed to titleize.')
    Batman.helpers.titleize(string)

  trim: (string) -> if string then string.trim() else ""

  interpolate: (stringOrObject, keys) ->
    if typeof stringOrObject is 'object'
      string = stringOrObject[keys.count]
      unless string
        string = stringOrObject['other']
    else
      string = stringOrObject

    for key, value of keys
      string = string.replace(new RegExp("%\\{#{key}\\}", "g"), value)
    string

  humanize: (string) ->
    string = Batman.helpers.underscore(string)
    string = Batman.helpers.inflector.humanize(string)
    string.replace(humanize_rx1, '')
          .replace(humanize_rx2, ' ')
          .replace(humanize_rx3, (match) -> match.toUpperCase())

  toSentence: (array) ->
    if array.length < 3
      return array.join ' and '
    else
      last = array.pop()
      itemString = array.join(', ')
      itemString += ", and #{last}"
      return itemString

Inflector = new Batman.Inflector
Batman.helpers.inflector = Inflector

Inflector.plural(/$/, 's')
Inflector.plural(/s$/i, 's')
Inflector.plural(/(ax|test)is$/i, '$1es')
Inflector.plural(/(octop|vir)us$/i, '$1i')
Inflector.plural(/(octop|vir)i$/i, '$1i')
Inflector.plural(/(alias|status)$/i, '$1es')
Inflector.plural(/(bu)s$/i, '$1ses')
Inflector.plural(/(buffal|tomat)o$/i, '$1oes')
Inflector.plural(/([ti])um$/i, '$1a')
Inflector.plural(/([ti])a$/i, '$1a')
Inflector.plural(/sis$/i, 'ses')
Inflector.plural(/(?:([^f])fe|([lr])f)$/i, '$1$2ves')
Inflector.plural(/(hive)$/i, '$1s')
Inflector.plural(/([^aeiouy]|qu)y$/i, '$1ies')
Inflector.plural(/(x|ch|ss|sh)$/i, '$1es')
Inflector.plural(/(matr|vert|ind)(?:ix|ex)$/i, '$1ices')
Inflector.plural(/([m|l])ouse$/i, '$1ice')
Inflector.plural(/([m|l])ice$/i, '$1ice')
Inflector.plural(/^(ox)$/i, '$1en')
Inflector.plural(/^(oxen)$/i, '$1')
Inflector.plural(/(quiz)$/i, '$1zes')

Inflector.singular(/s$/i, '')
Inflector.singular(/(n)ews$/i, '$1ews')
Inflector.singular(/([ti])a$/i, '$1um')
Inflector.singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '$1$2sis')
Inflector.singular(/(^analy)ses$/i, '$1sis')
Inflector.singular(/([^f])ves$/i, '$1fe')
Inflector.singular(/(hive)s$/i, '$1')
Inflector.singular(/(tive)s$/i, '$1')
Inflector.singular(/([lr])ves$/i, '$1f')
Inflector.singular(/([^aeiouy]|qu)ies$/i, '$1y')
Inflector.singular(/(s)eries$/i, '$1eries')
Inflector.singular(/(m)ovies$/i, '$1ovie')
Inflector.singular(/(x|ch|ss|sh)es$/i, '$1')
Inflector.singular(/([m|l])ice$/i, '$1ouse')
Inflector.singular(/(bus)es$/i, '$1')
Inflector.singular(/(o)es$/i, '$1')
Inflector.singular(/(shoe)s$/i, '$1')
Inflector.singular(/(cris|ax|test)es$/i, '$1is')
Inflector.singular(/(octop|vir)i$/i, '$1us')
Inflector.singular(/(alias|status)es$/i, '$1')
Inflector.singular(/^(ox)en/i, '$1')
Inflector.singular(/(vert|ind)ices$/i, '$1ex')
Inflector.singular(/(matr)ices$/i, '$1ix')
Inflector.singular(/(quiz)zes$/i, '$1')
Inflector.singular(/(database)s$/i, '$1')

Inflector.irregular('person', 'people')
Inflector.irregular('man', 'men')
Inflector.irregular('child', 'children')
Inflector.irregular('sex', 'sexes')
Inflector.irregular('move', 'moves')
Inflector.irregular('cow', 'kine')
Inflector.irregular('zombie', 'zombies')

Inflector.uncountable('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans')
