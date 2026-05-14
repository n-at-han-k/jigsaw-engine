module Jigsaw
  class Page < ApplicationRecord
    has_one :layout, dependent: :destroy

    accepts_nested_attributes_for :layout, update_only: true

    before_validation :normalize_path

    validates :path, presence: true, uniqueness: true
    validates :title, presence: true

    after_save    :reload_application_routes, if: :saved_change_to_path?
    after_destroy :reload_application_routes

    after_save :sync_layout_slots, if: :layout

    private

      def normalize_path
        return if path.nil?
        self.path = path.to_s.strip.delete_prefix("/")
      end

      def sync_layout_slots
        layout.sync_slots if layout&.saved_change_to_config?
      end

      def reload_application_routes
        return unless defined?(Rails) && Rails.application
        Rails.application.reload_routes!
      rescue StandardError => e
        Rails.logger.warn("[jigsaw] failed to reload routes: #{e.class}: #{e.message}") if defined?(Rails.logger)
      end
  end
end
