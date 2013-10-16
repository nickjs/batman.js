# batman.js

[batman.js](http://batmanjs.org/) is a framework for building rich single-page browser applications. It is written in [CoffeeScript](http://jashkenas.github.com/coffee-script/) and its API is developed with CoffeeScript in mind, but of course you can use regular JavaScript too.

#### It's got:

* a stateful MVC architecture
* a powerful 2-way data binding system
* routable controller actions
* pure HTML views
* toolchain support built on [Node.js](http://nodejs.org) and [cake](http://jashkenas.github.com/coffee-script/#cake)

The APIs are heavily inspired by [Rails](http://rubyonrails.org/) and are designed to make Rails devs feel right at home.

To find out more or get started with batman.js, check out the website: **[http://batmanjs.org](http://batmanjs.org)**.

## Contributing [![Build Status](https://secure.travis-ci.org/batmanjs/batman.png)](http://travis-ci.org/batmanjs/batman)

Well-tested contributions are always welcome! Here's what you should do:

#### 1. Clone the repo

```bash
git clone git@github.com:batmanjs/batman.git
```

#### 2. Install dependencies using NPM

```bash
npm install
```

If you don't already have Node.js, the installation instructions are [here](https://github.com/joyent/node/wiki/Installation).

#### 3. Run the tests

batman.js uses [karma](http://karma-runner.github.io) and [QUnit](http://docs.jquery.com/QUnit#API_documentation) for orchestrating tests.

To run the tests, run the following command from the project root:

```bash
cake test
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

#### 6. Create a pull request

If it's good code that fits with the goals of the project, we'll merge it in!

## License

batman.js is copyright 2013 by [Shopify](http://www.shopify.com), released under the MIT License (see LICENSE for details).

