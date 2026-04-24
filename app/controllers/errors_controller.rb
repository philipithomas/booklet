class ErrorsController < ApplicationController
  layout "error"
  before_action :set_community

  def show
    @exception = request.env["action_dispatch.exception"]
    @status_code = @exception.try(:status_code) ||
      ActionDispatch::ExceptionWrapper.new(
        request.env, @exception
      ).status_code

    # In development environments show the stack trace
    if Rails.env.development?
      @trace = @exception.try(:backtrace)
    end

    if request.host == Rails.configuration.api_host
      if Rails.env.development?
        render json: { error: view_for_code(@status_code), exception: @exception.message, trace: @trace }, status: @status_code
      else
        render json: { error: view_for_code(@status_code) }, status: @status_code
      end
    else
      render view_for_code(@status_code), status: @status_code
    end
  end

  private

  def view_for_code(code)
    supported_error_codes.fetch(code, "404")
  end

  def supported_error_codes
    {
      403 => "403",
      404 => "404",
      429 => "429",
      500 => "500",
      503 => "503"
    }
  end
end
