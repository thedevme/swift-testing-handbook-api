module ApiHelpers
  def auth_headers(api_key)
    { 'Authorization' => "Bearer #{api_key.token}" }
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
