module MyViews exposing (..)

import Html exposing (..)
import Html.Attributes
    exposing
        ( attribute
        , class
        , src
        , width
        , height
        , type_
        )
import Html.Events exposing (on)

import Json.Decode exposing (Decoder, string, array)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode exposing (encode, bool)
import Array exposing (..)
import List



-- Video Stuff

type alias VidModel =
        { videos : Array VidInfo
        , selected : Int
        , playing : Bool
        }

initVidModel =
    { videos = empty
    , selected = 0
    , playing = False
    }

-- For now we only allow some pretty basic customization
type alias VidInfo =
    { title : String, url : String }

-- This is using the more recently developed pipeline approach from NoRedInk
decodeSession : Decoder (Array VidInfo)
decodeSession =
    array
        (decode VidInfo
            |> required "title" string
            |> required "url" string
        )

videoIFrame : Maybe VidInfo -> List (Html msg)
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
                    , attribute "webkitallowfullscreen" ""
                    , attribute "mozallowfullscreen" ""
                    , attribute "allowfullscreen" ""
                    ]
                    []
                ]
            ]

-- General pattern for briefly stated event handlers
onEnded msg =
  on "ended" (Json.Decode.succeed msg)

onPlaying msg =
  on "playing" (Json.Decode.succeed msg)

onPause msg =
    on "pause" (Json.Decode.succeed msg)

maybeAutoplay aYep =
    if aYep then
        [ attribute "autoplay" "" ]
    else
        []

videoFile : VidModel -> msg -> List (Html msg)
videoFile vidModel playingMsg =
    let
        maybe_info = get vidModel.selected vidModel.videos

    in
        case maybe_info of
            Nothing ->
                [ text "No (valid) video number selected" ]

            Just info ->
                [ h2 [] [ text info.title ]
                -- These assets are only hosted on DreamHost currently
                , video
                  (List.append
                      [ attribute "controls" ""
                      -- The width built-in expects a number
                      , attribute "width" "100%"
                      -- This line seems particularly annoying
                      , onPlaying playingMsg
                      ]
                      (maybeAutoplay vidModel.playing)
                  )
                  [source
                     [ attribute "src" info.url
                     , type_ "video/mp4"
                     ]
                     []
                  ]
                ]

