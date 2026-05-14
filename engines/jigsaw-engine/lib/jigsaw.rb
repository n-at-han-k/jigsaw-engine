module Jigsaw
  def self.dynamic_page_routes(mapper)
    if ActiveRecord::Base.connection.data_source_exists?("jigsaw_pages")
      Jigsaw::Page.where.not(path: [nil, ""]).find_each do |page|
        mapper.get page.path, to: "jigsaw/pages#show", defaults: { path: page.path }, as: "page_#{page.id}_route"
      end
    end
  rescue StandardError => e
    Rails.logger.warn("[jigsaw] skipping dynamic page routes: #{e.class}: #{e.message}") if defined?(Rails.logger)
  end
end
