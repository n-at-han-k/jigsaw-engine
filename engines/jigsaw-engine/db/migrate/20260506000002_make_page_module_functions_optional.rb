class MakePageModuleFunctionsOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :jigsaw_page_modules, :data_function_id, true
    change_column_null :jigsaw_page_modules, :render_function_id, true
  end
end
