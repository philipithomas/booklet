require "active_support/concern"

module BrandColorable
  extend ActiveSupport::Concern

  LIGHT_LABEL_COLOR = "#FFFFFF"
  DARK_LABEL_COLOR = "#111111"
  MIN_CONTRAST_RATIO = 2.9
  # booklet brand color is Rails.configuration.booklet_brand_color

  def set_brand_color_from_logo
    return unless brand_color.nil?

    self.brand_color = calculate_brand_color
    save!
  end

  def light_mode_label_color
    return nil unless brand_color
    return LIGHT_LABEL_COLOR if brand_color_has_sufficient_contrast_to_light

    highest_contrast_label_color_for_brand_color
  end

  def dark_mode_label_color
    return nil unless brand_color
    return DARK_LABEL_COLOR if brand_color_has_sufficient_contrast_to_dark

    highest_contrast_label_color_for_brand_color
  end

  def brand_color_has_sufficient_contrast_to_light(ratio = MIN_CONTRAST_RATIO)
    brand_color_contrast(LIGHT_LABEL_COLOR) > ratio
  end

  def brand_color_has_sufficient_contrast_to_dark(ratio = MIN_CONTRAST_RATIO)
    brand_color_contrast(DARK_LABEL_COLOR) > ratio
  end

  private

  def calculate_brand_color
    return nil unless logo.attached?

    hist = Magick::Image.from_blob(logo.download).first.color_histogram
    sorted = hist.keys.sort_by { |p| -hist[p] }
    sorted.first.to_color(Magick::AllCompliance, false, 8, true)
  end

  def highest_contrast_label_color_for_brand_color
    return LIGHT_LABEL_COLOR if brand_color_contrast(LIGHT_LABEL_COLOR) > brand_color_contrast(DARK_LABEL_COLOR)

    DARK_LABEL_COLOR
  end

  def brand_color_contrast(color)
    raise "no brand color" unless brand_color

    WCAGColorContrast.ratio(brand_color.delete("#"), color.delete("#"))
  end
end
