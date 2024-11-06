import counter
import lustre

pub fn main() {
  let assert Ok(_) = lustre.start(counter.app(), "#app", Nil)

  Nil
}
