module Record exposing (..)

import Set exposing (Set)
import Time exposing (Posix)


type alias Record =
    { id : Int
    , time : Float
    , date : Posix
    , players : Set String
    }
