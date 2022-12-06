class AddTimeStampToOauthAccessTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :oauth_access_tokens, :updated_at, :datetime, null: false
  end
end
