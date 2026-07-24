class Growth < ApplicationRecord
  def self.chart_data
    data = []
    data << {
      name: "Posters",
      data: Post.joins(:community).where.not(communities: { slug: "demo" }).group_by_week(:published_at).distinct.count(:member_id).sort.to_h.reject { |k, v| k > Time.zone.today },
      color: "#f86a6a"
    }
    data << {
      name: "Engaged members",
      data: Ahoy::Event.group_by_week(:time).distinct.count(:user_id).sort.to_h.reject { |k, v| k > Time.zone.today },
      color: "#4D3DF7"
    }
    data << {
      name: "Contacted members",
      data: Ahoy::Message.group_by_week(:sent_at).distinct.count(:user_id).sort.to_h.reject { |k, v| k > Time.zone.today },
      color: "#7E7E7E"
    }

    # Ensure all data series have the same keys
    all_keys = data.map { |series| series[:data].keys }.flatten.uniq
    data.each do |series|
      series[:data] = all_keys.each_with_object({}) do |key, hash|
        hash[key] = series[:data][key] || 0
      end
    end
    # Add keys in the correct order so keys are still in order
    data.each do |series|
      series[:data] = series[:data].sort.to_h
    end
  end

  def self.contact_change
    data = Ahoy::Message.group_by_week(:sent_at).distinct.count(:user_id).sort.to_h.reject { |k, v| k > Time.zone.today }
    current_week = data.keys.last
    last_week = data.keys[-2]
    current_week_count = data[current_week] || 0
    last_week_count = data[last_week] || 0
    change = ((current_week_count - last_week_count) / last_week_count.to_f) * 100
    change.nan? ? 0 : change
  end
end
