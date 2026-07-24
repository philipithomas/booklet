module ApplicationHelper
  include Pagy::Frontend

  def support_email
    Rails.configuration.support_email
  end

  def marketing_url
    scheme = Rails.env.production? ? "https" : "http"
    port = Rails.env.production? ? nil : ":3000"
    "#{scheme}://#{Rails.configuration.marketing_host}#{port}"
  end

  def relative_time_tag(datetime)
    content_tag(:time, "", datetime: datetime.iso8601, data: { controller: "time" })
  end

  # Fix issue where `action-text-attachment` fields were getting hijacked by HEY.com
  def inline_action_text_attachments(html_content)
    doc = Nokogiri::HTML.fragment(html_content)

    doc.css("action-text-attachment").each do |node|
      figure_node = Nokogiri::XML::Node.new "figure", doc
      figure_node["class"] = node["class"]

      figure_node.inner_html = node.inner_html
      node.replace figure_node
    end
    doc.to_html
  end
end
