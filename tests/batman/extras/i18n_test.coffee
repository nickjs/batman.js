
preI18N = {}

reset = ->
  # Hack so that the actions taken in reset don't fire observers which
  # do the implicit locale file load
  Batman.I18N.property('translations').die()
  Batman.I18N.property('locales.en').die()
  Batman.I18N.property('locales.fr').die()
  Batman.I18N.property('locales').die()
  Batman.I18N.property('locale').die()
  Batman.I18N.unset 'locale'
  Batman.I18N.set('locales', preI18N.oldLocales)
  Batman.Request = preI18N.oldRequest
  Batman.I18N.disable()

class MockRequest extends MockClass
  @chainedCallback 'success'
  @chainedCallback 'error'
  @chainedCallback 'loading'
  @chainedCallback 'loaded'

QUnit.module "Batman.I18N: locale property",
  setup: ->
    viewHelpers = window.viewHelpers
    # HACK: store the existing values once, keep restoring them in `reset`
    preI18N.oldLocales ||= Batman.I18N.get('locales')
    preI18N.oldRequest ||= Batman.Request
    MockRequest.reset()
    Batman.I18N.set('locales', Batman {en: {grapefruit: true}, fr: {pamplemouse: true}})
    Batman.Request = MockRequest

  teardown: reset

test "the default locale should be returned if no locale has been set", ->
  Batman.I18N.unset 'locale'
  equal Batman.I18N.get('locale'), Batman.I18N.get('defaultLocale')

test "setting the locale should work", ->
  Batman.I18N.set 'locale', 'fr'
  equal Batman.I18N.get('locale'), 'fr'

test "setting the use fallback should work", ->
  Batman.I18N.set 'useFallback', true
  equal Batman.I18N.get('useFallback'), true

test "Batman.I18N.translations should reflect the locale", ->
  Batman.I18N.set 'locale', 'en'
  ok Batman.I18N.get('translations.grapefruit')
  ok !Batman.I18N.get('translations.pamplemouse')

  Batman.I18N.set 'locale', 'fr'
  ok !Batman.I18N.get('translations.grapefruit')
  ok Batman.I18N.get('translations.pamplemouse')

QUnit.module "Batman.I18N: locales fetching",
  setup: ->
    MockRequest.reset()
    Batman.Request = MockRequest
    Batman.I18N.unset('locales')
    newLocales = new Batman.I18N.LocalesStorage
    Batman.I18N.set('locales', newLocales)
    @obj = {a: "b"}

  teardown: ->
    reset.call(@)

test "the locales should be settable", ->
  en = Batman()
  Batman.I18N.set('locales.en', en)
  equal Batman.I18N.get('locales.en'), en

asyncTest "getting a new locale should fire observers when the new locale is fetched", ->
  Batman.I18N.get('locales').observe 'en', spy = createSpy()
  deepEqual Batman.I18N.get('locales.en'), {}, "should return an obj for use in the interm"

  delay =>
    MockRequest.lastInstance.fireSuccess({en: @obj})
    equal spy.lastCallArguments[0], @obj

asyncTest "getting a new locale should trigger a request for that locale", ->
  deepEqual Batman.I18N.get('locales.en'), {}, "should return an obj for use in the interm"

  delay =>
    MockRequest.lastInstance.fireSuccess({en: @obj})
    equal Batman.I18N.get('locales.en'), @obj

test "the locales obj should be replaceable", ->
  Batman.I18N.set('locales', Batman {en: {a: "c"}})
  deepEqual Batman.I18N.get('locales.en'), {a: "c"}

QUnit.module "Batman.I18N: translate filter",
  setup: ->
    class App extends Batman.App
      @layout: null

    Batman.Request = MockRequest
    Batman.I18N.enable()
    Batman.I18N.set 'locales', Batman
      fr:
        grapefruit: 'pamplemouse'
        kind_of_grapefruit: "pamplemouse %{kind}"
        how_many_grapefruits:
          1: "1 pamplemouse"
          other: "%{count} pamplemouses"
      en:
        fallback: 'fallback string'
    Batman.I18N.set 'locale', 'fr'
    App.run()

  teardown: reset

asyncTest "it should accept translations from other keypaths", ->
  viewHelpers.render '<div data-bind="foo.bar | translate"></div>', false, {foo: {bar: "baz"}}, (node) ->
    equal node.childNodes[0].innerHTML, "baz"
    QUnit.start()

asyncTest "it should accept string literals", ->
  viewHelpers.render '<div data-bind="\'this kind of defeats the purpose\' | translate"></div>', false, {}, (node) ->
    equal node.childNodes[0].innerHTML, "this kind of defeats the purpose"
    QUnit.start()

asyncTest "it should apply keypath value after get translation", ->
  viewHelpers.render '<div data-bind="\'how_many_grapefruits.other\' | translate {\'count\': \'grapefruits.count\'}"></div>', false, {grapefruits: {count: 10}}, (node) ->
    equal node.childNodes[0].innerHTML, "10 pamplemouses"
    QUnit.start()

asyncTest "it should look up keys in the translations under t", ->
  viewHelpers.render '<div data-bind="t.grapefruit"></div>', false, {}, (node) ->
    equal node.childNodes[0].innerHTML, "pamplemouse", 't has been added to the default render stack'
    QUnit.start()

asyncTest "it should fallback string from default locale", ->
  Batman.I18N.useFallback = true
  viewHelpers.render '<div data-bind="\'fallback\' | translate"></div>', false, {}, (node) ->
    equal node.childNodes[0].innerHTML, "fallback string"
    QUnit.start()
