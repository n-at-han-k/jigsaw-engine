module Jigsaw
  class FlexLayoutGenerator
    def initialize(config, layout_id)
      @config = config
      @id = layout_id
    end

    def call
      rules = [container_rule]
      rules << children_rules if has_children?
      rules.compact.join("\n\n")
    end

    private

    def selector = ".jigsaw-layout-#{@id}"

    def container_rule
      props = { "width" => "100%", "display" => "flex" }

      props["flex-direction"] = @config["direction"] if @config["direction"].present? && @config["direction"] != "row"
      props["flex-wrap"] = @config["wrap"] if @config["wrap"].present? && @config["wrap"] != "nowrap"

      gap_value = @config["gap"]
      gap_unit = @config["gapUnit"] || "px"
      props["gap"] = "#{gap_value}#{gap_unit}" if gap_value.present? && gap_value.to_f > 0

      container = @config["containerAlignment"]
      if container.present?
        props["justify-content"] = container["mainAxis"] if container["mainAxis"].present? && container["mainAxis"] != "flex-start"
        props["align-items"] = container["crossAxis"] if container["crossAxis"].present? && container["crossAxis"] != "stretch"
      end

      body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
      "#{selector} {\n#{body}\n}"
    end

    def has_children?
      @config["children"].present? && @config["children"].any? { |c| non_default_child?(c) }
    end

    def non_default_child?(child)
      child["grow"].to_i != 0 || child["shrink"].to_i != 1 || child["basis"] != "auto" || child["margin"] == true
    end

    def children_rules
      children = @config["children"]
      rules = []
      class_map = {}

      children.each_with_index do |child, _i|
        next unless non_default_child?(child)

        props = {}
        props["flex-grow"] = child["grow"].to_s if child["grow"].to_i != 0
        props["flex-shrink"] = child["shrink"].to_s if child["shrink"].to_i != 1
        props["flex-basis"] = child["basis"] if child["basis"].present? && child["basis"] != "auto"
        props["margin-left"] = "auto" if child["margin"] == true
        next if props.empty?

        class_name = child_class_name(child)
        class_map[class_name] ||= props
      end

      class_map.each do |class_name, props|
        body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
        rules << "#{selector} > .#{class_name} {\n#{body}\n}"
      end

      rules.empty? ? nil : rules.join("\n\n")
    end

    def child_class_name(child)
      if child["margin"] == true
        "marginLeft"
      elsif child["grow"].to_i != 0
        "grow#{child['grow'].to_i}"
      elsif child["shrink"].to_i != 1
        "shrink#{child['shrink'].to_i}"
      else
        "basis#{child['basis']}"
      end
    end
  end
end
