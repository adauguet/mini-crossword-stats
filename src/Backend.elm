module Backend exposing (..)

import Duration exposing (Duration(..))
import Env
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
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
                    List.range 0 99
                        |> List.map
                            (\id ->
                                { id = id
                                , duration = Duration ((id * 5 |> modBy 180) + 120)
                                , date =
                                    Parts 2023 Jan 1 12 0 0 0
                                        |> Time.Extra.partsToPosix Time.utc
                                        |> Time.Extra.add Day id Time.utc
                                , players =
                                    Set.fromList [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
                                }
                            )

                Env.Production ->
                    []
      , nextId = 0
      }
    , Cmd.none
    )


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
