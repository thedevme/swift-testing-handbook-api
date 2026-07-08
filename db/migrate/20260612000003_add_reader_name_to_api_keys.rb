class AddReaderNameToApiKeys < ActiveRecord::Migration[8.1]
  def change
    add_column :api_keys, :reader_name, :string
    add_index :api_keys, :reader_name
  end
end
