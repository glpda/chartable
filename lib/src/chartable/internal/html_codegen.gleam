import chartable/internal/notation_table.{type NotationTable}

pub const parse_entities_json = notation_table.parse_notation_to_grapheme_json

pub fn make_map(
  entities table: NotationTable,
  template template: String,
  data_source data_source: String,
) -> String {
  notation_table.make_javascript_map(table:, template:, data_source:)
}
