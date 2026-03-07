class RemoveBodyFromPostComment < ActiveRecord::Migration[8.0]
  def change
    remove_column :post_comments, :body, :string
  end
end
