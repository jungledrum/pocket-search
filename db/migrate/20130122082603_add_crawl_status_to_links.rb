class AddCrawlStatusToLinks < ActiveRecord::Migration
  def change
    add_column :links, :crawl_status, :integer
  end
end
