require "test_helper"

module Jigsaw
  class LayoutTest < ActiveSupport::TestCase
    # --- Schema Validation ---

    test "valid grid config passes validation" do
      layout = Layout.new(name: "test grid", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rows" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px"
      })
      assert layout.valid?
    end

    test "valid flex config passes validation" do
      layout = Layout.new(name: "test flex", config: {
        "type" => "flex",
        "childrenCount" => 3,
        "direction" => "row",
        "rowGap" => 8, "rowGapUnit" => "px"
      })
      assert layout.valid?
    end

    test "invalid type fails validation" do
      layout = Layout.new(name: "bad type", config: { "type" => "table" })
      assert_not layout.valid?
      assert layout.errors[:config].any?
    end

    test "invalid track unit fails validation" do
      layout = Layout.new(name: "bad unit", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "banana" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px"
      })
      assert_not layout.valid?
      assert layout.errors[:config].any?
    end

    test "missing required fields fails validation" do
      layout = Layout.new(name: "missing fields", config: { "type" => "grid" })
      assert_not layout.valid?
      assert layout.errors[:config].any?
    end

    test "invalid gap unit fails validation" do
      layout = Layout.new(name: "bad gap", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "em",
        "colGap" => 8, "colGapUnit" => "px"
      })
      assert_not layout.valid?
    end

    test "extra properties fail validation" do
      layout = Layout.new(name: "extra props", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "bogus" => "field"
      })
      assert_not layout.valid?
    end

    # --- Grid: Areas ---

    test "valid areas config passes" do
      layout = Layout.new(name: "areas", config: {
        "type" => "grid",
        "childrenCount" => 5,
        "rows" => [
          { "value" => 1, "unit" => "auto" },
          { "value" => 1, "unit" => "fr" },
          { "value" => 1, "unit" => "auto" }
        ],
        "columns" => [
          { "value" => 1, "unit" => "auto" },
          { "value" => 1, "unit" => "fr" },
          { "value" => 1, "unit" => "auto" }
        ],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px",
        "areas" => [
          %w[header header header],
          %w[leftSide body rightSide],
          %w[footer footer footer]
        ]
      })
      assert layout.valid?
    end

    test "non-rectangular areas fail validation" do
      layout = Layout.new(name: "L-shape", config: {
        "type" => "grid",
        "childrenCount" => 3,
        "rows" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px",
        "areas" => [
          %w[a a],
          %w[a b]
        ]
      })
      assert_not layout.valid?
      assert layout.errors[:config].any? { |e| e.include?("not rectangular") }
    end

    # --- Grid: Repeat tracks ---

    test "auto-fit repeat rows passes" do
      layout = Layout.new(name: "auto-fit", config: {
        "type" => "grid",
        "childrenCount" => 12,
        "rows" => { "repeat" => "auto-fit", "value" => 1, "unit" => "fr" },
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px"
      })
      assert layout.valid?
    end

    test "auto-fill repeat rows passes" do
      layout = Layout.new(name: "auto-fill", config: {
        "type" => "grid",
        "childrenCount" => 6,
        "rows" => { "repeat" => "auto-fill", "value" => 1, "unit" => "fr" },
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px"
      })
      assert layout.valid?
    end

    # --- Grid: Child placements ---

    test "child placements with grid-column passes" do
      layout = Layout.new(name: "placements", config: {
        "type" => "grid",
        "childrenCount" => 6,
        "rows" => { "repeat" => "auto-fill", "value" => 1, "unit" => "fr" },
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px",
        "childPlacements" => [
          {},
          { "column" => "1 / -1" },
          { "column" => "1 / -1" },
          {},
          { "column" => "1 / -1" },
          { "column" => "1 / -1" }
        ]
      })
      assert layout.valid?
    end

    # --- Grid: Alignment ---

    test "container and item alignment passes" do
      layout = Layout.new(name: "aligned", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "justifyContent" => "center",
        "alignContent" => "space-between",
        "justifyItems" => "start",
        "alignItems" => "end"
      })
      assert layout.valid?
    end

    test "invalid alignment value fails" do
      layout = Layout.new(name: "bad align", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "justifyContent" => "banana"
      })
      assert_not layout.valid?
    end

    # --- Grid: Direction + Dense ---

    test "direction and dense passes" do
      layout = Layout.new(name: "dense col", config: {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "direction" => "column",
        "dense" => true
      })
      assert layout.valid?
    end

    # --- Flex: All fields ---

    test "flex with all options passes" do
      layout = Layout.new(name: "full flex", config: {
        "type" => "flex",
        "childrenCount" => 4,
        "direction" => "row",
        "wrap" => "wrap",
        "rowGap" => 16, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "justifyContent" => "space-between",
        "alignItems" => "center",
        "alignContent" => "start",
        "childPlacements" => [
          { "flexGrow" => 1, "flexShrink" => 0, "flexBasis" => "200px" },
          { "flexGrow" => 2, "alignSelf" => "end", "order" => -1 },
          {},
          { "flexGrow" => 1 }
        ]
      })
      assert layout.valid?
    end

    test "invalid flex direction fails" do
      layout = Layout.new(name: "bad dir", config: {
        "type" => "flex",
        "childrenCount" => 3,
        "direction" => "diagonal",
        "rowGap" => 8, "rowGapUnit" => "px"
      })
      assert_not layout.valid?
    end

    test "invalid flex wrap fails" do
      layout = Layout.new(name: "bad wrap", config: {
        "type" => "flex",
        "childrenCount" => 3,
        "direction" => "row",
        "wrap" => "maybe",
        "rowGap" => 8, "rowGapUnit" => "px"
      })
      assert_not layout.valid?
    end

    # --- CSS Generation ---

    test "grid generator produces correct CSS for holy grail" do
      config = {
        "type" => "grid",
        "childrenCount" => 5,
        "rows" => [
          { "value" => 1, "unit" => "auto" },
          { "value" => 1, "unit" => "fr" },
          { "value" => 1, "unit" => "auto" }
        ],
        "columns" => [
          { "value" => 1, "unit" => "auto" },
          { "value" => 1, "unit" => "fr" },
          { "value" => 1, "unit" => "auto" }
        ],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px",
        "areas" => [
          %w[header header header],
          %w[leftSide body rightSide],
          %w[footer footer footer]
        ]
      }
      css = GridLayoutGenerator.new(config, "x").call

      assert_includes css, "display: grid"
      assert_includes css, '"header header header" auto'
      assert_includes css, '"leftSide body rightSide" 1fr'
      assert_includes css, '"footer footer footer" auto'
      assert_includes css, "/ auto 1fr auto"
      assert_includes css, "gap: 4px"
      assert_includes css, "grid-area: header"
      assert_includes css, "grid-area: body"
      assert_includes css, "grid-area: footer"
    end

    test "grid generator produces repeat for auto-fit rows" do
      config = {
        "type" => "grid",
        "childrenCount" => 12,
        "rows" => { "repeat" => "auto-fit", "value" => 1, "unit" => "fr" },
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px"
      }
      css = GridLayoutGenerator.new(config, "x").call

      assert_includes css, "grid-template-rows: repeat(auto-fit, 1fr)"
      assert_includes css, "grid-template-columns: 1fr 1fr 1fr"
    end

    test "grid generator produces child placement classes" do
      config = {
        "type" => "grid",
        "childrenCount" => 3,
        "rows" => { "repeat" => "auto-fill", "value" => 1, "unit" => "fr" },
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 4, "rowGapUnit" => "px",
        "colGap" => 4, "colGapUnit" => "px",
        "childPlacements" => [{}, { "column" => "1 / -1" }, {}]
      }
      css = GridLayoutGenerator.new(config, "x").call

      assert_includes css, "grid-column: 1 / -1"
    end

    test "grid generator produces auto-flow when direction is column" do
      config = {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "direction" => "column",
        "dense" => true
      }
      css = GridLayoutGenerator.new(config, "x").call

      assert_includes css, "grid-auto-flow: column dense"
    end

    test "grid generator produces alignment properties" do
      config = {
        "type" => "grid",
        "childrenCount" => 9,
        "columns" => [{ "value" => 1, "unit" => "fr" }],
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "justifyContent" => "center",
        "alignContent" => "space-between",
        "justifyItems" => "start",
        "alignItems" => "end"
      }
      css = GridLayoutGenerator.new(config, "x").call

      assert_includes css, "justify-content: center"
      assert_includes css, "align-content: space-between"
      assert_includes css, "justify-items: start"
      assert_includes css, "align-items: end"
    end

    test "flex generator produces correct CSS" do
      config = {
        "type" => "flex",
        "childrenCount" => 3,
        "direction" => "column",
        "wrap" => "wrap",
        "rowGap" => 16, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px",
        "justifyContent" => "space-between",
        "alignItems" => "center",
        "childPlacements" => [
          { "flexGrow" => 1 },
          { "flexGrow" => 2, "alignSelf" => "start" },
          {}
        ]
      }
      css = FlexLayoutGenerator.new(config, "x").call

      assert_includes css, "display: flex"
      assert_includes css, "flex-direction: column"
      assert_includes css, "flex-wrap: wrap"
      assert_includes css, "justify-content: space-between"
      assert_includes css, "align-items: center"
      assert_includes css, "row-gap: 16px"
      assert_includes css, "column-gap: 8px"
      assert_includes css, "flex-grow: 1"
      assert_includes css, "flex-grow: 2"
      assert_includes css, "align-self: start"
    end
  end
end
