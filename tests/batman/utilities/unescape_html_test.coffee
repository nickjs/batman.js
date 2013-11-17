QUnit.module "Batman.unescapeHTML helper",
test "should unescape escaped basic HTML characters", ->
  equal Batman.unescapeHTML('&lt;&gt;&amp;&#34;&#39;&#x2F;'), '<>&"\'/'

test "should unescape escaped symbol characters", ->
  # http://www.w3.org/TR/html4/sgml/entities.html
  # one from ISO 8859-1, greek letters, i18n chars
  equal Batman.unescapeHTML('&pound;'), "\u00A3"
  equal Batman.unescapeHTML('&Omega;'), "\u03A9"
  equal Batman.unescapeHTML('&euro;'), '\u20AC'

test "should return undefined for undefined values", ->
  equal Batman.unescapeHTML(undefined), undefined
  equal Batman.unescapeHTML(null), undefined
