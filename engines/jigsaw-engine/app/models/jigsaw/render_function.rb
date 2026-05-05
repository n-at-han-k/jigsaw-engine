module Jigsaw
  class RenderFunction < ApplicationRecord
    has_many :page_modules, dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: true
    validates :source, presence: true
    validates :language, presence: true, inclusion: { in: %w[javascript jsx] }
    validate :default_export_uses_function_syntax

    before_save :compile_source

    private

    def compile_source
      if language == "jsx" && source_changed?
        self.compiled_source = JsxCompiler.compile(source)
      elsif language == "javascript"
        self.compiled_source = source
      end
      self.compiled_digest = Digest::SHA256.hexdigest(source)
    end

    def default_export_uses_function_syntax
      return if source.blank?
      if source.match?(/export\s+default\s*\(/) || source.match?(/export\s+default\s+\w+\s*=>/)
        errors.add(:source, "default export must use function syntax, not arrow functions (this-binding requirement)")
      end
    end
  end
end
