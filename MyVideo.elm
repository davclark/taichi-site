module MyVideo exposing (..)

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
import Html.Events exposing (on, onClick)

import Http
import Json.Decode exposing (Decoder, string, array)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode exposing (encode, bool)

import Array exposing (..)
import List



-- MODEL

type alias Model =
        { videos : Array VidInfo
        , selected : Int
        , status : String
        , playing : Bool
        }

-- For now we only allow some pretty basic customization
type alias VidInfo =
    { title : String, url : String }

init =
    { videos = empty
    , selected = 0
    , status = "Initialized"
    , playing = False
    }



-- Messages

type Msg
    = NewVidInfo (Result Http.Error (Array VidInfo))
    | SetVidNum Int
    | VidPlaying Bool

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetVidNum num ->
            if (num >= 0) && (num < (length model.videos)) then
                ( { model | selected = num }, Cmd.none )
            else
                ( model, Cmd.none )

        NewVidInfo (Ok jsonData) ->
            ( { model | videos = jsonData
              , status = "Updated"
              }
            , Cmd.none
            )

        NewVidInfo (Err msg) ->
            ( { model | status = toString msg }, Cmd.none )

        VidPlaying playing ->
            ( { model | playing = playing } , Cmd.none)
-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        "Updated" ->
            div [] (List.concat
             [ [text "Select: "]
             -- Buttons
             , List.map numButton
                 (List.range 1 (length model.videos))
             -- actual video
            -- XXX need logic here to check for file vs. IFrame
             , videoFile model
             ])

        _ ->
            div [] [text model.status]


-- This is using the more recently developed pipeline approach from NoRedInk
decodeSession : Decoder (Array VidInfo)
decodeSession =
    array
        (decode VidInfo
            |> required "title" string
            |> required "url" string
        )

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

numButton : Int -> Html Msg
numButton num =
    button [ onClick (SetVidNum (num - 1)) ]
           [ text (toString num) ]

maybeAutoplay aYep =
    if aYep then
        [ attribute "autoplay" "" ]
    else
        []

videoFile : Model -> List (Html Msg)
videoFile model =
    let
        maybe_info = get model.selected model.videos

    in
        case maybe_info of
            Nothing ->
                [ text "No (valid) video number selected" ]

            Just info ->
                [ h2 [] [ text info.title ]
                -- These assets are only hosted on DreamHost currently
                , video
                  (List.append
                      [ src info.url
                      , attribute "controls" ""
                      -- The width built-in expects a number
                      , attribute "width" "100%"
                      -- This line seems particularly annoying
                      , onPlaying (VidPlaying True)
                      , onPause (VidPlaying False)
                      , onEnded (SetVidNum (model.selected + 1))
                      ]
                      (maybeAutoplay model.playing)
                  )
                  [
                     --  source
                     -- [ attribute "src" info.url
                     -- , type_ "video/mp4"
                     -- ]
                     -- []
                  ]
                ]

-- HTTP


getClassInfo : String -> Cmd Msg
getClassInfo session =
    let
        url =
            "/class_info/" ++ session ++ ".json"
    in
        Http.send NewVidInfo (Http.get url decodeSession )
