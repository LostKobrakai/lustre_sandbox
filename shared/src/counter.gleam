import gleam/dict
import gleam/dynamic.{type Decoder}
import gleam/int
import lustre
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event

pub const name = "counter-component"

pub fn app() -> lustre.App(Nil, Model, Msg) {
  lustre.component(init, update, view, on_attribute_change())
}

pub type Model =
  Int

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(0, effect.none())
}

pub type Msg {
  Increment
  Decrement
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let model = case msg {
    Increment -> model + 1
    Decrement -> model - 1
  }

  #(model, effect.none())
}

pub fn on_attribute_change() -> dict.Dict(String, Decoder(Msg)) {
  dict.new()
}

pub fn view(model: Model) -> element.Element(Msg) {
  let count = int.to_string(model)

  html.div([], [
    html.button([event.on_click(Increment)], [element.text("+")]),
    element.text(count),
    html.button([event.on_click(Decrement)], [element.text("-")]),
  ])
}
