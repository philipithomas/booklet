module ButtonComponents
  def submit_dynamic(*args, &block)
    data = {
      controller: "dynamic",
      dynamic_target: "button",
      action: "turbo:submit-start@document->dynamic#displayLoading"
    }

    options = args.extract_options!
    data.merge!(options.delete(:data) || {})
    # Expects a label option
    raise ArgumentError, "Missing label option" unless options[:label]

    template.button_tag(
      template.content_tag(
        :span, options[:label], class: "btn-text"
      ) + template.heroicon("arrow-right", options: { class: "btn-icon", "data-dynamic-target": "arrow" }, variant: :mini) + template.render("components/shared/button_spinner"),
      type: "submit",
      class: SimpleForm.button_class + (options[:full_width] ? " w-full" : ""),
      data: data
    )
  end
end

SimpleForm::FormBuilder.send :include, ButtonComponents
