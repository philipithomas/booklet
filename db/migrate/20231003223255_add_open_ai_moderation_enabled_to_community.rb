class AddOpenAIModerationEnabledToCommunity < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :open_ai_content_moderation_enabled, :boolean, null: false, default: true
    add_column :communities, :open_ai_member_moderation_enabled, :boolean, null: false, default: false
  end
end
