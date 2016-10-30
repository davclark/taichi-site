import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
-- I have no idea how to import :=
import Json.Decode exposing (..)
import Json.Encode as Encode
import Task
import Array exposing (..)



main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias VidInfo = {title : String, url: String}
type alias Model = { warmup : VidInfo
                   , form: Array VidInfo
                   , status: String
                   , selected: Int }


warmup = {
    title = "Taichi warmup",
    url = "//player.vimeo.com/video/119411037"}

init : (Model, Cmd Msg)
init =
  ( {warmup = warmup, form = empty, status = "Initialized", selected = 0}
  , getClassInfo "tue+thu"
  )

-- UPDATE

type Msg
  = FetchSucceed (Array VidInfo)
  | FetchFail Http.Error
  | SetWeek Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetWeek num ->
            ({model | selected = num}, Cmd.none)

        FetchSucceed jsonData ->
            -- Note we always reset selected to 0 here
            -- Out-of-bounds checking is handled under the view in vimeo
            ( { model | form = jsonData, selected = 0 , status = "Updated"}
            , Cmd.none )

        FetchFail msg ->
            ({model | status = toString msg}, Cmd.none)


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
    div [] (List.append
    [ text "Select week: "
    -- Want to auto-generate something like this:
    -- , button [ onClick Week 0 ] [ text "1" ]
    ]
    (vimeo (get model.selected model.form)) )

vimeo : Maybe VidInfo -> List (Html Msg)
vimeo maybe_info =
    case maybe_info of
        Nothing ->
            [text "No (valid) video number selected"]

        Just info ->
            [ h2 [] [text info.title]
            , div [class "videoWrapper"] [
                iframe [src info.url, width 500, height 282,
                        attribute "frameborder" "0",
                        attribute "webkitallowfullscreen" "true",
                        attribute "mozallowfullscreen" "true",
                        attribute "allowfullscreen" "true"] []
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
    url = "/class_info/" ++ session ++ ".json"
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeSession url)

decodeSession : Decoder (Array VidInfo)
decodeSession =
    Json.Decode.array (object2 VidInfo ("title" := string) ("url" := string))
