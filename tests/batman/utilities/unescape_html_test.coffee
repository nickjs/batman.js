QUnit.module "Batman.unescapeHTML helper"

test "should unescape escaped characters", ->
  equal Batman.unescapeHTML('&lt;&gt;&amp;&#34;&#39;'), '<>&"\''
