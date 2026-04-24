Notable.user_method = lambda do |env|
  env["action_controller.instance"].try(:current_member)
end

Notable.track_request_method = lambda do |data, env|
  Notable::Request.create!(data) unless URI(data[:url])&.path&.starts_with?("/pay/")
end
