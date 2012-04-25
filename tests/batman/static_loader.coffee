jQuery.ajax
  url: window.location.toString().replace('test_static', 'test')
  success: (html) ->
    html = "<div>#{html}</div>"
    jsScripts = $.makeArray($('script[src*=".coffee"]', html)).map (element) ->
      $(element).attr('src').replace('.coffee', '.js')

    head.js jsScripts..., ->
      QUnit.start()

  error: -> throw new Error("Couldn't load test.html!")

