class ChangeOauthAccessTokens < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :oauth_access_tokens, column: :resource_owner_id
    remove_reference :oauth_access_tokens, :resource_owner, index: true
    add_reference :oauth_access_tokens, :user, index: true, foreign_key: true
  end
end
