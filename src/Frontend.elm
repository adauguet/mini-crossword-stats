module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Date
import Duration
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html
import Lamdera exposing (sendToBackend)
import Set exposing (Set)
import Task
import Time
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app :
    { init : Lamdera.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
    , view : Model -> Browser.Document FrontendMsg
    , update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
    , subscriptions : Model -> Sub FrontendMsg
    , onUrlRequest : UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    }
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init _ key =
    let
        players =
            [ "Antoine", "Eman", "Faraaz", "Mfon", "Waj" ]
    in
    ( { key = key
      , players = players
      , selectedPlayers = Set.fromList players
      , timeString = ""
      , records = Loading
      }
    , sendToBackend GetRecords
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External url ->
                    ( model, Nav.load url )

        UrlChanged _ ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        DidCheckPlayer player True ->
            ( { model | selectedPlayers = Set.insert player model.selectedPlayers }, Cmd.none )

        DidCheckPlayer player False ->
            ( { model | selectedPlayers = Set.remove player model.selectedPlayers }, Cmd.none )

        DidInputTime timeString ->
            ( { model | timeString = timeString }, Cmd.none )

        ClickedAddRecord ->
            case Duration.fromString model.timeString of
                Just duration ->
                    ( { model | timeString = "" }, Task.perform (GotNow duration) Time.now )

                Nothing ->
                    ( model, Cmd.none )

        GotNow duration now ->
            ( case model.records of
                Loaded records ->
                    { model | records = Loaded <| { id = -1, duration = duration, date = now, players = model.selectedPlayers } :: records }

                Loading ->
                    model
            , sendToBackend (CreateNewRecord duration now model.selectedPlayers)
            )

        ClickedDelete id ->
            ( case model.records of
                Loaded records ->
                    { model | records = Loaded <| List.filter (\record -> record.id /= id) records }

                Loading ->
                    model
            , sendToBackend (DeleteRecord id)
            )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        UpdateRecords records ->
            ( { model | records = Loaded records }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "Team Zen Results"
    , body =
        [ Element.layout
            [ Font.size 14
            , importFont "https://fonts.googleapis.com/css2?family=Roboto:wght@100;200;300;400;500;700;900&display=swap"
            , importFont "https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@100;200;300;400;500;700;900&display=swap"
            , Font.family [ Font.typeface "Roboto" ]
            ]
          <|
            case model.records of
                Loading ->
                    Element.el [ Element.centerX, Element.centerY ] <| Element.text "loading..."

                Loaded records ->
                    Element.column [ Element.centerX, Element.centerY, Element.spacing 64 ]
                        [ Element.column [ Element.spacing 4, Font.size 24 ]
                            [ Element.el [ Font.extraLight ] <| Element.text "Team Zen Results"
                            , Element.el [ Font.bold, Font.family [ Font.typeface "Roboto Slab", Font.serif ] ] <| Element.text "The Mini Crossword"
                            ]
                        , Element.column [ Element.spacing 64, Element.height Element.fill ]
                            [ Element.column
                                [ Element.height Element.fill
                                , Element.width (Element.px 100)
                                , Element.spacing 24
                                , Element.alignTop
                                ]
                                [ Element.column [ Element.spacing 8, Element.height Element.fill ]
                                    [ title "Players"
                                    , Element.row [ Element.spacing 16 ] <| List.map (checkbox model.selectedPlayers) model.players
                                    ]
                                , Input.text [ Element.width (Element.px 100), Font.alignRight ]
                                    { onChange = DidInputTime
                                    , text = model.timeString
                                    , placeholder = Nothing
                                    , label =
                                        Input.labelAbove []
                                            (Element.column [ Element.spacing 4 ]
                                                [ title "Time"
                                                , Element.el [ Font.size 12, Font.color (Element.rgb255 150 150 150) ] <| Element.text "Please use the following format: m:ss."
                                                ]
                                            )
                                    }
                                , Input.button
                                    [ Border.width 1
                                    , Element.paddingXY 16 8
                                    , Element.width Element.fill
                                    , Border.rounded 3
                                    , Font.center
                                    , Background.color (Element.rgb255 251 211 0)
                                    ]
                                    { onPress = Just ClickedAddRecord
                                    , label = Element.text "Add"
                                    }
                                ]
                            , case records of
                                [] ->
                                    Element.none

                                results ->
                                    Element.column [ Element.spacing 8 ]
                                        [ title "Results"
                                        , Element.table [ Element.height Element.fill, Element.spacingXY 16 8 ]
                                            { data = results
                                            , columns =
                                                [ { header = Element.none
                                                  , width = Element.shrink
                                                  , view = \{ date } -> Date.format "EEE, d MMM" (Date.fromPosix Time.utc date) |> Element.text
                                                  }
                                                , { header = Element.none
                                                  , width = Element.shrink
                                                  , view = \{ duration } -> Element.el [ Font.alignRight ] <| Element.text <| Duration.toString duration
                                                  }
                                                , { header = Element.none
                                                  , width = Element.shrink
                                                  , view = \{ players } -> Element.text <| String.join ", " <| Set.toList players
                                                  }
                                                , { header = Element.none
                                                  , width = Element.shrink
                                                  , view = \{ id } -> deleteButton id
                                                  }
                                                ]
                                            }
                                        ]
                            ]
                        ]
        ]
    }


minimum : comparable -> List comparable -> comparable
minimum x xs =
    case List.minimum xs of
        Just min ->
            Basics.min x min

        Nothing ->
            x


checkbox : Set String -> String -> Element FrontendMsg
checkbox selectedPlayers player =
    Input.checkbox []
        { onChange = DidCheckPlayer player
        , icon = Input.defaultCheckbox
        , checked = Set.member player selectedPlayers
        , label = Input.labelRight [] (Element.text player)
        }


deleteButton : Int -> Element FrontendMsg
deleteButton id =
    Input.button []
        { onPress = Just <| ClickedDelete id
        , label =
            Element.el
                [ Font.color (Element.rgb255 200 200 200)
                , Element.mouseOver [ Font.color <| Element.rgb255 0 0 0 ]
                ]
                (Element.text "delete")
        }


importFont : String -> Element.Attribute msg
importFont url =
    Html.node "style" [] [ Html.text <| "@import url('" ++ url ++ "')" ]
        |> Element.html
        |> Element.inFront


title : String -> Element msg
title text =
    Element.el
        [ Font.size 18
        , Font.bold
        , Font.family [ Font.typeface "Roboto Slab", Font.serif ]
        ]
        (Element.text text)
