# https://stackoverflow.com/questions/77366033/allow-actiontext-tags-in-rails-7-1-with-new-sanitizers

Rails.application.config.after_initialize do
  default_allowed_attributes = Rails::HTML5::Sanitizer.safe_list_sanitizer.allowed_attributes + ActionText::Attachment::ATTRIBUTES.to_set
  custom_allowed_attributes = Set.new(%w[data-zoom-src srcset target fill-rule d clip-rule fill viewBox xmlns stroke-width stroke-linecap stroke-linejoin d class viewBox controls data-zoom-src srcset target])
  ActionText::ContentHelper.allowed_attributes = (default_allowed_attributes + custom_allowed_attributes).freeze

  default_allowed_tags = Rails::HTML5::Sanitizer.safe_list_sanitizer.allowed_tags + Set.new([ ActionText::Attachment.tag_name, "figure", "figcaption", "svg", "path", "video", "source" ])
  custom_allowed_tags = Set.new(%w[])
  ActionText::ContentHelper.allowed_tags = (default_allowed_tags + custom_allowed_tags).freeze
end
