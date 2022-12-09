RSpec.shared_context 'authenticated request' do
  def send_request(
    path:,
    action:,
    authenticated: true,
    token: nil,
    resource_owner: nil
  )
    headers = { 'Accept' => 'application/json' }
    if authenticated
      if resource_owner.blank? && token.blank?
        raise 'resource owner or token needed'
      end
      token ||= Authenticator.sign_in(resource_owner)
      headers['Authorization'] = "Bearer #{token.token}"
    end
    public_send(action, path, params: params, headers: headers, as: :json)
  end
end
