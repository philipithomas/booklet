class MakePinnedPostForeignKey < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :communities, :posts, column: :pinned_post_id, validate: false, on_delete: :nullify
  end
end
