class Communities::Settings::CustomDomainController < CommunitiesController
  layout "whole_page"
  before_action -> { authorize @community, policy_class: ::AdminPolicy }
  before_action :paywall_network_plan

  include Wicked::Wizard

  steps :connect, :configure, :confirm # formerly domain_connect, domain_configure, denouement

  def show
    case step
    when :connect
      return settings_custom_domain_path(:configure) if @community.domains.any?
    when :configure
      begin
        record = Whois.whois(@community.apex_domain)
        parser = record.parser
        @registrar = parser.registrar
      rescue
        @registrar = nil
      end
    end

    render_wizard(nil, layout: "whole_page")
  end

  def update
    case step
    when :connect
      if request.params[:domain][:domain].present?
        new_domain = request.params[:domain][:domain].downcase.strip
        ahoy.track("domain_connect", { domain: new_domain })
        add_domain(new_domain)
        return redirect_to settings_custom_domain_path(:configure)
      end
      return redirect_to settings_custom_domain_path(:connect)
    when :configure
      @community.domains.map(&:destroy)
      @community.reload
      return redirect_to settings_custom_domain_path(:connect)
    end

    render_wizard @community
  end

  private

  def add_domain(new_domain)
    @community.domains.map(&:destroy)
    @community.reload
    Domain.register(@community, new_domain)
  end
end
