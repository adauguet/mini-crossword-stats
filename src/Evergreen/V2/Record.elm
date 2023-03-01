module Evergreen.V2.Record exposing (..)

import Evergreen.V2.Duration
import Set
import Time


type alias Record =
    { id : Int
    , duration : Evergreen.V2.Duration.Duration
    , date : Time.Posix
    , players : Set.Set String
    }
