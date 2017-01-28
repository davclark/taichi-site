module Main exposing (..)

import Html exposing (..) -- includes program
import Html.Attributes
    exposing
        ( name
        , style
        , type_
        , src
        , attribute
        , height
        )
import Html.Events exposing (onClick)
import Http

import Array exposing (Array, get, length, empty)

import MyViews exposing (VidInfo, VidModel, initVidModel,
                         decodeSession, videoFile)

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { warmup : VidModel
    , form : VidModel
    , status : String
    }


init : ( Model, Cmd Msg )
init =
    ( { warmup = initVidModel
      , form = initVidModel
      , status = "Initialized"
      }
    , Cmd.batch [ getClassInfo NewWarmupInfo "yoga"
                , getClassInfo NewFormInfo "current"
                ]
    )



-- UPDATE


type Msg
    = NewFormInfo (Result Http.Error (Array VidInfo))
    | NewWarmupInfo (Result Http.Error (Array VidInfo))
    | SetWeek Int
    | SetWarmup Int
    | WarmupPlaying

updateSelected subModel num =
    {subModel | selected = num }


updateVideos subModel videos =
    -- We also reset selected to the first video
    -- Out-of-bounds checking is handled under the view in videoIFrame
    { subModel | videos = videos, selected = 0 }

updatePlaying subModel playing =
    { subModel | playing = playing }
 
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWeek num ->
            ( { model | form = updateSelected model.form num }, Cmd.none )

        SetWarmup num ->
            ( { model | warmup = updateSelected model.warmup num }, Cmd.none )

        NewFormInfo (Ok jsonData) ->
            ( { model | form = updateVideos model.form jsonData
              , status = "Updated"
              }
            , Cmd.none
            )

        NewWarmupInfo (Ok jsonData) ->
            ( { model | warmup = updateVideos model.warmup jsonData
              , status = "Updated"
              }
            , Cmd.none
            )

        NewFormInfo (Err msg) ->
            ( { model | status = toString msg }, Cmd.none )

        NewWarmupInfo (Err msg) ->
            ( { model | status = toString msg }, Cmd.none )

        WarmupPlaying ->
            ( { model | warmup = updatePlaying model.warmup True } , Cmd.none)
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
          [ -- Warmups
            (text "Warmup: "
              :: List.map (numButton SetWarmup)
                          (List.range 1 (length model.warmup.videos))
            )
          , (videoFile model.warmup WarmupPlaying)

            -- Form
            -- , (text "Select week: "
            --     :: List.map numButton (List.range 1 (length model.form))
            --   )
          , (videoFile model.form WarmupPlaying)
          , journal
          ]
        )


numButton : (Int -> Msg) -> Int -> Html Msg
numButton target num =
    button [ onClick (target (num - 1)) ] [ text (toString num) ]

journal =
    [ h1 [] [ text "Take credit: Journal your practice!"]
      , iframe
        [ src ("https://docs.google.com/forms/d/e/" ++
               "1FAIpQLSeYzzZNa_3IdwqNRqX1ESqlPdkRaDXuPxA5-iE5kkxx5KEdpw" ++
               "/viewform?embedded=true")
        , attribute "width" "100%"
        , height 1721
        , attribute "frameborder" "0"
        , attribute "marginheight" "0"
        ]
        [ text "Loading..." ]
      ]

-- SUBSCRIPTIONS - currently unused


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getClassInfo : (Result Http.Error (Array VidInfo) -> Msg) -> String -> Cmd Msg
getClassInfo msgType session =
    let
        url =
            "/class_info/" ++ session ++ ".json"
    in
        Http.send msgType (Http.get url decodeSession )
