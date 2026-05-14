# Jigsaw Engine Seeds
#
# Seeds the database with SlotTemplate records from the
# app/javascript/seeds/ directory structure.
#
# Each leaf directory containing config.json, data.js, and render.jsx
# becomes a SlotTemplate record. Tags are derived from the path segments.
#
# Usage:
#   bin/rails db:seed
#   # or load directly:
#   load Jigsaw::Engine.root.join("db/seeds.rb")

module Jigsaw
  class SeedLoader
    SEEDS_PATH = Engine.root.join("app/javascript/seeds")

    def call
      puts "[jigsaw] Seeding slot templates from #{SEEDS_PATH}..."

      count = 0
      seed_dirs.each do |dir|
        seed_slot_template(dir)
        count += 1
      end

      puts "[jigsaw] Seeded #{count} slot templates."
    end

    private

      def seed_dirs
        Dir.glob(SEEDS_PATH.join("**/config.json")).map { |f| File.dirname(f) }.sort
      end

      def seed_slot_template(dir)
        relative_path = Pathname.new(dir).relative_path_from(SEEDS_PATH).to_s
        name = humanize_path(relative_path)
        tags = derive_tags(relative_path)

        config_json = File.read(File.join(dir, "config.json"))
        data_js = File.read(File.join(dir, "data.js"))
        render_file = Dir.glob(File.join(dir, "render.*")).first
        render_source = render_file ? File.read(render_file) : ""
        render_language = render_file&.end_with?(".jsx") ? "jsx" : "javascript"

        config = begin
          JSON.parse(config_json)
        rescue JSON::ParserError
          {}
        end

        # Extract shares from config if present (it's a slot-level concept)
        shares = config.delete("shares") || []

        st = SlotTemplate.find_or_initialize_by(name: name)
        st.assign_attributes(
          data_source: data_js,
          render_source: render_source,
          render_language: render_language,
          config: config,
          shares: shares
        )
        st.tag_list = tags.join(", ")
        st.save!

        print "."
      rescue => e
        puts "\n[jigsaw] ERROR seeding #{dir}: #{e.message}"
      end

      def humanize_path(relative_path)
        # "blocks/marketing/hero-section-1" -> "Marketing / Hero Section 1"
        # "ide-editor" -> "IDE Editor"
        # "examples/blog-cards-2" -> "Examples / Blog Cards 2"
        segments = relative_path.split("/")
        segments.map { |s| humanize_segment(s) }.join(" / ")
      end

      def humanize_segment(segment)
        segment
          .gsub("-", " ")
          .gsub(/\b(ui|ide|css|html|js|jsx)\b/i) { |m| m.upcase }
          .split(" ")
          .map(&:capitalize)
          .join(" ")
      end

      def derive_tags(relative_path)
        # "blocks/marketing/hero-section-1" -> ["blocks", "marketing", "hero-section"]
        # "blocks/ecommerce/product-list-3" -> ["blocks", "ecommerce", "product-list"]
        # "ide-editor" -> ["ide"]
        # "examples/chat-bubbles-4" -> ["examples", "chat-bubbles"]
        segments = relative_path.split("/")
        tags = []

        segments.each_with_index do |segment, i|
          if i == segments.length - 1
            # Last segment: strip trailing variant number
            tag = strip_variant_number(segment)
          else
            tag = segment
          end
          tags << tag unless tag.blank?
        end

        tags.uniq
      end

      def strip_variant_number(segment)
        # "hero-section-1" -> "hero-section"
        # "charts-20" -> "charts"
        # "ide-editor" -> "ide-editor" (no trailing number after last hyphen? keep as-is)
        # "authentication-forms-3" -> "authentication-forms"
        segment.sub(/-\d+\z/, "")
      end
  end
end

Jigsaw::SeedLoader.new.call
