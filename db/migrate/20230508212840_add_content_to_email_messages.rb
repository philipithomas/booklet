class AddContentToEmailMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :ahoy_messages, :content, :text
  end
end
