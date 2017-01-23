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

import MyViews exposing (VidInfo, decodeSession, videoFile)

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { warmup : Array VidInfo
    , form : Array VidInfo
    , status : String
    , selectedForm : Int
    , selectedWarmup : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { warmup = empty
      , form = empty
      , status = "Initialized"
      , selectedForm = 0
      , selectedWarmup = 0
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWeek num ->
            ( { model | selectedForm = num }, Cmd.none )

        SetWarmup num ->
            ( { model | selectedWarmup = num }, Cmd.none )

        NewFormInfo (Ok jsonData) ->
            -- Note we always reset selectedForm to 0 here
            -- Out-of-bounds checking is handled under the view in videoIFrame
            ( { model | form = jsonData, selectedForm = 0, status = "Updated" }
            , Cmd.none
            )

        NewFormInfo (Err msg) ->
            ( { model | status = toString msg }, Cmd.none )


        NewWarmupInfo (Ok jsonData) ->
            -- Note we always reset selectedForm to 0 here
            -- Out-of-bounds checking is handled under the view in videoIFrame
            ( { model | warmup = jsonData, selectedWarmup = 0, status = "Updated" }
            , Cmd.none
            )

        NewWarmupInfo (Err msg) ->
            ( { model | status = toString msg }, Cmd.none )
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
                          (List.range 1 (length model.warmup))
            )
          , (videoFile (get model.selectedWarmup model.warmup))

            -- Form
            -- , (text "Select week: "
            --     :: List.map numButton (List.range 1 (length model.form))
            --   )
          , (videoFile (get model.selectedForm model.form))
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



