class Editor::GrowthChartController < EditorController
  def index
    @contacted_change = Growth.contact_change
  end

  def data
    render json: Growth.chart_data
  end
end
