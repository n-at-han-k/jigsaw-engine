module Jigsaw
  class Layout < ApplicationRecord
    SCHEMA_PATH = File.expand_path("schemas/layout_config.json", __dir__)
    SCHEMA = JSONSchemer.schema(Pathname.new(SCHEMA_PATH))

    belongs_to :page, optional: true
    has_many :slots, -> { order(:position) }, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :config, presence: true
    validate :config_valid_per_schema
    validate :areas_are_rectangular

    before_save :compile_css

    def unique_area_names
      return [] unless config["areas"].is_a?(Array)
      config["areas"].flatten.uniq.reject { |s| s == "." }
    end

    def sync_slots
      return unless config["areas"].is_a?(Array)

      current_names = unique_area_names
      existing = slots.reload.index_by(&:area_name)

      # Destroy obsolete slots first (avoid acts_as_list position thrashing)
      obsolete = existing.reject { |name, _| current_names.include?(name) }
      obsolete.values.each(&:destroy!)
      obsolete.keys.each { |name| existing.delete(name) }

      # Create any missing slots
      current_names.each do |name|
        unless existing.key?(name)
          existing[name] = slots.create!(area_name: name)
        end
      end

      # Assign final positions in bulk (skip callbacks)
      current_names.each_with_index do |name, position|
        slot = existing[name]
        slot.update_column(:position, position) if slot.position != position
      end
    end

    private

      def config_valid_per_schema
        unless config.blank?
          SCHEMA.validate(config).each do |error|
            errors.add(:config, JSONSchemer::Errors.pretty(error))
          end
        end
      end

      def areas_are_rectangular
        if config.is_a?(Hash) && config["type"] == "grid" && config["areas"].present?
          config["areas"].flatten.uniq.reject { |s| s == "." }.each do |slot_name|
            cells = []
            config["areas"].each_with_index do |row, r|
              row.each_with_index { |cell, c| cells << [r, c] if cell == slot_name }
            end
            rows = cells.map(&:first).uniq.sort
            cols = cells.map(&:last).uniq.sort
            expected = rows.product(cols).sort
            errors.add(:config, "area '#{slot_name}' is not rectangular") unless cells.sort == expected
          end
        end
      end

      def compile_css
        generator = GridLayoutGenerator.new(config, id || SecureRandom.hex(4))
        self.compiled_css = generator.call
        self.compiled_digest = Digest::SHA256.hexdigest(compiled_css)
      end
  end
end
