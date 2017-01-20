module Main exposing (..)

import Html exposing (..) -- includes program
import Html.Attributes
    exposing
        ( attribute
        , class
        , href
        , src
        , width
        , height
        , type_
        , name
        , style
        )
import Html.Events exposing (..)
import Http


-- I don't know how to import :=

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import Array exposing (..)


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias VidInfo =
    { title : String, url : String }


type alias Model =
    { warmup : VidInfo
    , form : Array VidInfo
    , status : String
    , selected : Int
    , classVersion : String
    }


warmup =
    { title = "Taichi warmup"
    , url = "//player.vimeo.com/video/119411037"
    }


init : ( Model, Cmd Msg )
init =
    ( { warmup = warmup
      , form = empty
      , status = "Initialized"
      , selected = 0
      , classVersion = "mon+wed"
      }
    , getClassInfo "mon+wed"
    )



-- UPDATE


type Msg
    = NewVidInfo (Result Http.Error (Array VidInfo))
    | SetWeek Int
    | SwitchClass String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWeek num ->
            ( { model | selected = num }, Cmd.none )

        NewVidInfo (Ok jsonData) ->
            -- Note we always reset selected to 0 here
            -- Out-of-bounds checking is handled under the view in videoIFrame
            ( { model | form = jsonData, selected = 0, status = "Updated" }
            , Cmd.none
            )

        NewVidInfo (Err msg) ->
            ( { model | status = toString msg }, Cmd.none )

        SwitchClass lab ->
            ( { model | classVersion = lab }, getClassInfo lab )



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        "Updated" ->
            dispVideos model

        _ ->
            text model.status


dispVideos : Model -> Html Msg
dispVideos model =
    div []
        (List.concat
            [ (videoIFrame (Just model.warmup))
            , classMsg
            , (text "Select week: "
                :: List.map weekButton (List.range 1 (length model.form))
              )
            , (videoIFrame (get model.selected model.form))
            ]
        )


classMsg =
    [ br [] []
    , p []
        [ strong [] [ text "Be sure to select your class below!" ]
        ]
    , fieldset []
        [ classChoice "mon+wed"
        , classChoice "tue+thu"
        ]
    ]


classChoice lab =
    label
        [ style [ ( "padding", "5px" ) ]
        ]
        [ input [ type_ "radio", name "class-session", onClick (SwitchClass lab) ] []
        , text lab
        ]


weekButton : Int -> Html Msg
weekButton num =
    button [ onClick (SetWeek (num - 1)) ] [ text (toString num) ]


videoIFrame : Maybe VidInfo -> List (Html Msg)
videoIFrame maybe_info =
    case maybe_info of
        Nothing ->
            [ text "No (valid) video number selected" ]

        Just info ->
            [ h2 [] [ text info.title ]
            , div [ class "videoWrapper" ]
                [ iframe
                    [ src info.url
                    , width 500
                    , height 282
                    , attribute "frameborder" "0"
                    , attribute "webkitallowfullscreen" "true"
                    , attribute "mozallowfullscreen" "true"
                    , attribute "allowfullscreen" "true"
                    ]
                    []
                ]
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getClassInfo : String -> Cmd Msg
getClassInfo session =
    let
        url =
            "/class_info/" ++ session ++ ".json"
    in
        Http.send NewVidInfo (Http.get url decodeSession )



-- This is using the more recently developed pipeline approach from NoRedInk


decodeSession : Decoder (Array VidInfo)
decodeSession =
    Json.Decode.array
        (decode VidInfo
            |> required "title" string
            |> required "url" string
        )
