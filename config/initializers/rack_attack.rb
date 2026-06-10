# frozen_string_literal: true

# Rate limiting for authentication endpoints. Counters live in Rails.cache;
# with the default per-process memory store the limits are approximate (each
# web process counts separately) — point Rails.cache at a shared store if
# exact limits matter. Disabled outside production to keep development and
# tests unthrottled.

if Rails.env.production?
  class Rack::Attack
    ### Throttle Spammy Clients ###

    # Throttle all requests by IP
    throttle("req/ip", limit: 1000, period: 5.minutes, &:ip)

    ### Prevent Brute-Force Login Attacks ###

    throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == "/sign-in" && req.post?
    end

    throttle("logins/ip-hourly", limit: 50, period: 1.hour) do |req|
      req.ip if req.path == "/sign-in" && req.post?
    end

    throttle("logins/email", limit: 10, period: 20.minutes) do |req|
      if req.path == "/sign-in" && req.post? && req.params["member"].is_a?(Hash)
        req.params["member"]["email"].to_s.downcase.strip.presence
      end
    end

    # A blank password on /sign-in requests a fresh login pin by email —
    # keep the email-send volume per address low.
    throttle("pins/email", limit: 6, period: 1.hour) do |req|
      if req.path == "/sign-in" && req.post? && req.params["member"].is_a?(Hash) &&
          req.params["member"]["password"].to_s.strip.blank?
        req.params["member"]["email"].to_s.downcase.strip.presence
      end
    end

    throttle("editor-logins/ip", limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == "/editors/sign_in" && req.post?
    end

    ### Prevent Mass Signups ###

    # Member registration (and, in multiuser mode, community creation on the
    # signup host) both POST to the root path.
    throttle("signups/ip", limit: 5, period: 1.minute) do |req|
      req.ip if req.path == "/" && req.post?
    end

    throttle("signups/ip-hourly", limit: 60, period: 1.hour) do |req|
      req.ip if req.path == "/" && req.post?
    end
  end
end
