class UserHooks < Redmine::Hook::ViewListener
  include FeelingsHelper
  def view_account_left_bottom(context = {})
    user = context[:user]
    feeling = Feeling.latest(user)
    if feeling
      image = face_image(feeling.level)
      header_and_image = <<~EOS
  <h3>#{l(:label_niko_cale_feeling)}(#{feeling.at})</h3>
  <ul>#{link_to(image, :controller => "feelings", :action => "show", :id => feeling)}</ul>
EOS

      if feeling.has_description?
        description = <<EOS
<div class="wiki">
#{textilizable(feeling.description)}
</div>
EOS
        header_and_image += description
      end
      header_and_image.html_safe
    end
  end
end
