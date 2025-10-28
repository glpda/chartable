import chartable/data.{type Data}
import chartable/route.{type Route}
import chartable/unicode
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint
import chartable/unicode/script.{type Script}
import chartable/view_codepoint

import gleam/list
import gleam/result
import gleam/string
import gleam/uri.{type Uri}

import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#chartable", Nil)

  Nil
}

type Model {
  Model(data: Data, nav_model: NavModel, route: Route)
}

type NavModel {
  NavBlock
  NavScript
  // NavHidden
}

fn init(_) -> #(Model, Effect(Msg)) {
  let data = data.init()
  let route =
    modem.initial_uri()
    |> result.unwrap(uri.empty)
    |> route.from_uri(data)
  let model = Model(data:, nav_model: NavBlock, route:)
  #(model, modem.init(on_url_change(_, data)))
}

fn on_url_change(uri: Uri, data: Data) -> Msg {
  OnRouteChange(route.from_uri(uri, data))
}

type Msg {
  UserSelectedNav(NavModel)
  OnRouteChange(Route)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserSelectedNav(nav_model) -> #(Model(..model, nav_model:), effect.none())
    OnRouteChange(route) -> #(Model(..model, route:), effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    view_nav(model),
    view_main(model),
    view_article(model),
  ])
}

fn view_nav(model: Model) -> Element(Msg) {
  let menu =
    html.menu([], case model.nav_model {
      NavBlock ->
        nav_list(
          model.data.blocks,
          element: block_link,
          highlight: block_is_current(model, _),
        )
      NavScript ->
        nav_list(
          model.data.scripts,
          element: script_link,
          highlight: script_is_current(model, _),
        )
    })
  html.nav([], [
    html.header([], [
      nav_button(model, NavBlock, "Blocks"),
      nav_button(model, NavScript, "Scripts"),
    ]),
    menu,
  ])
}

fn nav_button(model: Model, nav_model: NavModel, name: String) {
  html.button(
    [
      event.on_click(UserSelectedNav(nav_model)),
      ..case model.nav_model == nav_model {
        True -> [attribute.aria_current("true")]
        False -> []
      }
    ],
    [
      html.text(name),
    ],
  )
}

fn nav_list(
  list: List(a),
  element element: fn(a) -> Element(Msg),
  highlight highlight: fn(a) -> Bool,
) -> List(Element(Msg)) {
  use item <- list.map(list)
  html.li(
    case highlight(item) {
      True -> [attribute.aria_current("true")]
      False -> []
    },
    [element(item)],
  )
}

fn block_link(block: unicode.Block) -> Element(Msg) {
  html.a([attribute.href(route.block_path(block))], [
    html.text(block.name),
  ])
}

fn block_is_current(model: Model, block) {
  case model.route {
    route.Block(active_block, ..) -> active_block == block
    _ -> False
  }
}

fn script_link(script: Script) -> Element(Msg) {
  let long_name = script.to_long_name(script)
  let short_name = script.to_short_name(script)
  html.a([attribute.href(route.script_path(script))], [
    html.text(long_name <> " (" <> short_name <> ")"),
  ])
}

fn script_is_current(model: Model, script) {
  case model.route {
    route.Script(active_script, ..) -> active_script == script
    _ -> False
  }
}

fn category_to_string(cat: GeneralCategory) {
  let long_name =
    category.to_long_name(cat)
    |> string.replace(each: "_", with: " ")
  let short_name = category.to_short_name(cat)

  html.text(long_name <> " (" <> short_name <> ")")
}

fn view_main(model: Model) -> Element(Msg) {
  let codepoints = case model.route {
    route.Block(block, ..) -> codepoint.range_to_list(block.range)
    route.Script(script, ..) ->
      script.to_ranges(script)
      |> list.flat_map(codepoint.range_to_list)
  }

  html.main([], [
    html.header([attribute.id("header")], [
      html.h1([], [
        html.text(case model.route {
          route.Block(block, ..) -> "Block: " <> block.name
          route.Script(script, ..) -> "Script: " <> script.to_long_name(script)
        }),
      ]),
    ]),
    html.ol(
      [attribute.id("codepoints-grid")],
      list.map(codepoints, fn(codepoint) {
        html.li(
          case codepoint == model.route.codepoint {
            True -> [attribute.aria_current("true")]
            False -> []
          },
          [
            view_codepoint.tile(codepoint, model.route),
          ],
        )
      }),
    ),
    view_footer(),
  ])
}

fn view_article(model: Model) {
  let codepoint = model.route.codepoint
  let hex = codepoint.to_hex(codepoint)
  let cat = unicode.category_from_codepoint(codepoint)
  let name =
    unicode.name_from_codepoint(codepoint)
    |> result.unwrap("<" <> hex <> ">")
  let block = case unicode.block_from_codepoint(codepoint) {
    Ok(block) -> block_link(block)
    Error(Nil) -> html.text("No_Block")
  }

  html.article([], [
    html.header([], [
      html.h2([], [html.text("U+" <> hex)]),
    ]),
    html.dl([], [
      html.dt([], [html.text("Name")]),
      html.dd([], [html.text(name)]),
      html.dt([], [html.text("Block")]),
      html.dd([], [block]),
      html.dt([], [html.text("Category")]),
      html.dd([], [category_to_string(cat)]),
    ]),
  ])
}

fn view_footer() {
  let link = fn(url, name) {
    html.a([attribute.class("external"), attribute.href(url)], [
      html.text(name),
    ])
  }
  let glpda = link("https://github.com/glpda/", "Louis Guichard")
  let gleam = link("https://gleam.run/", "Gleam ⭐")
  let lustre = link("https://lustre.build/", "Lustre 🦋")

  html.footer([], [
    html.p([], [
      html.text("Made by "),
      glpda,
      html.text(" with, "),
      gleam,
      html.text(", "),
      lustre,
      html.text(", and love ❤️!"),
    ]),
  ])
}
