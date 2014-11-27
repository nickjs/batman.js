# Shhh... Batman is sleeping.

Batman.js is [no longer in production at Shopify](http://www.shopify.com/technology/15646068-rebuilding-the-shopify-admin-improving-developer-productivity-by-deleting-28-000-lines-of-javascript) and is not actively developed. :(

# batman.js

[batman.js](http://batmanjs.org/) is a framework for building rich single-page browser applications.

#### It's got:

* __A stateful MVC architecture__ that emphasizes object-oriented design, convention over configuration, and communication via REST.
* __A developer-friendly API__ inspired by [Ruby on Rails](http://rubyonrails.org/) and designed for [CoffeeScript](http://coffeescript.org/).
* __Powerful two-way data binding__. [Every property](http://batmanjs.org/docs/api/batman.object_accessors.html) tracks its sources and updates automatically when its sources change.
* __Pure HTML templates__ so you can use whatever templating engine you like. [Liquid](http://liquidmarkup.org/)-style filters make designers & developers feel right at home.
* __Lots more:__ [expressive routing](http://batmanjs.org/docs/api/batman.app_routing.html), [model validations](http://batmanjs.org/docs/api/batman.model.html#class_function_validate), [model associations](http://batmanjs.org/docs/api/batman.model_associations.html), [I18n](http://batmanjs.org/docs/api/batman.i18n.html), [`localStorage` persistence](http://batmanjs.org/docs/api/batman.storageadapter.html)...

To find out more or get started with batman.js, check out the website: **[http://batmanjs.org](http://batmanjs.org)**.

## Contributing [![Build Status](https://travis-ci.org/batmanjs/batman.png?branch=master)](http://travis-ci.org/batmanjs/batman)

Well-tested contributions are always welcome! Here's what you should do:

#### 1. Clone the repo

```bash
git clone git@github.com:batmanjs/batman.git
```

#### 2. Install dependencies using NPM

```bash
npm install
npm install -g gulp
```

If you don't already have Node.js, the installation instructions are [here](https://github.com/joyent/node/wiki/Installation).

#### 3. Run the tests

batman.js uses [karma](http://karma-runner.github.io) and [QUnit](http://docs.jquery.com/QUnit#API_documentation) for orchestrating tests.

To run the tests, run the following command from the project root:

```bash
gulp # starts webpack & karma
```

Assuming you have Chrome installed, it should automatically open and start running the tests. The test outcome will appear in your terminal.

#### 4. Write some test-driven code

The tests are in `tests/batman`. All test files in there are automatically picked up and run.

#### 5. Update the documentation

The [API documentation](http://batmanjs.org/docs/api/) is written using [literate CoffeeScript](http://coffeescript.org/#literate).

The API documentation includes its own set of tests, which serves as both an
assurance that the API hasn't broken, as well as a set of examples for how to use
it. These tests need not be comprehensive (that's what the regular tests are
for), but should cover the most common use cases. They're automatically run
alongside the regular tests, so you don't need to run them manually.

If you want to render the API docs, see the [README for batmanjs.github.io](https://github.com/batmanjs/batmanjs.github.io/blob/master/README.md).

Please read the [README for the docs](https://github.com/batmanjs/batman/blob/master/docs/README.md)
before writing any.

#### 6. Create a pull request

If it's good code that fits with the goals of the project, we'll merge it in!

## Compiling the library

Task | Does...
---- | ----
`gulp` | Does it all: starts Karma and watches for changes, running `finalize` on any change
`gulp build` | compiles files into `/dist`
`gulp finalize` | runs `build` and creates minified versions
`gulp test` | starts Karma runner
`gulp test:travis` | `finalize`s then runs the tests once with PhantomJS

## License

batman.js is copyright 2014 by [Shopify](http://www.shopify.com), released under the MIT License (see LICENSE for details).

