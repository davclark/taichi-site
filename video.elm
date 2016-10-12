import Html exposing (Html, button, div, text, h2, iframe)
import Html.Attributes exposing (attribute, src, width, height)
import Html.App as App
import Html.Events exposing (onClick)
import Json.Encode as Json

main =
  App.beginnerProgram { model = model, view = view, update = update }

-- Useful data


warmup = {
    title = "Taichi warmup",
    url = "//player.vimeo.com/video/119411037"}

form = {
      week1 =
       {title = "Week 1: Opening",
        url = "//player.vimeo.com/video/119410170"}
    , week2 =
       {title = "Week 2: Grasping the bird's tail, first way",
        url = "//player.vimeo.com/video/119410628"}
    , week3 =
       {title = "Week 3: Playing the guitar",
        url = "//player.vimeo.com/video/119411033"}
    , week4 =
       {title = "Week 4: Grasping the bird's tail, second way",
        url = "//player.vimeo.com/video/119410165"}
    , week5 =
       {title = "Week 5: Simple whip",
        url = "//player.vimeo.com/video/119410625"}
    , week6 =
       {title = "Week 6: Opening the arms",
        url = "//player.vimeo.com/video/119410627"}
    , week7 =
       {title = "Week 7: Roll / Closing the form",
        url = "//player.vimeo.com/video/119410167"}
    }


-- MODEL

type alias Model = {title: String, url: String}

model : Model
model = form.week1


-- UPDATE

type Msg = Week1 | Week2 | Week3 | Week4 | Week5 | Week6 | Week7

update : Msg -> Model -> Model
update msg model =
    case msg of
        Week1 -> form.week1
        Week2 -> form.week2
        Week3 -> form.week3
        Week4 -> form.week4
        Week5 -> form.week5
        Week6 -> form.week6
        Week7 -> form.week7


-- VIEW

view : Model -> Html Msg
view model =
    div [] (List.append
    [ text "Select week: "
    , button [ onClick Week1 ] [ text "1" ]
    , button [ onClick Week2 ] [ text "2" ]
    , button [ onClick Week3 ] [ text "3" ]
    , button [ onClick Week4 ] [ text "4" ]
    , button [ onClick Week5 ] [ text "5" ]
    , button [ onClick Week6 ] [ text "6" ]
    , button [ onClick Week7 ] [ text "7" ]
    ]
    (vimeo model))


vimeo model =
    [ h2 [] [text model.title]
    , iframe [src model.url, width 500, height 282,
              attribute "frameborder" "0",
              attribute "webkitallowfullscreen" "true",
              attribute "mozallowfullscreen" "true",
              attribute "allowfullscreen" "true"
              ] [] ]
