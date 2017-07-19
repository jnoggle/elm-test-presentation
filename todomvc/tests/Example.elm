module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, bool)
import Test exposing (..)
import Todo exposing (..)


suite : Test
suite =
    describe "Todo MVC"
        [ test "emptyModel evaluates to the correct empty model" <|
            \_ ->
                let
                    expectedModel =
                        { entries = []
                        , field = ""
                        , uid = 0
                        , visibility = "All"
                        }
                in
                    Expect.equal expectedModel emptyModel
        , fuzz2 string int "newEntry generates a correct Entry" <|
            \desc id ->
                let
                    expectedNewEntry =
                        { description = desc
                        , completed = False
                        , editing = False
                        , id = id
                        }
                in
                    Expect.equal expectedNewEntry (newEntry desc id)
        , describe "Update"
            [ test "correctly adds an entry" <|
                \_ ->
                    let
                        oldModel =
                            { uid = 1
                            , field = "New Task"
                            , entries = []
                            , visibility = "All"
                            }

                        updatedModel =
                            { uid = 2
                            , field = ""
                            , entries = [ newEntry oldModel.field oldModel.uid ]
                            , visibility = "All"
                            }
                    in
                        Expect.equal (update Add oldModel) ( updatedModel, Cmd.none )
            ]
        ]
