module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Evergreen.V1.Record
import Set
import Time
import Url


type Records
    = Loading
    | Loaded (List Evergreen.V1.Record.Record)


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , players : List String
    , selectedPlayers : Set.Set String
    , timeString : String
    , records : Records
    }


type alias BackendModel =
    { records : List Evergreen.V1.Record.Record
    , nextId : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | DidCheckPlayer String Bool
    | DidInputTime String
    | ClickedAddRecord
    | GotNow Float Time.Posix
    | ClickedDelete Int


type ToBackend
    = CreateNewRecord Float Time.Posix (Set.Set String)
    | GetRecords
    | DeleteRecord Int


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateRecords (List Evergreen.V1.Record.Record)
