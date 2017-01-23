module MyViews exposing (..)

import Html exposing (..)
import Html.Attributes
    exposing
        ( attribute
        , class
        , src
        , width
        , height
        )

import Json.Decode exposing (Decoder, string, array)
import Json.Decode.Pipeline exposing (decode, required)
import Array exposing (..)



-- Video Stuff

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

videoFile : Maybe VidInfo -> List (Html msg)
videoFile maybe_info =
    case maybe_info of
        Nothing ->
            [ text "No (valid) video number selected" ]

        Just info ->
            [ h2 [] [ text info.title ]
            -- These assets are only hosted on DreamHost currently
            , video
              [ src info.url
              -- XXX We may want to intercept controls in Elm?
              , attribute "controls" ""
              -- The width built-in expects a number
              , attribute "width" "100%" ]
              []
            ]

