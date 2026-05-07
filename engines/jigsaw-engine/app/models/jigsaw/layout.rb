module Jigsaw
  class Layout < ApplicationRecord

    SCHEMA_PATH = File.expand_path("schemas/layout_config.json", __dir__)
    SCHEMA = JSONSchemer.schema(Pathname.new(SCHEMA_PATH))

    belongs_to :custom_page, optional: true
    has_many :page_modules, -> { order(:position) }, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :config, presence: true
    validate :config_valid_per_schema
    validate :areas_are_rectangular

    before_save :compile_css

    store_accessor :config, :type, :childrenCount, :rowGap, :colGap, :colGapUnit, :rowGapUnit

    attribute :col_count,      :integer
    attribute :row_count,      :integer
    attribute :children_count, :integer
    attribute :row_gap,        :integer
    attribute :row_geight,     :integer
    attribute :col_width,      :integer
    attribute :col_gap,        :integer

    private

      def config_valid_per_schema
        unless config.blank?
          SCHEMA.validate(config).each do |error|
            errors.add(:config, JSONSchemer::Errors.pretty(error))
          end
        end
      end

      def default_grid_config
        {
          "type" => "grid",
          "children_count" => 9,
          "columns" => [
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" }
          ],
          "rows" => [
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" }
          ],
          "row_height" => 20,
          "row_gap" => 8,
          "row_gap_unit" => "px",
          "col_gap" => 8,
          "col_gap_unit" => "px",
          "areas" => []
        }
      end

      #def areas_are_rectangular
      #  if config.is_a?(Hash) && config["type"] == "grid" && config["areas"].present?
      #    config["areas"].flatten.uniq.reject { |s| s == "." }.each do |slot|
      #      cells = []
      #      config["areas"].each_with_index do |row, r|
      #        row.each_with_index { |cell, c| cells << [r, c] if cell == slot }
      #      end
      #      rows = cells.map(&:first).uniq.sort
      #      cols = cells.map(&:last).uniq.sort
      #      expected = rows.product(cols).sort
      #      errors.add(:config, "area '#{slot}' is not rectangular") unless cells.sort == expected
      #    end
      #  end
      #end

      #def compile_css
      #  generator = config["type"] == "grid" ? GridLayoutGenerator : FlexLayoutGenerator
      #  self.compiled_css = generator.new(config, id || SecureRandom.hex(4)).call
      #  self.compiled_digest = Digest::SHA256.hexdigest(compiled_css)
      #end
  end
end
