module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Navigation as Nav
import Chart as C
import Chart.Attributes as CA
import Date
import Duration
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Lamdera exposing (sendToBackend)
import Record exposing (Record)
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
      , results = Chart
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

        DidCheckPlayer player True ->
            ( { model | selectedPlayers = Set.insert player model.selectedPlayers }, Cmd.none )

        DidCheckPlayer player False ->
            ( { model | selectedPlayers = Set.remove player model.selectedPlayers }, Cmd.none )

        DidInputTime timeString ->
            ( { model | timeString = timeString }, Cmd.none )

        ClickedAddRecord ->
            case Duration.fromString model.timeString of
                Just duration ->
                    ( { model | timeString = "" }
                    , Cmd.batch
                        [ Task.perform (GotNow duration) Time.now
                        , Task.attempt DidFocus (Browser.Dom.focus "add-button")
                        ]
                    )

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

        DidFocus _ ->
            ( model, Cmd.none )

        SelectChart ->
            ( { model | results = Chart }, Cmd.none )

        SelectList ->
            ( { model | results = List }, Cmd.none )


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
                                , Input.text
                                    [ Element.width (Element.px 100)
                                    , Font.alignRight
                                    , onEnter ClickedAddRecord
                                    ]
                                    { onChange = DidInputTime
                                    , text = model.timeString
                                    , placeholder = Just <| Input.placeholder [] <| Element.text "m:ss"
                                    , label = Input.labelAbove [] <| title "Time"
                                    }
                                , Input.button
                                    [ Border.width 1
                                    , Element.paddingXY 16 8
                                    , Element.width Element.fill
                                    , Border.rounded 3
                                    , Font.center
                                    , Background.color (Element.rgb255 251 211 0)
                                    , Element.htmlAttribute (Html.Attributes.id "add-button")
                                    ]
                                    { onPress = Just ClickedAddRecord
                                    , label = Element.text "Add"
                                    }
                                ]
                            , case records of
                                [] ->
                                    Element.none

                                results ->
                                    Element.column [ Element.spacing 20 ]
                                        [ Element.row [ Element.width Element.fill ]
                                            [ title "Results"
                                            , Element.row
                                                [ Border.width 1
                                                , Border.rounded 3
                                                , Element.clip
                                                , Element.height (Element.px 22)
                                                , Element.alignRight
                                                ]
                                                [ Input.button
                                                    [ Element.paddingXY 8 4
                                                    , if model.results == Chart then
                                                        Background.color (Element.rgb255 251 211 0)

                                                      else
                                                        Background.color (Element.rgb255 255 255 255)
                                                    ]
                                                    { onPress = Just SelectChart
                                                    , label = Element.text "Chart"
                                                    }
                                                , Element.el
                                                    [ Background.color (Element.rgb255 0 0 0)
                                                    , Element.width (Element.px 1)
                                                    , Element.height Element.fill
                                                    ]
                                                    Element.none
                                                , Input.button
                                                    [ Element.paddingXY 8 4
                                                    , if model.results == List then
                                                        Background.color (Element.rgb255 251 211 0)

                                                      else
                                                        Background.color (Element.rgb255 255 255 255)
                                                    ]
                                                    { onPress = Just SelectList
                                                    , label = Element.text "List"
                                                    }
                                                ]
                                            ]
                                        , Element.el
                                            [ Element.height (Element.px 300)
                                            , Element.width (Element.px 500)
                                            ]
                                          <|
                                            case model.results of
                                                Chart ->
                                                    chart results

                                                List ->
                                                    table results
                                        ]
                            ]
                        ]
        ]
    }


chart : List Record -> Element msg
chart results =
    Element.html <|
        C.chart
            [ CA.height 300
            , CA.width 500
            ]
            [ C.xAxis []
            , C.xTicks [ CA.times Time.utc ]
            , C.xLabels [ CA.times Time.utc ]
            , C.yAxis []
            , C.yTicks []
            , C.yLabels
                [ CA.withGrid
                , CA.format formatYLabel
                , CA.amount 8
                ]
            , C.bars [ CA.x1 (.date >> Time.posixToMillis >> toFloat) ]
                [ C.bar (.duration >> Duration.toSeconds >> toFloat) [ CA.color "#4688F0" ]
                ]
                results
            ]


table : List Record -> Element FrontendMsg
table results =
    Element.table
        [ Element.spacingXY 20 10
        , Element.clipY
        , Element.scrollbarY
        , Element.height (Element.px 300)
        ]
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


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Json.Decode.succeed msg

                        else
                            Json.Decode.fail "Not the enter key"
                    )
            )
        )


formatYLabel : Float -> String
formatYLabel f =
    let
        s =
            floor f
    in
    (String.fromInt <| s // 60) ++ ":" ++ (String.padLeft 2 '0' <| String.fromInt <| modBy 60 s)
