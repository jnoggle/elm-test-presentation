# Testing in Elm

Although the static typing that the elm compiler offers is incredibly powerful, it isn't magical, and mistakes slip by even the most careful programmers. Elm doesn't offer the robust and full featured testing suite that other, older, languages do. There is, for example, no support for mocks or stubs, and no facility to string together BDD style assertions like `foo.should.equal('bar')`.

Elm's nature, however, lends itself towards unit testing each function. As a function's behavior depends solely on its inputs, we are able to precisely define inputs and expected results. This simple method works exceptionally well for decoders and utility functions, but can make testing update and view functions tricky. Luckily, there are workarounds and packages like elm-html-test that allow us to do so.

Elm-test also provides a facility called "fuzzing" for testing functions on a variety of randomly generated inputs. This can prove especially useful for testing Json decoders.

I'll begin by describing the installation and initialization process. Then I'll move onto how to create tests and the features offered by elm-test (like fuzzing). We'll touch on how to test update and view functions. Finally we'll close with some final thoughts.


## Installing Elm-Test

Every installation guide you'll find for elm-test starts by having you install it globally with npm.

```
npm install -g elm-test
```

This works great when you really want to install it globally, and doing so makes it really easy to use the test runner through the command line. On your personal development computer, this might be a good option.

However, I would prefer not adding to up my global package space if I can avoid it. If you install it locally, however, you'll have a difficult time actually using the cli to initialize your test directory and run your tests.

What you'll have to do is use the elm-test program stored in `node_modules/elm-test/bin/elm-test`. I recommend adding this to your node-package.js scripts to make running tests easier.

```
"test": "node node_modules/elm-test/bin/elm-test"
```

## Initializing Tests

If you'd like, you could add a similar script to initialize your tests, but it's probably easier to just run the script as a one off. You should run this command in the root directory of your project.

```
node node_modules/elm-test/bin/elm-test init
```

It will create a new directory calls `tests` that contains an example test and an elm-package.json. It's important to note that your tests do not share the same dependencies as your application. This allows you to keep your application dependencies clean of all the testing packages.

## Creating Tests

If you peak inside the Example.elm file. You'll find a module name and a list of imports. Following these, you'll see a function named suite, of type `Test`. This is the root level function where all your tests will live.

Each test in Elm consists of an expression that evaluates to an `Expectation` value.

```
expectation : Expectation
expectation =
    Expect.equal (2 + 2) 4
```

where

```
equal : a -> a -> Expectation
```

If both arguments are equal to one another, the expectation passes, otherwise, it fails. Failed expectations generally lead to failing tests.

To create a test, we'll use the `test` function.

```
test : String -> (() -> Expectation) -> Test
```

(Ask if anyone knows what `()` is)

The second parameter takes a `unit` and returns an Expectation. What this means in practice is that your test function expects a function that returns an expectation, not an actual expectation. This is done to allow deferring the execution of the expectation. Here's a full example of what we have so far.

```
suite : Test
suite =
test "one plus one equals two" (\_ -> Expect.equal 4 (2 + 2))
```

## Testing a Decoder

One of the most useful applications of elm-test is for testing Json decoders. If we have a simple Foo decoder like so:

```
type alias Foo =
    { bar : String }

fooDecoder : Decoder Foo
fooDecoder =
    decode Foo
        |> required "bar" string
```

We can create a decoder test like so:

```
fooJson =
"""
    {"bar": "test string"}
"""

decoderTest : Test
decoderTest =
    test "bar should be correctly decoded" <|
        \_ ->
            fooJson
                |> Json.decodeString fooDecoder
                |> Expect.equal
                    (Ok { bar = "test string" })
```

The left and right applicative operator is used heavily throughout testing to reduce parenthesis usage, which could become overwhelming quickly.

It is straightforward to plug our decoderTest into the test suite.

```
suite =
    decoderTest
```

However, elm-test provides an exceptionally useful function called `describe`. This takes a string descriptor, and a list of tests, and returns a single test. This makes it able to be nested, much like a div.

Using `describe`, our test suite now looks like this:

```
suite =
    describe "Test suite"
        [ describe "decoder tests"
            [ decoderTest
            , ...
            ]
        , ...
        ]
```

Now if we jump back to our command line, we can run our test suite using the npm script we defined.

```
npm run test
```

And we'll see the results of our tests in the terminal

```
elm-test
--------

Running 1 test. To reproduce these results, run: elm-test --fuzz 100 --seed 1218401866


TEST RUN PASSED

Duration: 37 ms
Passed:   1
Failed:   0
```

## Fuzz Tests

Elm-test provides a mechanism for testing a large number of randomly generated inputs. This is called "Fuzzing" or "Generative Testing".

```
fuzz string "newEntry generates a correct Entry" <|
            \fuzzInput ->
            [ ( "bar", Encode.string fuzzInput ) ]
                |> Json.Encode.object
                |> Json.decodeValue fooDecoder
                |> Expect.equal (Ok { bar = fuzzInput })
```

Although Fuzz testing seems like it would be very useful, in practice, I've found that relatively few tests benefit from it. Although to be fair, they are very easy to implement, so wiring up your decoder tests to use Fuzzers instead of static Json might be a fruitful endeavour.

## Testing the Update Function

Since the update function in Elm isn't special, it can be tested like any other function.

```
update : Msg -> Model -> ( Model, Cmd Msg )
```

To do so we simply define the starting model, pass it and a message into update, and check that it matches the resulting output model.

```
test "correctly adds an entry" <|
                \_ ->
                    let
                        initialModel =
                            { ...
                            }

                        updatedModel =
                            { ...
                            }
                    in
                        initialModel
                            |> update (SomeMessage)
                            |> Tuple.first
                            |> Expect.equal updatedModel
```

If you're careful, however, you'll notice that I used Tuple.first to check the model, but did not check the Cmd Msg. There is a reason for this.

Currently, elm-test does not support testing commands. This is a shortcoming that is being addressed, but isn't complete yet. There is a work around, though it involves modifying your actual application code. If you make a union type to represent all the possible commands your application runs, then write functions that convert those Commands to a Cmd Msg, you can examine them using Expect.equal.

This is a stopgap measure, and the advice of Richard Feldman himself is to hold off on testing your commands in this way. Such is the price we pay for a young, vibrant language.

## Testing the View

The package elm-html-test works well to test the view function. It provides utilities for reaching into the DOM and examining nodes. This is done by calling the Query.fromHtml function on your Html (your view), and using queries like find, findAll, and children to find elements in the page. Then you use Query.has and Query.count to create expectations.

The elm-html-test package is imported as Test.Html.Query, and it's common to alias it as Query. The test pipeline follows the general form:

```
test "foo has the expected text <|
    \_ ->
        let initialModel =
            { ...
            }
        in
            initialModel
                |> Bar.view
                |> Query.fromHtml
                |> Query.findAll [ tag "foo" ]
                |> Query.has [ text "expected text" ]

# Final Thoughts

A large part of the reason we enjoy working in Elm is the guarantees that it provides. The static typing ensures that we don't make certain mistakes, and the compiler ensures that we don't have run-time errors. It would be dangerous, however, to take these strengths and interpret it to mean that we don't have to test our code. Indeed, the facility for tests is another facet of the language that allows us to refactor confidently and write new code without the crippling fear of bugs.

