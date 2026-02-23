class CreatePostLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :post_likes do |t|
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
