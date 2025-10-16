import chartable/unicode
import chartable/unicode/codepoint.{type Codepoint}
import chartable/unicode/script.{type Script}
import chartable/view_codepoint

import gleam/list
import gleam/result

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

type Model {
  Model(
    data: Data,
    nav_model: NavModel,
    grid_model: GridModel,
    codepoint: Codepoint,
  )
}

type Data {
  Data(blocks: List(unicode.Block), scripts: List(Script))
}

type NavModel {
  NavBlock
  NavScript
  // NavHidden
}

type GridModel {
  GridBlock(unicode.Block)
  GridScript(Script)
}

fn init(_args) -> Model {
  let blocks = unicode.blocks()
  let scripts = script.list()
  let assert Ok(ascii) = list.first(blocks)
  let assert Ok(codepoint) = codepoint.from_int(0x41)
  Model(
    data: Data(blocks:, scripts:),
    nav_model: NavBlock,
    grid_model: GridBlock(ascii),
    codepoint:,
  )
}

type Msg {
  UserSelectedNav(NavModel)
  UserSelectedBlock(unicode.Block)
  UserSelectedScript(Script)
  UserSelectedCodepoint(Codepoint)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectedBlock(block) -> Model(..model, grid_model: GridBlock(block))
    UserSelectedScript(script) -> Model(..model, grid_model: GridScript(script))
    UserSelectedNav(nav_model) -> Model(..model, nav_model:)
    UserSelectedCodepoint(codepoint) -> Model(..model, codepoint:)
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
  html.a([event.on_click(UserSelectedBlock(block))], [
    html.text(block.name),
  ])
}

fn block_is_current(model: Model, block) {
  case model.grid_model {
    GridBlock(active_block) -> active_block == block
    _ -> False
  }
}

fn script_link(script: Script) -> Element(Msg) {
  let long_name = script.to_long_name(script)
  let short_name = script.to_short_name(script)
  html.a([event.on_click(UserSelectedScript(script))], [
    html.text(long_name <> " (" <> short_name <> ")"),
  ])
}

fn script_is_current(model: Model, script) {
  case model.grid_model {
    GridScript(active_script) -> active_script == script
    _ -> False
  }
}

fn view_main(model: Model) -> Element(Msg) {
  let codepoints = case model.grid_model {
    GridBlock(block) -> codepoint.range_to_list(block.range)
    GridScript(script) ->
      script.to_ranges(script)
      |> list.flat_map(codepoint.range_to_list)
  }

  html.main([], [
    html.header([attribute.id("header")], [
      html.h1([], [
        html.text(case model.grid_model {
          GridBlock(block) -> "Block: " <> block.name
          GridScript(script) -> "Script: " <> script.to_long_name(script)
        }),
      ]),
    ]),
    html.ol(
      [attribute.id("codepoints-grid")],
      list.map(codepoints, fn(codepoint) {
        html.li(
          case codepoint == model.codepoint {
            True -> [attribute.aria_current("true")]
            False -> []
          },
          [
            view_codepoint.tile(codepoint, UserSelectedCodepoint(codepoint)),
          ],
        )
      }),
    ),
    view_footer(),
  ])
}

fn view_article(model: Model) {
  html.article([], [
    html.header([], [
      html.h2([], [html.text(codepoint.to_hex(model.codepoint))]),
    ]),
    html.dl([], [
      html.dt([], [html.text("Name")]),
      html.dd([], [
        html.text(
          unicode.name_from_codepoint(model.codepoint) |> result.unwrap(""),
        ),
      ]),
      html.dt([], [html.text("Block")]),
      html.dd([], [
        case unicode.block_from_codepoint(model.codepoint) {
          Ok(block) -> block_link(block)
          Error(Nil) -> html.text("No_Block")
        },
      ]),
    ]),
  ])
}

fn view_footer() {
  let link = fn(url, name) {
    html.a([attribute.href(url)], [
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
