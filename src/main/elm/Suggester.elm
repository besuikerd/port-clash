port module Suggester exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

port check : String -> Cmd msg
port suggestions : (List String -> msg) -> Sub msg

type Msg
  = OnSuggestions (List String)
  | FieldUpdate String
  | Check

type alias Model =
  { suggestions: List String
  , field: String
  }

init : (Model, Cmd Msg)
init =
  (
    Model
      []
      ""
  , Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = suggestions OnSuggestions

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OnSuggestions suggestions ->
      { model | suggestions = suggestions } ! []
    FieldUpdate field ->
      { model | field = field } ! []
    Check ->
      ({ model | field = "" }, check model.field)

view : Model -> Html Msg
view model =
  div
    []
    [ input
        [ type' "text"
        , onInput FieldUpdate
        ]
        []
    , button
      [ onClick Check
      ]
      [ text "Check"
      ]
    , h2 [] [ text "Suggestions" ]
    , ul
        []
        (List.map (\suggestion -> li [] [text suggestion]) model.suggestions)
    ]
