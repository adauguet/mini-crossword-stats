module DurationTest exposing (..)

import Duration
import Expect
import Fuzz exposing (int)
import Test exposing (Test, describe, fuzz2)


suite : Test
suite =
    let
        formatPadLeft0 int =
            String.padLeft 2 '0' (String.fromInt int)
    in
    describe "parsing"
        [ fuzz2 (Fuzz.intRange 0 59) (Fuzz.intRange 0 59) "fuzz" <|
            \minutes seconds ->
                Expect.equal
                    (Maybe.map Duration.toSeconds <| Duration.fromString (String.fromInt minutes ++ ":" ++ formatPadLeft0 seconds))
                    (Just <| minutes * 60 + seconds)
        , fuzz2 (Fuzz.intRange 0 59) (Fuzz.intRange 0 59) "fuzz with zeros left padding on minutes" <|
            \minutes seconds ->
                Expect.equal
                    (Maybe.map Duration.toSeconds <| Duration.fromString (formatPadLeft0 minutes ++ ":" ++ formatPadLeft0 seconds))
                    (Just <| minutes * 60 + seconds)
        ]
