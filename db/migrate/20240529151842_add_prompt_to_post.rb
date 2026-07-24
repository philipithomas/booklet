class AddPromptToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :prompt, :string
  end
end
