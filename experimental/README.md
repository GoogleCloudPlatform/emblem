This directory exists for testing out new design approaches to our terraform setup.  Some of the things we want to do are not straightforward (e.g. supporting single and multi-env environments), so this allows us to isolate the design patterns and validate that the approach would work.

Guidelines for contributing:
- Each design question should have its own subdirectory and should be associated with a GitHub issue for tracking
- Use comments to show what you're testing and why
- Write small atomic tests
- Create a separate PR to delete your subdirectory after the code has been incorporated into the main project and the design decisions have been documented