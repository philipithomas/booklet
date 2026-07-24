class Communities::PwaController < CommunitiesController # :nodoc:
  skip_forgery_protection
  skip_after_action :verify_authorized

  def service_worker
    render "service_worker", layout: false
  end

  def manifest
    render "manifest", layout: false
  end
end
