require "test_helper"

module Jigsaw
  class LayoutTest < ActiveSupport::TestCase
    def setup
      @page_counter = 0
    end

    def build_page!
      @page_counter += 1
      Page.create!(title: "Page #{@page_counter}", path: "page-#{@page_counter}-#{SecureRandom.hex(2)}")
    end

    def new_layout(attrs = {})
      defaults = { name: "layout-#{SecureRandom.hex(2)}", page: build_page! }
      Layout.new(defaults.merge(attrs))
    end

    def create_layout!(attrs = {})
      new_layout(attrs).tap(&:save!)
    end

    def holy_grail_config
      {
        "type" => "grid",
        "areas" => [
          ["header", "header", "header"],
          ["left", "main", "right"],
          ["footer", "footer", "footer"]
        ],
        "columns" => ["120px", "4fr", "1fr"],
        "rows" => ["160px", "1fr", "80px"],
        "gridWidth" => "100%",
        "gridHeight" => "100%",
        "rowGap" => 8, "rowGapUnit" => "px",
        "colGap" => 8, "colGapUnit" => "px"
      }
    end

    # --- Schema Validation ---

    test "valid grid config passes validation" do
      layout = new_layout(name: "test grid", config: holy_grail_config)
      assert layout.valid?, layout.errors.full_messages.to_s
    end

    test "invalid type fails validation" do
      config = holy_grail_config.merge("type" => "flex")
      layout = new_layout(name: "bad type", config: config)
      assert_not layout.valid?
      assert layout.errors[:config].any?
    end

    test "missing required fields fails validation" do
      layout = new_layout(name: "missing fields", config: { "type" => "grid" })
      assert_not layout.valid?
      assert layout.errors[:config].any?
    end

    test "invalid gap unit fails validation" do
      config = holy_grail_config.merge("rowGapUnit" => "em")
      layout = new_layout(name: "bad gap", config: config)
      assert_not layout.valid?
    end

    test "extra properties fail validation" do
      config = holy_grail_config.merge("bogus" => "field")
      layout = new_layout(name: "extra props", config: config)
      assert_not layout.valid?
    end

    # --- Areas ---

    test "non-rectangular areas fail validation" do
      layout = new_layout(name: "L-shape", config: holy_grail_config.merge(
        "areas" => [
          ["a", "a"],
          ["a", "b"]
        ],
        "columns" => ["1fr", "1fr"],
        "rows" => ["1fr", "1fr"]
      ))
      assert_not layout.valid?
      assert layout.errors[:config].any? { |e| e.include?("not rectangular") }
    end

    test "unique_area_names returns deduplicated area names excluding dots" do
      layout = new_layout(name: "areas", config: holy_grail_config)
      assert_equal %w[header left main right footer], layout.unique_area_names
    end

    # --- CSS Generation ---

    test "grid generator produces correct CSS for holy grail" do
      css = GridLayoutGenerator.new(holy_grail_config, "x").call

      assert_includes css, "display: grid"
      assert_includes css, '"header header header"'
      assert_includes css, '"left main right"'
      assert_includes css, '"footer footer footer"'
      assert_includes css, "grid-template-columns: 120px 4fr 1fr"
      assert_includes css, "grid-template-rows: 160px 1fr 80px"
      assert_includes css, "gap: 8px"
      assert_includes css, "grid-area: header"
      assert_includes css, "grid-area: main"
      assert_includes css, "grid-area: footer"
    end

    test "grid generator produces different row and col gap when different" do
      config = holy_grail_config.merge("rowGap" => 8, "colGap" => 16)
      css = GridLayoutGenerator.new(config, "x").call

      assert_includes css, "gap: 8px 16px"
    end

    test "compile_css callback sets compiled_css and digest" do
      layout = new_layout(name: "compile-test", config: holy_grail_config)
      layout.save!

      assert_not_nil layout.compiled_css
      assert_not_nil layout.compiled_digest
      assert_includes layout.compiled_css, "display: grid"
    end

    # --- Slot sync ---

    test "sync_slots creates slots for each unique area" do
      layout = create_layout!(name: "sync-test", config: holy_grail_config)
      layout.sync_slots

      assert_equal 5, layout.slots.count
      assert_equal %w[header left main right footer], layout.slots.order(:position).map(&:area_name)
    end

    test "sync_slots removes slots whose areas no longer exist" do
      layout = create_layout!(name: "sync-test-2", config: holy_grail_config)
      layout.sync_slots
      assert_equal 5, layout.slots.count

      layout.update!(config: holy_grail_config.merge(
        "areas" => [
          ["header", "header", "header"],
          ["main", "main", "main"],
          ["footer", "footer", "footer"]
        ]
      ))
      layout.sync_slots

      assert_equal 3, layout.slots.count
      assert_equal %w[header main footer], layout.slots.order(:position).map(&:area_name)
    end

    test "sync_slots is idempotent" do
      layout = create_layout!(name: "sync-test-3", config: holy_grail_config)
      layout.sync_slots
      slot_ids = layout.slots.pluck(:id)

      layout.sync_slots
      assert_equal slot_ids.sort, layout.reload.slots.pluck(:id).sort
    end
  end
end
