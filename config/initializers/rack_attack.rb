# require "redis"

# class Rack::Attack
#   ### Configure Cache ###

#   # If you don't want to use Rails.cache (Rack::Attack's default), then
#   # configure it here.
#   #
#   # Note: The store is only used for throttling (not blocklisting and
#   # safelisting). It must implement .increment and .write like
#   # ActiveSupport::Cache::Store

#   safelist("allow from Cloudfront") do |req|
#     req.env["CLOUDFRONT_VALIDATION_KEY"] == Rails.application.credentials.cloudfront_validation_header
#   end

#   Rack::Attack.cache.store = if Rails.env.production?
#     Redis.new(
#       password: Rails.application.credentials.redis_throttle_password,
#       host: "#{ENV["FLY_REGION"]}.bklt-throttle.internal",
#       port: 6379
#     )
#   else
#     Rails.cache
#   end
#   ### Throttle Spammy Clients ###

#   # If any single client IP is making tons of requests, then they're
#   # probably malicious or a poorly-configured scraper. Either way, they
#   # don't deserve to hog all of the app server's CPU. Cut them off!
#   #
#   # Note: If you're serving assets through rack, those requests may be
#   # counted by rack-attack and this throttle may be activated too
#   # quickly. If so, enable the condition to exclude them from tracking.

#   # Throttle all requests by IP (60rpm)
#   #
#   # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
#   throttle("req/ip", limit: 1000, period: 5.minutes) do |req|
#     req.env["HTTP_FLY_CLIENT_IP"]
#   end

#   ### Prevent Brute-Force Login Attacks ###

#   # The most common brute-force login attack is a brute-force password
#   # attack where an attacker simply tries a large number of emails and
#   # passwords to see if any credentials match.
#   #
#   # Another common method of attack is to use a swarm of computers with
#   # different IPs to try brute-forcing a password for a specific account.

#   # Throttle POST requests to /login by IP address
#   #
#   # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"

#   throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
#     if req.path == "/sign-in" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   throttle("logins/ip-hour", limit: 50, period: 1.hour) do |req|
#     if req.path == "/sign-in" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   throttle("logins/email", limit: 5, period: 60.seconds) do |req|
#     if req.path == "/sign-in" && req.post? && req.params["member"].present?
#       req.params["member"]["email"].to_s.downcase.strip
#     end
#   end

#   throttle("logins/email-hourly", limit: 10, period: 20.minutes) do |req|
#     if req.path == "/sign-in" && req.post? && req.params["member"].present?
#       req.params["member"]["email"].to_s.downcase.strip
#     end
#   end

#   throttle("editor-logins/ip", limit: 5, period: 20.seconds) do |req|
#     if req.path == "/editors/sign_in" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   throttle("signups/ip", limit: 5, period: 1.minute) do |req|
#     if req.path == "/sign-up" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   throttle("signups/ip-hourly", limit: 60, period: 1.hour) do |req|
#     if req.path == "/sign-up" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   # Throttle new creations
#   throttle("communities/ip", limit: 10, period: 1.minute) do |req|
#     if (req.host == Rails.configuration.signup_host) && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   throttle("communities/ip-hourly", limit: 20, period: 1.hour) do |req|
#     if (req.host == Rails.configuration.signup_host) && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   ### Prevent Brute-Force Passwordless Login Attacks ###
#   throttle("passwordless/email", limit: 20, period: 24.hours) do |req|
#     if req.path == "/passwordless" && req.post? && req.params["member"].present?
#       req.params["member"]["email"].to_s.downcase.strip
#     end
#   end

#   throttle("passwordless/email", limit: 5, period: 1.hour) do |req|
#     if req.path == "/passwordless" && req.post? && req.params["member"].present?
#       req.params["member"]["email"].to_s.downcase.strip
#     end
#   end

#   throttle("passwordless/email", limit: 1, period: 10.seconds) do |req|
#     if req.path == "/passwordless" && req.post? && req.params["member"].present?
#       req.params["member"]["email"].to_s.downcase.strip
#     end
#   end

#   throttle("passwordless/ip", limit: 20, period: 24.hours) do |req|
#     if req.path == "/passwordless" && req.post?
#       req.env["HT
#   TP_FLY_CLIENT_IP"] end
#   end

#   throttle("passwordless/ip", limit: 5, period: 1.hour) do |req|
#     if req.path == "/passwordless" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   throttle("passwordless/ip", limit: 1, period: 10.seconds) do |req|
#     if req.path == "/passwordless" && req.post?
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   # Throttle POST requests to /login by email param
#   #
#   # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{normalized_email}"
#   #
#   # Note: This creates a problem where a malicious user could intentionally
#   # throttle logins for another user and force their login requests to be
#   # denied, but that's not very common and shouldn't happen to you. (Knock
#   # on wood!)
#   throttle("logins/email", limit: 5, period: 20.seconds) do |req|
#     if req.path == "/sign-in" && req.post?
#       # Normalize the email, using the same logic as your authentication process, to
#       # protect against rate limit bypasses. Return the normalized email if present, nil otherwise.
#       begin
#         req.params["member"]["email"].to_s.downcase.gsub(/\s+/, "").presence
#       rescue
#         nil
#       end
#     end
#   end

#   throttle("ahoy/ip", limit: 200, period: 1.minute) do |req|
#     if req.path.start_with?("/labyrinth/")
#       req.env["HTTP_FLY_CLIENT_IP"]
#     end
#   end

#   ### Custom Throttle Response ###

#   # By default, Rack::Attack returns an HTTP 429 for throttled responses,
#   # which is just fine.
#   #
#   # If you want to return 503 so that the attacker might be fooled into
#   # believing that they've successfully broken your app (or you just want to
#   # customize the response), then uncomment these lines.
#   # self.throttled_responder = lambda do |env|
#   #  [ 503,  # status
#   #    {},   # headers
#   #    ['']] # body
#   # end
# end
