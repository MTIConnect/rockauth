class CreateRockauthAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :resource_owner, polymorphic: true
      t.references :provider_authentication, index: true, foreign_key: true
      t.integer :expiration
      t.string :auth_type, null: false
      t.string :salt
      t.string :encrypted_token
      t.string :client_id, null: false
      t.string :client_version
      t.string :client_os

      t.timestamps null: false
    end

    add_index :provider_authentications, [:resource_owner_id, :resource_owner_type], name: 'index_authentications_on_resource_owner'
  end
end
