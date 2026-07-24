class CreateViewJob < ApplicationJob
  queue_as :high

  def perform(member_id, viewable, ahoy_visit_id)
    View.create!(member_id: member_id, viewable: viewable, ahoy_visit_id: ahoy_visit_id)
  end
end
