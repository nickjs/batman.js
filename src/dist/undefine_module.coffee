# This undefines the global module function that QUnit defines.
# It's necessary because a number of our polyfills and vendored libs
# check to see if module is defined and then define all of there lovelyness
# on module. This way, it will still go to the window.
(window ? global).module = undefined
