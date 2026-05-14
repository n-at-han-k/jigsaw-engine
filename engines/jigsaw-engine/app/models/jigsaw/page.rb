module Jigsaw
  class Page < ApplicationRecord
    has_one :layout, dependent: :destroy

    validates :path, presence: true, uniqueness: true
    validates :title, presence: true
  end
end
