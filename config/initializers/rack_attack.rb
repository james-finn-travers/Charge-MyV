class Rack::Attack
  # Throttle all requests by IP (60 req/min)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle login attempts (5 req/20 sec per IP)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end
end
