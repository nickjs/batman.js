QUnit.module 'Batman.DOM.IteratorBinding longest increasing subsequence',
  setup: ->
    @cmp = Batman.SetSort::compare
    @longestIncreasingSubsequence = Batman.DOM.IteratorBinding._longestIncreasingSubsequence

test 'it should return the whole array for a sorted array', ->
  arr = [0, 1, 2, 3, 4, 5, 6]
  deepEqual @longestIncreasingSubsequence(arr, @cmp), arr

test 'it should not break for edge cases', ->
  arr = [1]
  deepEqual @longestIncreasingSubsequence(arr, @cmp), [1]

  arr = []
  deepEqual @longestIncreasingSubsequence(arr, @cmp), []

test 'it should work for general cases', ->
  arr = [10, 1, 9, 2, 8, 3, 7, 4, 5]
  deepEqual @longestIncreasingSubsequence(arr, @cmp), [1, 2, 3, 4, 5]

  arr = [4, 4, 5, 5, 4, 4, 4]
  deepEqual @longestIncreasingSubsequence(arr, @cmp), [4, 4, 4, 4, 4]
