module Main exposing (..)

-- For now I've removed the warmup video section for the content. I haven't
-- actually removed the code, as it can serve as a placeholder if we want to
-- add things back in

-- Html includes program

import Html exposing (..)
import Html.Attributes
    exposing
        ( name
        , style
        , type_
        , src
        , attribute
        , height
        )
import MyVideo


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { -- warmup : MyVideo.Model,
     form : MyVideo.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { -- warmup = MyVideo.init "Warmup" True,
       form = MyVideo.init "Form practice" False
      }
    , Cmd.batch
        [ -- Cmd.map WarmupMsg (MyVideo.getClassInfo "yoga"),
         Cmd.map FormMsg (MyVideo.getClassInfo "current")
        ]
    )



-- UPDATE


type Msg
    = FormMsg MyVideo.Msg
    -- | WarmupMsg MyVideo.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- These are boilerplates to dispatch messages to the Module level
    --     WarmupMsg subMsg ->
    --         let
    --             ( updatedWarmupModel, warmupCmd ) =
    --                 MyVideo.update subMsg model.warmup
    --         in
    --             ( { model | warmup = updatedWarmupModel }
    --             , Cmd.map WarmupMsg warmupCmd
    --             )

        FormMsg subMsg ->
            let
                ( updatedFormModel, formCmd ) =
                    MyVideo.update subMsg model.form
            in
                ( { model | form = updatedFormModel }
                , Cmd.map FormMsg formCmd
                )



-- VIEW


view : Model -> Html Msg
view model =
    -- A single point of mapping for each Msg branch makes us less likely to
    -- miss things (though it enforces a strong form of componentization)
    div []
        [ -- Html.map WarmupMsg (MyVideo.view model.warmup),
          Html.map FormMsg (MyVideo.view model.form)
        , journal_view
        ]


journal_view : Html Msg
journal_view =
    div []
        [ h1 [] [ text "Take credit: Journal your practice!" ]
        , iframe
            [ src
                ("https://docs.google.com/forms/d/e/"
                    ++ "1FAIpQLSeYzzZNa_3IdwqNRqX1ESqlPdkRaDXuPxA5-iE5kkxx5KEdpw"
                    ++ "/viewform?embedded=true"
                )
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
