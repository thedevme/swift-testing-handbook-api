class CreateApiKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.string :email, null: false
      t.string :token, null: false

      t.timestamps
    end
    add_index :api_keys, :email, unique: true
    add_index :api_keys, :token, unique: true
  end
end
