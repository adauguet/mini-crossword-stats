module Record exposing (..)

import Duration exposing (Duration)
import Set exposing (Set)
import Time exposing (Posix)


type alias Record =
    { id : Int
    , duration : Duration
    , date : Posix
    , players : Set String
    }
