# frozen_string_literal: true

class Editor::SessionsController < Devise::SessionsController
  layout "whole_page"
  before_action :skip_authorization

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    return redirect_to editor_root_path unless params[:editor][:email].present? && params[:editor][:password].present?

    # Manually find the editor based on your custom logic

    editor = Editor.find_by(email: params[:editor][:email])

    # Manually authenticate the editor
    if editor&.valid_password?(params[:editor][:password])
      sign_in(:editor, editor)
      redirect_to editor_root_path # or wherever you want to redirect
    else
      flash[:alert] = "Invalid email or password"
      render :new, status: :unauthorized
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
