module Evergreen.V2.Types exposing (..)

import Browser
import Browser.Navigation
import Evergreen.V2.Duration
import Evergreen.V2.Record
import Set
import Time
import Url


type Records
    = Loading
    | Loaded (List Evergreen.V2.Record.Record)


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , players : List String
    , selectedPlayers : Set.Set String
    , timeString : String
    , records : Records
    }


type alias BackendModel =
    { records : List Evergreen.V2.Record.Record
    , nextId : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | DidCheckPlayer String Bool
    | DidInputTime String
    | ClickedAddRecord
    | GotNow Evergreen.V2.Duration.Duration Time.Posix
    | ClickedDelete Int


type ToBackend
    = CreateNewRecord Evergreen.V2.Duration.Duration Time.Posix (Set.Set String)
    | GetRecords
    | DeleteRecord Int


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateRecords (List Evergreen.V2.Record.Record)
