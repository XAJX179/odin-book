class RemoveBodyFromPost < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :body, :string
  end
end
