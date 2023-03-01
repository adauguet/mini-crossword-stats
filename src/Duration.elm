module Duration exposing (Duration(..), fromString, toSeconds, toString)

import Parser exposing ((|.), (|=), Parser)


type Duration
    = Duration Int


toString : Duration -> String
toString (Duration seconds) =
    String.fromInt (seconds // 60) ++ ":" ++ String.padLeft 2 '0' (String.fromInt (modBy 60 seconds))


fromString : String -> Maybe Duration
fromString string =
    case Parser.run parser string of
        Ok duration ->
            Just duration

        Err _ ->
            Nothing


toSeconds : Duration -> Int
toSeconds (Duration seconds) =
    seconds


parser : Parser Duration
parser =
    Parser.succeed (\minutes seconds -> Duration <| minutes * 60 + seconds)
        |= zeroToFiftyNineInt
        |. Parser.symbol ":"
        |= zeroToFiftyNineIntWithLeftPadding
        |. Parser.end


zeroToFiftyNineIntWithLeftPadding : Parser Int
zeroToFiftyNineIntWithLeftPadding =
    Parser.succeed ()
        |. Parser.chompIf (\c -> List.member c [ '0', '1', '2', '3', '4', '5' ])
        |. Parser.chompIf Char.isDigit
        |> Parser.getChompedString
        |> Parser.andThen
            (\str ->
                case String.toInt str of
                    Just int ->
                        Parser.succeed int

                    Nothing ->
                        Parser.problem "Could not cast to Int"
            )


zeroToFiftyNineInt : Parser Int
zeroToFiftyNineInt =
    Parser.succeed ()
        |. Parser.chompIf Char.isDigit
        |. Parser.chompWhile Char.isDigit
        |> Parser.getChompedString
        |> Parser.andThen
            (\str ->
                case String.toInt str of
                    Just int ->
                        if int < 0 || int >= 60 then
                            Parser.problem "Int is not in range 0..59"

                        else
                            Parser.succeed int

                    Nothing ->
                        Parser.problem "Could not cast to Int"
            )
