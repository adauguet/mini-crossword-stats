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
    }


type Records
    = Loading
    | Loaded (List Record)


type alias BackendModel =
    { records : List Record
    , nextId : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | DidCheckPlayer String Bool
    | DidInputTime String
    | ClickedAddRecord
    | GotNow Duration Posix
    | ClickedDelete Int
    | DidFocus (Result Browser.Dom.Error ())


type ToBackend
    = CreateNewRecord Duration Posix (Set String)
    | GetRecords
    | DeleteRecord Int


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateRecords (List Record)
