module Jigsaw
  class GridLayoutGenerator
    def initialize(config, layout_id)
      @config = config
      @id = layout_id
    end

    def call
      rules = [container_rule]
      rules << area_rules if has_areas?
      rules << child_placement_rules if has_child_placements?
      rules.compact.join("\n\n")
    end

    private

    def selector = ".jigsaw-layout-#{@id}"

    def container_rule
      props = { "width" => "100%", "display" => "grid" }

      if has_areas?
        props["grid"] = grid_shorthand
      else
        props["grid-template-rows"] = track_list(@config["rows"])
        props["grid-template-columns"] = track_list(@config["columns"])
      end

      props["gap"] = gap_shorthand

      flow = auto_flow
      props["grid-auto-flow"] = flow if flow

      container = @config["containerAlignment"]
      if container.present?
        props["justify-content"] = container["horizontal"] if container["horizontal"].present? && container["horizontal"] != "stretch"
        props["align-content"] = container["vertical"] if container["vertical"].present? && container["vertical"] != "stretch"
      end

      children = @config["childrenAlignment"]
      if children.present?
        props["justify-items"] = children["horizontal"] if children["horizontal"].present? && children["horizontal"] != "stretch"
        props["align-items"] = children["vertical"] if children["vertical"].present? && children["vertical"] != "stretch"
      end

      body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
      "#{selector} {\n#{body}\n}"
    end

    def auto_flow
      direction = @config["direction"]
      dense = @config["emptySpace"] == "fill"

      if direction == "column" && dense
        "column dense"
      elsif direction == "column"
        "column"
      elsif dense
        "dense"
      end
    end

    def grid_shorthand
      rows = @config["rows"] || []
      areas = @config["areas"] || []
      cols = track_list(@config["columns"])

      if rows.is_a?(Array)
        lines = areas.each_with_index.map do |area_row, i|
          row_size = track_value(rows[i] || { "value" => 1, "unit" => "fr" })
          "\n    \"#{area_row.join(' ')}\" #{row_size}"
        end
      else
        lines = areas.each_with_index.map do |area_row, _i|
          row_size = track_value({ "value" => rows["value"], "unit" => rows["unit"] })
          "\n    \"#{area_row.join(' ')}\" #{row_size}"
        end
      end

      "#{lines.join}\n    / #{cols}"
    end

    def track_list(tracks)
      if tracks.blank?
        "1fr"
      elsif tracks.is_a?(Hash)
        size = track_value(tracks)
        "repeat(#{tracks['repeat']}, #{size})"
      else
        tracks.map { |t| track_value(t) }.join(" ")
      end
    end

    def track_value(track)
      if track.blank?
        "1fr"
      elsif track["unit"] == "auto"
        "auto"
      elsif track["unit"] == "min-content"
        "min-content"
      elsif track["unit"] == "max-content"
        "max-content"
      else
        unit = track["unit"] || "fr"
        "#{track['value']}#{unit}"
      end
    end

    def gap_shorthand
      row_gap = "#{@config['rowGap']}#{@config['rowGapUnit'] || 'px'}"
      col_gap = "#{@config['colGap']}#{@config['colGapUnit'] || 'px'}"
      if row_gap == col_gap
        row_gap
      else
        "#{row_gap} #{col_gap}"
      end
    end

    def has_areas?
      @config["areas"].present? && @config["areas"].flatten.any? { |s| s != "." }
    end

    def has_child_placements?
      @config["childPlacements"].present? && @config["childPlacements"].any? { |p| p.present? }
    end

    def area_rules
      slots = @config["areas"].flatten.uniq.reject { |s| s == "." }
      if slots.empty?
        nil
      else
        slots.map { |s| "#{selector} > .#{s} { grid-area: #{s}; }" }.join("\n")
      end
    end

    def child_placement_rules
      placements = @config["childPlacements"]
      rules = []

      placements.each_with_index do |placement, i|
        next if placement.blank?

        props = {}
        props["grid-row"] = placement["row"] if placement["row"].present?
        props["grid-column"] = placement["column"] if placement["column"].present?
        next if props.empty?

        class_name = placement_class_name(placement)
        body = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
        rules << "#{selector} > .#{class_name} {\n#{body}\n}"
      end

      rules.empty? ? nil : rules.uniq.join("\n\n")
    end

    def placement_class_name(placement)
      parts = []
      if placement["column"].present?
        parts << "col#{placement['column'].gsub(/\s*\/\s*/, 'Last').gsub('-', '')}"
      end
      if placement["row"].present?
        parts << "row#{placement['row'].gsub(/\s*\/\s*/, 'Last').gsub('-', '')}"
      end
      parts.join("")
    end
  end
end
