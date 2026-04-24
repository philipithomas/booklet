class AddMaxMemberDirectAddsToPerson < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :max_member_direct_adds, :integer, default: 10000
  end
end
