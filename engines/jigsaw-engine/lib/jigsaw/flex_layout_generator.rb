module Jigsaw
  class FlexLayoutGenerator
    def initialize(config, layout_id)
      @config = config
      @id = layout_id
    end

    def call
      rules = [container_rule]
      rules << child_placement_rules if has_child_placements?
      rules.compact.join("\n\n")
    end

    private

    def selector = ".jigsaw-layout-#{@id}"

    def container_rule
      props = { "width" => "100%", "display" => "flex" }

      props["flex-direction"] = @config["direction"] if @config["direction"].present? && @config["direction"] != "row"
      props["flex-wrap"] = @config["wrap"] if @config["wrap"].present? && @config["wrap"] != "nowrap"
      props["justify-content"] = @config["justifyContent"] if @config["justifyContent"].present? && @config["justifyContent"] != "start"
      props["align-items"] = @config["alignItems"] if @config["alignItems"].present? && @config["alignItems"] != "stretch"
      props["align-content"] = @config["alignContent"] if @config["alignContent"].present? && @config["alignContent"] != "stretch"

      row_gap = gap_str("rowGap", "rowGapUnit")
      col_gap = gap_str("colGap", "colGapUnit")

      if row_gap && col_gap && row_gap == col_gap
        props["gap"] = row_gap
      else
        props["row-gap"] = row_gap if row_gap
        props["column-gap"] = col_gap if col_gap
      end

      body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
      "#{selector} {\n#{body}\n}"
    end

    def gap_str(value_key, unit_key)
      value = @config[value_key]
      unit = @config[unit_key] || "px"
      if value.present? && value.to_f > 0
        "#{value}#{unit}"
      end
    end

    def has_child_placements?
      @config["childPlacements"].present? && @config["childPlacements"].any? { |p| p.present? }
    end

    def child_placement_rules
      placements = @config["childPlacements"]
      rules = []

      placements.each_with_index do |placement, i|
        next if placement.blank?

        props = {}
        props["flex-grow"] = placement["flexGrow"].to_s if placement["flexGrow"].present?
        props["flex-shrink"] = placement["flexShrink"].to_s if placement["flexShrink"].present?
        props["flex-basis"] = placement["flexBasis"] if placement["flexBasis"].present?
        props["align-self"] = placement["alignSelf"] if placement["alignSelf"].present?
        props["order"] = placement["order"].to_s if placement["order"].present?
        next if props.empty?

        body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
        rules << "#{selector} > :nth-child(#{i + 1}) {\n#{body}\n}"
      end

      rules.empty? ? nil : rules.join("\n\n")
    end
  end
end
