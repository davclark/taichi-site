module Main exposing (..)

import Html exposing (..)
import MyVideo


main : Program Never MyVideo.Model MyVideo.Msg
main =
    Html.program
        { init = init
        , view = MyVideo.view
        , update = MyVideo.update
            -- view and update fully defined in MyVideo
        , subscriptions = subscriptions
        }



-- MODEL
-- Note that the Model itself is already defined in MyVideo


init : ( MyVideo.Model, Cmd MyVideo.Msg )
init =
    ( MyVideo.init "Extra materials" True
    , MyVideo.getClassInfo "extra"
    )



-- SUBSCRIPTIONS - currently unused


subscriptions : MyVideo.Model -> Sub MyVideo.Msg
subscriptions model =
    Sub.none
