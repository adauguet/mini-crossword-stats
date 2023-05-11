module Backend exposing (..)

import Duration exposing (Duration(..))
import Env
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Record exposing (Record)
import Set
import Time exposing (Month(..))
import Time.Extra exposing (Interval(..), Parts)
import Types exposing (..)


type alias Model =
    BackendModel


type alias App =
    { init : ( Model, Cmd BackendMsg )
    , update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
    , subscriptions : Model -> Sub BackendMsg
    }


app : App
app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \_ -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { records =
            case Env.mode of
                Env.Development ->
                    list

                Env.Production ->
                    []
      , nextId = 0
      }
    , Cmd.none
    )


list : List Record
list =
    [ { id = 0
      , duration = Duration (1 * 60 + 38)
      , date = Parts 2023 Feb 28 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon" ]
      }
    , { id = 0
      , duration = Duration (3 * 60 + 28)
      , date = Parts 2023 Mar 1 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Waj" ]
      }
    , { id = 0
      , duration = Duration (3 * 60 + 17)
      , date = Parts 2023 Mar 2 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Waj" ]
      }
    , { id = 0
      , duration = Duration (6 * 60 + 21)
      , date = Parts 2023 Mar 6 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Waj" ]
      }
    , { id = 0
      , duration = Duration (3 * 60 + 30)
      , date = Parts 2023 Mar 7 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Waj" ]
      }
    , { id = 0
      , duration = Duration (5 * 60 + 5)
      , date = Parts 2023 Mar 8 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 20)
      , date = Parts 2023 Mar 9 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Eman", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 10)
      , date = Parts 2023 Mar 10 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 35)
      , date = Parts 2023 Mar 14 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 5)
      , date = Parts 2023 Mar 15 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 31)
      , date = Parts 2023 Mar 16 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (3 * 60 + 18)
      , date = Parts 2023 Mar 21 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 53)
      , date = Parts 2023 Mar 28 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 49)
      , date = Parts 2023 Mar 29 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 59)
      , date = Parts 2023 Mar 30 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 49)
      , date = Parts 2023 Apr 3 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 54)
      , date = Parts 2023 Apr 4 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 44)
      , date = Parts 2023 Apr 5 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (0 * 60 + 59)
      , date = Parts 2023 Apr 10 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 21)
      , date = Parts 2023 Apr 11 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Eman", "Faraaz", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 11)
      , date = Parts 2023 Apr 12 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 51)
      , date = Parts 2023 Apr 24 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 29)
      , date = Parts 2023 Apr 25 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (3 * 60 + 6)
      , date = Parts 2023 Apr 26 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 23)
      , date = Parts 2023 Apr 27 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 0)
      , date = Parts 2023 May 2 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 25)
      , date = Parts 2023 May 3 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (1 * 60 + 43)
      , date = Parts 2023 May 4 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    , { id = 0
      , duration = Duration (2 * 60 + 49)
      , date = Parts 2023 May 8 12 0 0 0 |> Time.Extra.partsToPosix Time.utc
      , players = Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
      }
    ]


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend _ clientId msg model =
    case msg of
        CreateNewRecord duration date players ->
            let
                records =
                    { id = model.nextId, duration = duration, date = date, players = players } :: model.records
            in
            ( { model | records = records, nextId = model.nextId + 1 }, broadcast (UpdateRecords records) )

        GetRecords ->
            ( model, sendToFrontend clientId (UpdateRecords model.records) )

        DeleteRecord id ->
            let
                records =
                    List.filter (\record -> record.id /= id) model.records
            in
            ( { model | records = records }, broadcast (UpdateRecords records) )
