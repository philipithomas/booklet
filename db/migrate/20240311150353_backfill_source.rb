class BackfillSource < ActiveRecord::Migration[7.1]
  def change
    Member.find_each do |member|
      if member.invited_by_id.present?
        member.update_column(:source, "invited")
      elsif member.admin?
        member.update_column(:source, "creator")
      else
        member.update_column(:source, "public_join")
      end
    end
  end
end
