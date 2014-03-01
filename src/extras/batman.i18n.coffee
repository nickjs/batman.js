class Batman.I18N extends Batman.Object
  @defaultLocale: "en"
  @useFallback: false

  @classAccessor 'locale',
    get: -> @locale || @get('defaultLocale')
    set: (k,v) -> @locale = v
    unset: -> x = @locale; delete @locale; x

  @classAccessor 'translations', -> @get("locales.#{@get('locale')}")
  @classAccessor 'defaultTranslations', -> @get("locales.#{@defaultLocale}")

  @translate: (key, values) ->
    translation = @get("translations.#{key}")
    translation ||= @get("defaultTranslations.#{key}") if @useFallback
    if ! translation?
      Batman.developer.warn "Warning, undefined translation #{key} when in local #{@get('locale')}"
      return ""
    return translation unless values
    Batman.helpers.interpolate(translation, values)

  @enable: ->
    @_oldTranslation = Batman.translate
    @locales.set 'en', Batman.translate.messages
    Batman.translate = => @translate(arguments...)

  @disable: ->
    Batman.translate = @_oldTranslation

  constructor: -> Batman.developer.error "Can't instantiate i18n!"

class Batman.I18N.LocalesStorage extends Batman.Object
  constructor: ->
    @isStorage = true
    @_storage = {}
    super

  # Define a default accessor which fires off a request to the backend to
  # grab a locale json.
  @accessor
    get: (k) ->
      unless @_storage[k]
        @_storage[k] = {}
        new Batman.Request
          url: "/locales/#{k}.json"
          success: (data) => @set k, data[k]
          error: (xhr) ->
            throw new Error("Couldn't load locale file #{k}!")
      @_storage[k]
    set: (k, v) -> @_storage[k] = v
    unset: (k) ->
      x = @_storage[k]
      delete @_storage[k]
      x

Batman.I18N.set 'locales', new Batman.I18N.LocalesStorage

Batman.Filters.t = Batman.Filters.translate = (args...) ->
    binding = if args[2] then args[2] else args[1]
    key = args[0] # Store key for lookupKeypath if translate didn't found
    unless binding.key and binding.key.substr(0, 2) == "t." # If already translated, skip it
      args[0] = Batman.I18N.translate(key)
      args[0] ||= key # no translate, return default key
    Batman.Filters.interpolate.apply(@, args)

Batman.config.translations = true
