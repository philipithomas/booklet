module CustomTurboStreamActions
  # turbo_stream.redirect(model_url(@model))
  def redirect(url)
    action(:redirect, url)
  end
end

Turbo::Streams::TagBuilder.include(CustomTurboStreamActions)
