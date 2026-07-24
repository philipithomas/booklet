class EditorController < ApplicationController
  before_action :authenticate_editor!
  before_action :skip_authorization
  layout "editor"

  def find_current_auditor
    current_editor
  end
end
