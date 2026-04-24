class Communities::Settings::APIKeysController < CommunitiesController
  layout "settings", only: [ :index ]

  before_action -> { authorize @community, policy_class: ::AdminPolicy }
  before_action :set_api_key, only: [ :destroy ]
  before_action :paywall_network_plan, only: [ :create, :new ]

  def index
    @api_keys = @community.api_keys
  end

  def new
    @api_key = @community.api_keys.new
    render :new, layout: "whole_page"
  end

  def create
    @api_key = @community.api_keys.new(api_key_params)

    if @api_key.save
      render :create, layout: "whole_page", status: :created
    else
      flash.now[:alert] = @api_key.errors.full_messages.to_sentence
      render :new, layout: "whole_page", status: :unprocessable_entity
    end
  end

  def destroy
    @api_key.soft_destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_api_keys_path, status: :see_other }
    end
  end

  private

  def set_api_key
    @api_key = @community.api_keys.find(params[:id])
  end

  def api_key_params
    params.require(:api_key).permit(:name)
  end
end
