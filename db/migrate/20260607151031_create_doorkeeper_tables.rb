# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[7.1]
  def change

    create_table :oauth_access_tokens do |t|
      t.references :resource_owner, index: true
      t.string :token, null: false
      t.string   :refresh_token
      t.integer  :expires_in
      t.string   :scopes
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string   :previous_refresh_token, null: false, default: ""
    end

    add_index :oauth_access_tokens, :token, unique: true

    # See https://github.com/doorkeeper-gem/doorkeeper/issues/1592
    if ActiveRecord::Base.connection.adapter_name == "SQLServer"
      execute <<~SQL.squish
        CREATE UNIQUE NONCLUSTERED INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens(refresh_token)
        WHERE refresh_token IS NOT NULL
      SQL
    else
      add_index :oauth_access_tokens, :refresh_token, unique: true
    end

    # Uncomment below to ensure a valid reference to the resource owner's table
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id
  end
end
