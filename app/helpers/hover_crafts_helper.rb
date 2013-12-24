module HoverCraftsHelper

  def status_indicator(hover_craft)
    return 'panel-success' if hover_craft.crafted?
    return 'panel-info' if hover_craft.craft_fit_score >= HoverCraft::FIT_absolute
    'panel-warning'
  end
end
