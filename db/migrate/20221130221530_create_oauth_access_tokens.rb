class CreateOauthAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_access_tokens do |t|
      t.references :resource_owner, index: true
      t.text :token, null: false
      t.text :refresh_token, null: false
      t.datetime :expired_at, null: false
      t.datetime :created_at, null: false
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id
  end
end
