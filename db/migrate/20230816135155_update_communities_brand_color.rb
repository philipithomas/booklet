class UpdateCommunitiesBrandColor < ActiveRecord::Migration[7.0]
  def change
    # Update records with null brand_color to default
    # Community.where(brand_color: nil).update_all(brand_color: "#6e69e8")

    # Change the default value and make it NOT NULL
    change_column_default :communities, :brand_color, "#6e69e8"
    change_column_null :communities, :brand_color, false
  end
end
