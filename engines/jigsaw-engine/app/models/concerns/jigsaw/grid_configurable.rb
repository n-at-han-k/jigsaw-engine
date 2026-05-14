module Jigsaw
  module GridConfigurable
    extend ActiveSupport::Concern

    SCHEMA_PATH = File.expand_path("../../jigsaw/schemas/layout_config.json", __dir__)
    SCHEMA = JSONSchemer.schema(Pathname.new(SCHEMA_PATH))

    included do
      store_accessor(
        :config,
        :gridWidth,
        :gridHeight,
        :rowGap,
        :colGap,
        :rowGapUnit,
        :colGapUnit,
      )

      validates :config, presence: true, unless: :skip_config_validation?
      validate :config_valid_per_schema, unless: :skip_config_validation?

      before_save :compile_css
    end

    # Override in models that support template linking
    def skip_config_validation?
      false
    end

    def config=(val)
      val = JSON.parse(val) if val.is_a?(String)
      super(val)
    end

    def rowGap=(val)
      super(val.to_i)
    end

    def colGap=(val)
      super(val.to_i)
    end

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
