class ClearbitBackfill < ActiveRecord::Migration[7.1]
  def change
    # Clearbit integration removed. This migration was a data backfill
    # and is retained as a no-op for schema history integrity.
  end
end
