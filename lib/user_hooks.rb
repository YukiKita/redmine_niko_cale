class UserHooks < Redmine::Hook::ViewListener
  include FeelingsHelper
  def view_account_left_bottom(context = {})
    user = context[:user]
    feeling = Feeling.latest(user)
    if feeling
      image = feeling.good? ? face_image('good') : (feeling.bad? ? face_image('bad') : face_image('ordinary'))
      header_and_image = <<EOS
<h3>#{l(:label_niko_cale_feeling)}(#{feeling.at})</h3>
<ul>#{link_to(image, :controller => "feelings", :action => "show", :id => feeling)}</ul>
EOS

      if feeling.has_description?
        header_and_image + <<EOS
<div class="wiki">
#{textilizable(feeling.description)}
</div>
EOS
      else
        header_and_image
      end
    end
  end
end
