class AddTokenToAhoyMessages < ActiveRecord::Migration[7.0]
  def change
    change_table :ahoy_messages do |t|
      t.string :token, null: true, index: { unique: true }
    end
  end
end
