module Evergreen.V3.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V3.Duration
import Evergreen.V3.Record
import Set
import Time
import Url


type Records
    = Loading
    | Loaded (List Evergreen.V3.Record.Record)


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , players : List String
    , selectedPlayers : Set.Set String
    , timeString : String
    , records : Records
    }


type alias BackendModel =
    { records : List Evergreen.V3.Record.Record
    , nextId : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | DidCheckPlayer String Bool
    | DidInputTime String
    | ClickedAddRecord
    | GotNow Evergreen.V3.Duration.Duration Time.Posix
    | ClickedDelete Int
    | DidFocus (Result Browser.Dom.Error ())


type ToBackend
    = CreateNewRecord Evergreen.V3.Duration.Duration Time.Posix (Set.Set String)
    | GetRecords
    | DeleteRecord Int


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateRecords (List Evergreen.V3.Record.Record)
