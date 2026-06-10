class CustomDeviseFailureApp < Devise::FailureApp
  # Devise's scope_url, with the request host preserved so each community
  # (and the editor subdomain) redirects to the sign-in page on its own host.
  def scope_url
    opts = {}

    # THIS IS THE CUSTOM PART
    opts[:host] = request.host

    # Initialize script_name with nil to prevent infinite loops in
    # authenticated mounted engines
    opts[:script_name] = nil

    route = route(scope)

    opts[:format] = request_format unless skip_format?

    router_name = Devise.mappings[scope].router_name || Devise.available_router_name
    context = send(router_name)

    if relative_url_root?
      opts[:script_name] = relative_url_root
    end

    if context.respond_to?(route)
      context.send(route, opts)
    elsif respond_to?(:root_url)
      root_url(opts)
    else
      "/"
    end
  end
end
