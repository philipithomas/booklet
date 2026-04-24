Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      community: controller.instance_variable_get(:@community)&.id,
      member: controller.current_member&.id,
      post: controller.instance_variable_get(:@post)&.id,
      reply: controller.instance_variable_get(:@reply)&.id,
      remote_ip: controller.request.remote_ip,
      params: controller.params.to_unsafe_h,
      request_id: controller.request.request_id,
      fly_alloc_id: ENV["FLY_ALLOC_ID"],
      fly_region: ENV["FLY_REGION"],
      fly_public_ip: ENV["FLY_PUBLIC_IP"],
      fly_machine_id: ENV["FLY_MACHINE_ID"],
      fly_process_group: ENV["FLY_PROCESS_GROUP"],
      fly_vm_memory_mb: ENV["FLY_VM_MEMORY_MB"],
      fly_client_ip: controller.request.headers["fly-client-ip"],
      fly_edge_region: controller.request.headers["fly-region"]
    }.compact
  end
end
