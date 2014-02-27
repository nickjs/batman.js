# /api/Extras/Batman.I18N

`Batman.I18N` is a batman.js extra ([available in CoffeeScript](https://github.com/batmanjs/batman/blob/master/src/extras/batman.i18n.coffee)) for providing multi-langauge support in your application. It is modeled after [Rails i18n](http://guides.rubyonrails.org/i18n.html).

To use `Batman.I18N`, you must:

- Include the [batman.js extra](https://github.com/batmanjs/batman/blob/master/src/extras/batman.i18n.coffee) in your project
- Enable `Batman.I18N` with `Batman.I18N.enable()`
- Define locales on the client or [provide support from the server](/docs/api/batman.i18n.html#getting_locales_from_the_server)

For example:

```coffeescript
# after inlcuding Batman.I18N
Batman.I18N.enable()
Batman.I18N.set 'locales.en',
  messages:
    welcome: "Welcome"
  account:
    sign_in: "Sign In"
    register: "Register"

Batman.I18N.get("locale")    # "en", default
Batman.t("messages.welcome") # "Welcome"
Batman.I18N.set("locale", "zh")
Batman.t("messages.welcome") # "欢迎"
```

You can get translations for the current locale by using `t` in view bindings:

```html
<p data-source='t.messages.welcome'></p>
```

## Getting locales from the server

`Batman.I18N.get('locales')` returns a `Batman.I18N.LocalesStorage`. This object's default accessor fetches locale objects from the server and caches them on the client. For example:

```coffeescript
Batman.I18N.get('locales.es')     # GET /locales/es.json
Batman.I18N.get('locales.fr')     # GET /locales/fr.json
```

`Batman.I18N.translate` will fetch a locale if it isn't loaded already:

```
Batman.I18N.set('locale', 'zh')
Batamn.I18N.translate('welcome')  # GET /locales/zh.json
```

The `Batman.Request` expects a JSON response with the locale object:

```coffeescript
{
  "zh" : {
    "welcome" : "欢迎",
    "account" : {
      "sign_in" : "登录",
      "register" : "注册",
    }
  }
}
```

When the new values are returned, view bindings will be automatically updated.

## Error messages

You can provide error messages for a new locale by including translations in the same structure as batman.js's default messages. [See the batman.js source](https://github.com/batmanjs/batman/blob/master/src/model/validations/validators.coffee) for the structure of these messages.

## @.defaultLocale[= "en"] : String

The default locale for `Batman.I18N`. Override this to make your app start in a locale other than `"en"`.

## @%locale : String

The current locale for `Batman.I18N`, used by `Batman.translate`. Set this value to change your locale:

```coffeescript
Batman.I18N.set('locale', 'fr') # Bienvenue!
```

## @%locales : I18N.LocalesStorage

Returns the current `Batman.I18N.LocalesStorage`, which stores locales and there translations. You can set keys on `locales` to define translations:

```coffeescript
Batman.I18N.set("locales.uz", { ... })
```

See ["Getting locales from the server"](/docs/api/batman.i18n.html#getting_locales_from_the_server) for information about how `Batman.I18N.LocalesStorage` handles missing keys.

## @%translations : Object

Returns the defined translations for the current locale.

## @enable()

Turns on `Batman.I18N` by:

- Storing batman.js's default error messages to the `"en"` locale
- Overriding `Batman.translate` to use `Batman.I18N.translate`

## @disable()

Turns off `Batman.I18N` by restoring previous functionality to `Batman.translate`.
