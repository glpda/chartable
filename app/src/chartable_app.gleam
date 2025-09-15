import gleam/int
import lustre
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "[chartable]", Nil)

  Nil
}

type Model =
  Int

fn init(_args) -> Model {
  0
}

type Msg {
  UserClickedIncrement
  UserClickedDecrement
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserClickedIncrement -> model + 1
    UserClickedDecrement -> model - 1
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.header([], [html.text("Under construction 🚧")]),
    view_main(model),
  ])
}

fn view_main(model: Model) -> Element(Msg) {
  let count = int.to_string(model)

  html.main([], [
    html.button([event.on_click(UserClickedIncrement)], [html.text("+")]),
    html.button([event.on_click(UserClickedDecrement)], [html.text("-")]),
    html.p([], [html.text("count:" <> count)]),
  ])
}
