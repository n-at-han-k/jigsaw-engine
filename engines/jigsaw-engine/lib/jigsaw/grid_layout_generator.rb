module Jigsaw
  class GridLayoutGenerator
    def initialize(config, layout_id)
      @config = config
      @id = layout_id
    end

    def call
      rules = [container_rule]
      rules << area_rules if has_areas?
      rules.compact.join("\n\n")
    end

    private

      def selector = ".jigsaw-layout-#{@id}"

      def container_rule
        props = {
          "width" => @config["gridWidth"] || "100%",
          "height" => @config["gridHeight"] || "100%",
          "display" => "grid"
        }

        props["grid-template-rows"] = @config["rows"]&.join(" ") || "1fr"
        props["grid-template-columns"] = @config["columns"]&.join(" ") || "1fr"

        if has_areas?
          props["grid-template-areas"] = @config["areas"].map { |row| "\"#{row.join(' ')}\"" }.join("\n    ")
        end

        props["gap"] = gap_shorthand

        body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
        "#{selector} {\n#{body}\n}"
      end

      def gap_shorthand
        row_gap = "#{@config['rowGap']}#{@config['rowGapUnit'] || 'px'}"
        col_gap = "#{@config['colGap']}#{@config['colGapUnit'] || 'px'}"
        row_gap == col_gap ? row_gap : "#{row_gap} #{col_gap}"
      end

      def has_areas?
        @config["areas"].present? && @config["areas"].flatten.any? { |s| s != "." }
      end

      def area_rules
        names = @config["areas"].flatten.uniq.reject { |s| s == "." }
        return nil if names.empty?

        names.map { |name| "#{selector} > .#{name} { grid-area: #{name}; }" }.join("\n")
      end
  end
end
