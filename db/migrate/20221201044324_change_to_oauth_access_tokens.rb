class ChangeToOauthAccessTokens < ActiveRecord::Migration[7.0]
  def change
    remove_reference :oauth_access_tokens, :users, index: true, foreign_key: true
    add_reference :oauth_access_tokens, :user, index: true, foreign_key: true
  end
end
