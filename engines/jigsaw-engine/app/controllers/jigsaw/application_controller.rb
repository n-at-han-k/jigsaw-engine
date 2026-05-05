module Jigsaw
  class ApplicationController < ActionController::Base
    ActionView::Base.default_form_builder = Ui::FomanticFormBuilder
  end
end
