class DisposableEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if DisposableEmailService.disposable?(value)
      record.errors.add(attribute, (options[:message] || "is not deliverable"))
    end
  end
end
