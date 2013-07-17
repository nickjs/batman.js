QUnit.module 'Batman.DOM.IteratorBinding longest increasing subsequence',
  setup: ->
    @cmp = Batman.SetSort::compare
    @longestIncreasingSubsequence = Batman.DOM.IteratorBinding._longestIncreasingSubsequence

test 'it should return the whole array for a sorted array', ->
  arr = [0, 1, 2, 3, 4, 5, 6]
  deepEqual @longestIncreasingSubsequence(arr, @cmp).subsequence, arr

test 'it should not break for edge cases', ->
  arr = [1]
  deepEqual @longestIncreasingSubsequence(arr, @cmp).subsequence, [1]

  arr = []
  deepEqual @longestIncreasingSubsequence(arr, @cmp).subsequence, []

test 'it should work for general cases', ->
  arr = [10,        1,         9, 2,         8, 3,         7, 4, 5]
  exp = [undefined, 1, undefined, 2, undefined, 3, undefined, 4, 5]
  deepEqual @longestIncreasingSubsequence(arr, @cmp).subsequence, exp

  arr = [4, 4, 5, 5, 4, 4, 4]
  exp = [4, 4, undefined, undefined, 4, 4, 4]
  deepEqual @longestIncreasingSubsequence(arr, @cmp).subsequence, exp
