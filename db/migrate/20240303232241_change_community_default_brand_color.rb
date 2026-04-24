class ChangeCommunityDefaultBrandColor < ActiveRecord::Migration[7.1]
  def change
    change_column_default :communities, :brand_color, from: "#6e69e8", to: "#4D3DF7"
  end
end
