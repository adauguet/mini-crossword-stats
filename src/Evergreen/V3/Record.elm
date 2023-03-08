module Evergreen.V3.Record exposing (..)

import Evergreen.V3.Duration
import Set
import Time


type alias Record =
    { id : Int
    , duration : Evergreen.V3.Duration.Duration
    , date : Time.Posix
    , players : Set.Set String
    }
