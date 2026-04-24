class SetupController < ApplicationController
  layout "whole_page"
  prepend_before_action :protect_from_spam, only: [ :create ]

  def new
    @community = Community.new
  end

  def create
    @community = Community.new(community_params)
    @community.generate_slug
    if @community.save
      @community.members.invite!(email: @community.email, permission: :admin, notify_new_posts_email: true, notify_new_posts_push: true, source: "creator")
      render :welcome, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def community_params
    params.require(:community).permit(:name, :slug, :email)
  end
end
