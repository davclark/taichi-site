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

import Array exposing (Array, get, length, empty)

import MyVideo

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL

type alias Model =
    { warmup : MyVideo.Model
    , form : MyVideo.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { warmup = MyVideo.init
      , form = MyVideo.init
      }
    , Cmd.batch [ Cmd.map WarmupMsg (MyVideo.getClassInfo "yoga")
                , Cmd.map FormMsg (MyVideo.getClassInfo "current")
                ]
    )



-- UPDATE


type Msg
    = WarmupMsg MyVideo.Msg
    | FormMsg MyVideo.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WarmupMsg subMsg ->
            let
                ( updatedWarmupModel, warmupCmd ) =
                    MyVideo.update subMsg model.warmup
            in
                ( { model | warmup = updatedWarmupModel }
                  , Cmd.map WarmupMsg warmupCmd )

        FormMsg subMsg ->
            let
                ( updatedFormModel, formCmd ) =
                    MyVideo.update subMsg model.form
            in
                ( { model | form = updatedFormModel }
                  , Cmd.map FormMsg formCmd )



-- VIEW

view : Model -> Html Msg
view model =
    div []
        (List.concat
          [ -- Warmups
            [text "Warmup: "]
          , List.map (\num -> Html.map WarmupMsg (MyVideo.numButton num))
                     (List.range 1 (length model.warmup.videos))
          , [Html.map WarmupMsg (MyVideo.view model.warmup)]

            -- Form
            -- , (text "Select week: "
            --     :: List.map numButton (List.range 1 (length model.form))
            --   )
          , [Html.map FormMsg (MyVideo.view model.form)]
          , journal
          ]
        )


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
