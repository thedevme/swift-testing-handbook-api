# config/initializers/rack_attack.rb
# Rate limiting for Flight API

class Rack::Attack
  ### Configure Cache ###
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Safelist ###
  # Allow unlimited requests from localhost (development)
  safelist('allow-localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  # Safelist health checks
  safelist('allow-health-check') do |req|
    req.path == '/health' || req.path == '/up'
  end

  ### Throttles ###

  # 1. API Key Creation - Prevent abuse
  throttle('keys/ip', limit: 10, period: 1.hour) do |req|
    req.ip if req.path == '/api/v1/keys' && req.post?
  end

  # 2. Key Recovery - Prevent spam
  throttle('keys/recover', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/api/v1/keys/recover' && req.post?
  end

  # 3. Booking Creation - Prevent spam bookings (lenient for demo)
  throttle('bookings/key', limit: 50, period: 1.hour) do |req|
    if req.path.include?('/api/v1/bookings') && req.post?
      req.get_header('HTTP_AUTHORIZATION')&.sub('Bearer ', '')
    end
  end

  # 4. Multi-city/Round-trip - More expensive queries
  throttle('complex_search/key', limit: 30, period: 1.hour) do |req|
    if (req.path.include?('/api/v1/flights/multi_city') ||
        req.path.include?('/api/v1/flights/round_trip') ||
        req.path.include?('/api/v1/itineraries')) && req.post?
      req.get_header('HTTP_AUTHORIZATION')&.sub('Bearer ', '')
    end
  end

  # 5. General API requests - All other endpoints (very lenient for demo)
  throttle('api/key', limit: 500, period: 1.hour) do |req|
    if req.path.start_with?('/api/v1/')
      req.get_header('HTTP_AUTHORIZATION')&.sub('Bearer ', '')
    end
  end

  # 6. Catch-all for unauthenticated requests
  throttle('unauthenticated/ip', limit: 100, period: 1.hour) do |req|
    if req.path.start_with?('/api/v1/') && !req.get_header('HTTP_AUTHORIZATION')
      req.ip
    end
  end

  # 7. Gumroad webhook (existing)
  throttle('gumroad/ping', limit: 20, period: 1.hour) do |req|
    req.ip if req.path == '/gumroad/ping' && req.post?
  end

  ### Custom Throttle Response ###
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = Time.now
    period = match_data[:period]
    limit = match_data[:limit]
    retry_after = (period - (now.to_i % period))

    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s,
        'X-RateLimit-Limit' => limit.to_s,
        'X-RateLimit-Remaining' => '0',
        'X-RateLimit-Reset' => (now + retry_after).to_i.to_s
      },
      [{
        error: 'rate_limited',
        message: 'Too many requests. Please try again later.',
        code: 'RATE_LIMITED',
        retry_after_seconds: retry_after,
        limit: limit
      }.to_json]
    ]
  end

  ### Logging ###
  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled #{req.env['rack.attack.matched']}: #{req.ip} on #{req.path}"
  end
end
