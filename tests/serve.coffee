connect = require 'connect'
assets = require 'connect-assets'
url = require 'url'
path = require 'path'
liquor = require 'liquor'
fs = require 'fs'

root = path.normalize(path.join __dirname, '../')
console.log "Batman tests are being served on http://localhost:1047/tests/batman/test.html"
app = connect.createServer(
  connect.favicon(),
  connect.logger(),
  connect.static(root),
  connect.directory(root)
)

template = liquor(fs.readFileSync(path.join(root, 'tests', 'batman', 'test.html.liquor')).toString())
testManifestMiddleware = (req, res, next) ->
  requestURL = url.parse(req.url)
  if path.normalize(decodeURIComponent(requestURL.pathname)) == '/tests/batman/test.html'
    contents = template()
    res.setHeader('Content-Type', 'text/html')
    res.setHeader('Content-Length', contents.length)
    res.end(contents)
  else
    next()

app.use testManifestMiddleware

app.use assets
  src: root
  buildDir: false #'./build'
  minify: false

app.listen 1047
