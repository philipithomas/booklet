class NewsletterCommunityForeignKey < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :newsletters, :communities, validate: false
  end
end
