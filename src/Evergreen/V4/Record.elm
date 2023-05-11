module Evergreen.V4.Record exposing (..)

import Evergreen.V4.Duration
import Set
import Time


type alias Record =
    { id : Int
    , duration : Evergreen.V4.Duration.Duration
    , date : Time.Posix
    , players : Set.Set String
    }
