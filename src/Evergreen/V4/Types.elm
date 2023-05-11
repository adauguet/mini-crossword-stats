module Evergreen.V4.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V4.Duration
import Evergreen.V4.Record
import Set
import Time
import Url


type Records
    = Loading
    | Loaded (List Evergreen.V4.Record.Record)


type Results
    = Chart
    | List


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , players : List String
    , selectedPlayers : Set.Set String
    , timeString : String
    , records : Records
    , results : Results
    }


type alias BackendModel =
    { records : List Evergreen.V4.Record.Record
    , nextId : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | DidCheckPlayer String Bool
    | DidInputTime String
    | ClickedAddRecord
    | GotNow Evergreen.V4.Duration.Duration Time.Posix
    | ClickedDelete Int
    | DidFocus (Result Browser.Dom.Error ())
    | SelectChart
    | SelectList


type ToBackend
    = CreateNewRecord Evergreen.V4.Duration.Duration Time.Posix (Set.Set String)
    | GetRecords
    | DeleteRecord Int


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | UpdateRecords (List Evergreen.V4.Record.Record)
