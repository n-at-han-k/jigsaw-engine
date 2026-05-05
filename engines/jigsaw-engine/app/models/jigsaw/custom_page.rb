module Jigsaw
  class CustomPage < ApplicationRecord
    belongs_to :layout, optional: true
    has_many :page_modules, -> { order(:position) }, dependent: :destroy

    validates :path, presence: true, uniqueness: true
    validates :title, presence: true
  end
end
