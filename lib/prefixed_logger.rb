module PrefixedLogger
  def log_info(message)
    Rails.logger.info "[#{log_prefix}] #{message}"
  end

  def log_error(message)
    Rails.logger.error "[#{log_prefix}] #{message}"
  end

  def log_warning(message)
    Rails.logger.warn "[#{log_prefix}] #{message}"
  end

  private

  def log_prefix
    calling_method = caller_locations(2, 1)[0].label
    method(calling_method).owner
  rescue NameError
    self.class.name
  end
end
