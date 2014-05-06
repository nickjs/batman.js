## Pull Requests
- All changes, from core team and not, should be in the form of a pull request from a branch.
- Pull request description should explain what the problem was and what steps you took to fix it.
- After a pull request has been merged in, we'll use the "Delete Branch" button (especially for branches in origin).

## Tests
- All code should have appropriate batman tests. Apps shouldn't need to test the framework; the framework should test the framework.
- Ideally each commit should be a self-contained unit of new code passing the test suite, but the only real requirement is that the branch or pull request, when done, should pass the test suite.

## Building
- Do not include built files with source change commits. It makes the commits hard to diff and revert.
- You can get `batman/master` from http://batman.js.s3.amazonaws.com/batman-master.tar.gz

## Documentation
- Anyone can help contribute to the docs, even without contributing code!
- If you're adding a new batman feature or changing an existing API or feature, it would be AWESOME if you could include docs with the pull request.
- Docs are required for core team pull requests, but just highly appreciated for external contributors.
