# Notes
## General Notes
include source files you want to test

# Sections

## vanilla elm-test
https://github.com/elm-community/elm-test
### Separate elm-package for test directory
There is a seperate elm-package for your test directory, this is to keep test dependencies separate
### Nesting describe statements
Describe statements can be nested in one another to keep your test structure organized
### Fuzzers
Fuzzing generates random data for your tests to check your functions against a wide variety of input.
### Todo
Indicates a test that is not yet implemented. These will always fail, but the test runner will only include them in the output if no other test failed.
### Skip
`skip` is useful when you want to focus on a subset of tests, and ignore (or skip) others. Tests tagged with `skip` will not be ran or included in the test runner's output, but using it will cause the entire test suite to fail. This is to discourage committing to version control.
### Only
Inverse of `skip`. Tagging tests with `only` cause "only" those tests to be ran, equivalent to tagging every other test with `skip`. Like `skip`, a test suite with tests tagged `only` will cause the whole enchilada to fail.

## elm-architecture-test
https://github.com/Janiczek/elm-architecture-test

Fuzz-test the update function

## elm-html-test
https://github.com/eeue56/elm-html-test

Test the view function

## arborist
https://github.com/SamirTalwar/arborist

Testing asynchronous code (i.e. tasks)

## html-test-runner
https://github.com/elm-community/html-test-runner

run tests in the browser

## elm-test-extra
https://github.com/ktonon/elm-test-extra

cool extra stuff