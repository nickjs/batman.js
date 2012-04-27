camelize_rx = /(?:^|_|\-)(.)/g
capitalize_rx = /(^|\s)([a-z])/g
underscore_rx1 = /([A-Z]+)([A-Z][a-z])/g
underscore_rx2 = /([a-z\d])([A-Z])/g

helpers = Batman.helpers =
  inflector: new Batman.Inflector
  ordinalize: -> helpers.inflector.ordinalize.apply helpers.inflector, arguments
  singularize: -> helpers.inflector.singularize.apply helpers.inflector, arguments
  pluralize: (count, singular, plural) ->
    if arguments.length < 2
      helpers.inflector.pluralize count
    else
      "#{count || 0} " + if +count is 1 then singular else (plural || helpers.inflector.pluralize(singular))

  camelize: (string, firstLetterLower) ->
    string = string.replace camelize_rx, (str, p1) -> p1.toUpperCase()
    if firstLetterLower then string.substr(0,1).toLowerCase() + string.substr(1) else string

  underscore: (string) ->
    string.replace(underscore_rx1, 'Batman.1_Batman.2')
          .replace(underscore_rx2, 'Batman.1_Batman.2')
          .replace('-', '_').toLowerCase()

  capitalize: (string) -> string.replace capitalize_rx, (m,p1,p2) -> p1 + p2.toUpperCase()

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

