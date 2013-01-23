class RenameTypeToLinks < ActiveRecord::Migration
  def change
    rename_column("links", :type, :content_type)
  end
end
