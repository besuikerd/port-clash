# Port Clash

The Elm port system allows you to interop with javascript. An issue that I found while playing around with them is that these ports are global. While many use cases are valid for these global ports, they obstruct composition. Take the spellchecker example from [the guide](http://guide.elm-lang.org/interop/javascript.html). Say you have multiple windows that require spellchecking. So you simply subscribe to the `suggestions` port and fire commands to the `check` port. All is well until every part of your application that uses spellchecking now have their suggestions updated. Now of course you can fix this by managing request/response identifiers of some sort, but that is not an elegant solution

## Local ports

To enable composition of these request/reponse type use cases where you want to use ports, a port should be defined as a 'local port'. It combines the two previously used ports into one, for example:

```elm
port localCheck : String -> (List String -> msg) -> Sub msg
```

Then in the javascript world, the code has to be changed a bit:


```js
main.ports.localCheck.subscribe(word){
  return function(port){
    port.send(['these', 'are', 'my', 'suggestions', 'for', word])
  }
}
```

The subscriptions would need a bit more management, you cannot 'fire' a check command anymore, something along the lines of this:

```elm
type Msg
  = Check String
  | ...

type alias Model =
  { pendingCheck : Maybe String
    ...
  }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Check check -> { model | pendingCheck = Just check } ! []
    ...

subscriptions : Model -> Sub Msg
subscription model =
  case model.pendingCheck of
    case Just check -> localCheck check
    case Nothing -> Sub.none
```
