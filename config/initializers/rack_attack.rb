class Rack::Attack
  # Throttle API requests by API key
  throttle('api/key', limit: 200, period: 1.hour) do |req|
    req.get_header('HTTP_AUTHORIZATION')&.sub('Bearer ', '') if req.path.start_with?('/api/')
  end

  # Throttle Gumroad pings by IP
  throttle('gumroad/ping', limit: 20, period: 1.hour) do |req|
    req.ip if req.path == '/gumroad/ping' && req.post?
  end

  # Throttle key recovery by IP
  throttle('keys/recover', limit: 3, period: 1.hour) do |req|
    req.ip if req.path == '/api/v1/keys/recover' && req.post?
  end

  # Custom response for rate limiting
  self.throttled_responder = lambda do |req|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'rate_limited', message: 'Too many requests', code: 'RATE_LIMITED' }.to_json]
    ]
  end
end
