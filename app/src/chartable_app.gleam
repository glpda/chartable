import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#chartable", Nil)

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
    view_header(model),
    view_main(model),
    view_footer(),
  ])
}

fn view_header(_model: Model) -> Element(Msg) {
  html.header([], [html.text("CharTable 🎒")])
}

fn view_main(model: Model) -> Element(Msg) {
  let count = int.to_string(model)

  html.main([], [
    html.button([event.on_click(UserClickedIncrement)], [html.text("+")]),
    html.button([event.on_click(UserClickedDecrement)], [html.text("-")]),
    html.p([], [html.text("count:" <> count)]),
  ])
}

fn view_footer() {
  let glpda =
    html.a([attribute.href("https://github.com/glpda/")], [
      html.text("Louis Guichard"),
    ])
  let gleam =
    html.a([attribute.href("https://gleam.run/")], [
      html.text("Gleam ⭐"),
    ])
  let lustre =
    html.a([attribute.href("https://lustre.build/")], [
      html.text("Lustre ✨"),
    ])

  html.footer([], [
    html.p([], [
      html.text("Made by "),
      glpda,
      html.text(" with love ❤️, "),
      gleam,
      html.text(" and, "),
      lustre,
      html.text("!"),
    ]),
  ])
}
