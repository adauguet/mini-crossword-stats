module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Dom
import Browser.Navigation exposing (Key)
import Duration exposing (Duration)
import Record exposing (Record)
import Set exposing (Set)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , players : List String
    , selectedPlayers : Set String
    , timeString : String
    , records : Records
    , results : Results
    }


type Records
    = Loading
    | Loaded (List Record)


type Results
    = Chart
    | List


type alias BackendModel =
    { records : List Record
    , nextId : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | DidCheckPlayer String Bool
    | DidInputTime String
    | ClickedAddRecord
    | GotNow Duration Posix
    | ClickedDelete Int
    | DidFocus (Result Browser.Dom.Error ())
    | SelectChart
    | SelectList


type ToBackend
    = CreateNewRecord Duration Posix (Set String)
    | GetRecords
    | DeleteRecord Int


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateRecords (List Record)
