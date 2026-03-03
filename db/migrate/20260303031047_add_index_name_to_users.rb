class AddIndexNameToUsers < ActiveRecord::Migration[8.0]
  def up
    change_table :users do |t|
      t.change :name, :string, null: false
    end
    add_index :users, 'lower(name)', name: 'index_users_on_unique_name', unique: true
  end

  def down
    change_table :users do |t|
      t.remove_index name: 'index_users_on_unique_name'
      t.change :name, :string
    end
  end
end
