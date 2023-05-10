module Record exposing (Record)

import Duration exposing (Duration(..))
import Set exposing (Set)
import Time exposing (Month(..), Posix)


type alias Record =
    { id : Int
    , duration : Duration
    , date : Posix
    , players : Set String
    }
