module FeelingsHelper
  def feeling_list project=nil
    "#{l(:label_niko_cale_feeling_list)} (#{(project ? h(project.name) : l(:label_niko_cale_all_users))})"
  end
end
