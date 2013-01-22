class AddUidToLinks < ActiveRecord::Migration
  def change
    add_column :links, :uid, :integer
  end
end
