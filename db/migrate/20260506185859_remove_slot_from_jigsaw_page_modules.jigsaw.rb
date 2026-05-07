# This migration comes from jigsaw (originally 20260506000001)
class RemoveSlotFromJigsawPageModules < ActiveRecord::Migration[8.1]
  def change
    remove_column :jigsaw_page_modules, :slot, :string
  end
end
