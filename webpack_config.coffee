# See webpack.config.js for more examples:
# https://github.com/webpack/webpack-with-common-libs/blob/master/webpack.config.js

path = require 'path'
webpack = require 'webpack'

# webpack-dev-server options used in gulpfile
# https://github.com/webpack/webpack-dev-server

module.exports =

  contentBase: "#{__dirname}/modules/"

  cache: true

  entry:
    "batman"                    : './modules/batman'
    # "batman.testing"            : './modules/testing'
    # "batman.jquery"             : './platform/jquery'
    # "extras/batman.i18n"        : "./modules/i18n"
    # "extras/batman.rails"       : "./modules/extras/batman.rails"
    # "extras/batman.paginator"   : "./modules/paginator"

  output:
    path: path.join(__dirname, 'dist')
    publicPath: 'dist/'
    filename: '[name].js'
    chunkFilename: '[chunkhash].js'

  module:
    loaders: [
      {
        test: /\.coffee$/
        loader: 'coffee-loader'
      }
    ]

  resolve:
    extensions: ['', '.webpack.js', '.web.js', '.coffee', '.js']
    modulesDirectories: ['modules', '.']
    alias:
      object_helpers: "./foundation/object_helpers"

  plugins: [
    # new webpack.optimize.UglifyJsPlugin({})
  ]