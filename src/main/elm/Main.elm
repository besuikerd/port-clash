module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Suggester

main : Program Never
main = App.program
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }


type Msg =
  SuggesterMsg Int Suggester.Msg

type alias Model =
  { suggesters : List Suggester.Model
  }

init : (Model, Cmd Msg)
init =
  let
    initSuggester i =
      let
        (suggester, cmd) = Suggester.init
      in (suggester, (i, cmd))
    (suggesters, cmds) = List.unzip <| List.map initSuggester [1..10]
  in
    ( Model
        suggesters
    , Cmd.batch
        ( List.map
          (\(i, cmd) -> Cmd.map (SuggesterMsg i) cmd)
          cmds
        )
    )

subscriptions : Model -> Sub Msg
subscriptions model =
  let
    suggesterSubscription i suggester = Sub.map (SuggesterMsg i) (Suggester.subscriptions suggester)
  in
    Sub.batch <| List.indexedMap suggesterSubscription model.suggesters

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SuggesterMsg i msg ->
      case List.drop i model.suggesters of
        (suggester :: suf) ->
          let
            pre = List.take i model.suggesters
            (suggester', cmd) = Suggester.update msg suggester
          in
            ( { model | suggesters = List.concat [pre, [suggester'], suf] }
            , Cmd.map (SuggesterMsg i) cmd
            )
        [] -> model ! []

view : Model -> Html Msg
view model =
  let
    suggestorView i suggestor = App.map (SuggesterMsg i) (Suggester.view suggestor)
  in
    div
      []
      (List.indexedMap suggestorView model.suggesters)
