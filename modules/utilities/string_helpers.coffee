Inflector = require './inflector'

camelize_rx = /(?:^|_|\-)(.)/g
titleize_rx = /(^|\s)([a-z])/g
underscore_rx1 = /([A-Z]+)([A-Z][a-z])/g
underscore_rx2 = /([a-z\d])([A-Z])/g
humanize_rx1 = /_id$/
humanize_rx2 = /_|-|\./g
humanize_rx3 = /^\w/g

module.exports = helpers =
  ordinalize: -> helpers.inflector.ordinalize.apply(helpers.inflector, arguments)
  singularize: -> helpers.inflector.singularize.apply(helpers.inflector, arguments)
  pluralize: (count, singular, plural, includeCount = true) ->
    if arguments.length < 2
      helpers.inflector.pluralize(count)
    else
      result = if +count is 1
          singular
        else
          plural || helpers.inflector.pluralize(singular)

      if includeCount
        result = "#{count || 0} #{result}"
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

  capitalize: (string) -> string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

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
      array = array.slice()
      last = array.pop()
      itemString = array.join(', ')
      itemString += ", and #{last}"
      return itemString

  coerceInteger: (value, shouldThrow=false) ->
    if (typeof value is "string") and (value.match(/[^0-9]/) is null) and ("#{coercedValue = parseInt(value, 10)}" is value)
      coercedValue
    else if shouldThrow
      throw "#{value} was passed to Batman.helpers.coerceInteger but couldn't be coerced!"
    else
      value

inflector = new Inflector
helpers.inflector = inflector

inflector.plural(/$/, 's')
inflector.plural(/s$/i, 's')
inflector.plural(/(ax|test)is$/i, '$1es')
inflector.plural(/(octop|vir)us$/i, '$1i')
inflector.plural(/(octop|vir)i$/i, '$1i')
inflector.plural(/(alias|status)$/i, '$1es')
inflector.plural(/(bu)s$/i, '$1ses')
inflector.plural(/(buffal|tomat)o$/i, '$1oes')
inflector.plural(/([ti])um$/i, '$1a')
inflector.plural(/([ti])a$/i, '$1a')
inflector.plural(/sis$/i, 'ses')
inflector.plural(/(?:([^f])fe|([lr])f)$/i, '$1$2ves')
inflector.plural(/(hive)$/i, '$1s')
inflector.plural(/([^aeiouy]|qu)y$/i, '$1ies')
inflector.plural(/(x|ch|ss|sh)$/i, '$1es')
inflector.plural(/(matr|vert|ind)(?:ix|ex)$/i, '$1ices')
inflector.plural(/([m|l])ouse$/i, '$1ice')
inflector.plural(/([m|l])ice$/i, '$1ice')
inflector.plural(/^(ox)$/i, '$1en')
inflector.plural(/^(oxen)$/i, '$1')
inflector.plural(/(quiz)$/i, '$1zes')

inflector.singular(/s$/i, '')
inflector.singular(/(n)ews$/i, '$1ews')
inflector.singular(/([ti])a$/i, '$1um')
inflector.singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '$1$2sis')
inflector.singular(/(^analy)ses$/i, '$1sis')
inflector.singular(/([^f])ves$/i, '$1fe')
inflector.singular(/(hive)s$/i, '$1')
inflector.singular(/(tive)s$/i, '$1')
inflector.singular(/([lr])ves$/i, '$1f')
inflector.singular(/([^aeiouy]|qu)ies$/i, '$1y')
inflector.singular(/(s)eries$/i, '$1eries')
inflector.singular(/(m)ovies$/i, '$1ovie')
inflector.singular(/(x|ch|ss|sh)es$/i, '$1')
inflector.singular(/([m|l])ice$/i, '$1ouse')
inflector.singular(/(bus)es$/i, '$1')
inflector.singular(/(o)es$/i, '$1')
inflector.singular(/(shoe)s$/i, '$1')
inflector.singular(/(cris|ax|test)es$/i, '$1is')
inflector.singular(/(octop|vir)i$/i, '$1us')
inflector.singular(/(alias|status)es$/i, '$1')
inflector.singular(/^(ox)en/i, '$1')
inflector.singular(/(vert|ind)ices$/i, '$1ex')
inflector.singular(/(matr)ices$/i, '$1ix')
inflector.singular(/(quiz)zes$/i, '$1')
inflector.singular(/(database)s$/i, '$1')

inflector.irregular('person', 'people')
inflector.irregular('man', 'men')
inflector.irregular('child', 'children')
inflector.irregular('sex', 'sexes')
inflector.irregular('move', 'moves')
inflector.irregular('cow', 'kine')
inflector.irregular('zombie', 'zombies')

inflector.uncountable('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans')
