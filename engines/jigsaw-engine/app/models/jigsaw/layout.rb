module Jigsaw
  class Layout < ApplicationRecord
    SCHEMA_PATH = File.expand_path("schemas/layout_config.json", __dir__)
    SCHEMA = JSONSchemer.schema(Pathname.new(SCHEMA_PATH))

    belongs_to :page
    has_many :slots, -> { order(:position) }, dependent: :destroy

    store_accessor(
      :config,
      :gridWidth,
      :gridHeight,
      :rowGap,
      :colGap,
      :rowGapUnit,
      :colGapUnit,
    )

    validates :name, presence: true, uniqueness: true
    validates :config, presence: true
    validate :config_valid_per_schema

    before_save :compile_css

    def unique_area_names
      if config["areas"].is_a?(Array)
        config["areas"].flatten.uniq.reject { |s| s == "." }
      else
        []
      end
    end

    def sync_slots
      if config["areas"].is_a?(Array)
        current_names = unique_area_names
        existing = slots.reload.index_by(&:area_name)

        obsolete = existing.reject { |name, _| current_names.include?(name) }
        obsolete.values.each(&:destroy!)
        obsolete.keys.each { |name| existing.delete(name) }

        current_names.each do |name|
          unless existing.key?(name)
            existing[name] = slots.create!(area_name: name)
          end
        end

        current_names.each_with_index do |name, position|
          slot = existing[name]
          slot.update_column(:position, position) if slot.position != position
        end
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

      def compile_css
        generator = GridLayoutGenerator.new(config, id || SecureRandom.hex(4))
        self.compiled_css = generator.call
        self.compiled_digest = Digest::SHA256.hexdigest(compiled_css)
      end
  end
end
