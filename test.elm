import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
-- I have no idea how to import :=
import Json.Decode exposing (..)
import Json.Encode as Encode
import Task



main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias VidInfo = {title : String, url: String}
type alias Model = { warmup : VidInfo
                   , form: List VidInfo
                   , status: String }


warmup = {
    title = "Taichi warmup",
    url = "//player.vimeo.com/video/119411037"}

init : (Model, Cmd Msg)
init =
  ( {warmup = warmup, form = [], status = "Initialized"}
  , getClassInfo "tue+thu"
  )

-- UPDATE

type Msg
  = SwitchSession
  | FetchSucceed (List VidInfo)
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SwitchSession ->
            ({model | status = "Switch!"}, Cmd.none)

        FetchSucceed jsonData ->
            ({model | form = jsonData}, Cmd.none)

        FetchFail msg ->
            ({model | status = toString msg}, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
        text model.status


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- HTTP

getClassInfo : String -> Cmd Msg
getClassInfo session =
  let
    url = "/class_info/" ++ session ++ ".json"
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeSession url)

decodeSession : Decoder (List VidInfo)
decodeSession =
    Json.Decode.list (object2 VidInfo ("title" := string) ("url" := string))
