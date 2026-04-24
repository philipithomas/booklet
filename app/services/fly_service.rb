class FlyService
  include HTTParty
  debug_output $stderr if Rails.env.development?
  base_uri "api.fly.io:443/graphql"
  headers "Authorization" => "Bearer #{ENV["FLY_API_TOKEN"]}"
  format :json
  attr_reader :app_id

  class FlyGraphqlError < StandardError
    def initialize(message = "Error in FlyGraphql")
      super
    end
  end

  def initialize(app_id = ENV["FLY_APP_ID"])
    @app_id = app_id
  end

  def add(host_name)
    query = <<~QUERY.strip
      mutation {
        addCertificate(appId: "#{app_id}", hostname: "#{host_name}") {
          certificate {
            hostname,
            id
          }
        }
      }
    QUERY
    execute(query).dig("data", "addCertificate", "certificate")
  end

  def delete(host_name)
    query = <<~QUERY.strip
      mutation {
        deleteCertificate(appId: "#{app_id}", hostname: "#{host_name}") {
          certificate {
            hostname,
            id
          }
        }
      }
    QUERY
    execute(query).dig("data", "deleteCertificate", "certificate")
  end

  def list
    query = <<~QUERY.strip
      query {
        app(name: "#{app_id}") {
          certificates {
            nodes {
              hostname,
              id,
              clientStatus
            }
          }
        }
      }
    QUERY
    execute(query).dig("data", "app", "certificates", "nodes")
  end

  def find(host_name)
    query = <<~QUERY.strip
      query {
        app(name: "#{app_id}") {
          certificate(hostname: "#{host_name}") {
            check
            configured
            acmeDnsConfigured
            acmeAlpnConfigured
            certificateAuthority
            createdAt
            dnsProvider
            dnsValidationInstructions
            dnsValidationHostname
            dnsValidationTarget
            hostname
            id
            source
            clientStatus
            issued {
              nodes {
                type
                expiresAt
              }
            }
          }
        }
      }
    QUERY
    execute(query).dig("data", "app")
  end

  private

  def execute(query)
    self.class.post("/", body: { query: query }).tap do |response|
      errors = response.dig("errors") || []
      if errors.any?
        raise FlyGraphqlError.new(errors.map { |err| err["message"] }.join(" -  "))
      end
    end
  end
end
