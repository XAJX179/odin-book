class AddBodyToPostComment < ActiveRecord::Migration[8.0]
  def change
    add_column :post_comments, :body, :string
  end
end
