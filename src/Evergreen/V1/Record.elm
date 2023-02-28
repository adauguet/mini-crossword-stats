module Evergreen.V1.Record exposing (..)

import Set
import Time


type alias Record =
    { id : Int
    , time : Float
    , date : Time.Posix
    , players : Set.Set String
    }
