module Jigsaw
  class Layout < ApplicationRecord
    SCHEMA_PATH = File.expand_path("schemas/layout_config.json", __dir__)
    SCHEMA = JSONSchemer.schema(Pathname.new(SCHEMA_PATH))

    has_many :custom_pages, dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: true
    validates :config, presence: true
    validate :config_valid_per_schema
    validate :areas_are_rectangular

    before_save :compile_css

    private

    def config_valid_per_schema
      return if config.blank?

      SCHEMA.validate(config).each do |error|
        errors.add(:config, JSONSchemer::Errors.pretty(error))
      end
    end

    def areas_are_rectangular
      return unless config.is_a?(Hash) && config["type"] == "grid" && config["areas"].present?

      config["areas"].flatten.uniq.reject { |s| s == "." }.each do |slot|
        cells = []
        config["areas"].each_with_index do |row, r|
          row.each_with_index { |cell, c| cells << [r, c] if cell == slot }
        end
        rows = cells.map(&:first).uniq.sort
        cols = cells.map(&:last).uniq.sort
        expected = rows.product(cols).sort
        errors.add(:config, "area '#{slot}' is not rectangular") unless cells.sort == expected
      end
    end

    def compile_css
      generator = config["type"] == "grid" ? GridLayoutGenerator : FlexLayoutGenerator
      self.compiled_css = generator.new(config, id || SecureRandom.hex(4)).call
      self.compiled_digest = Digest::SHA256.hexdigest(compiled_css)
    end
  end
end
