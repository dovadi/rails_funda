# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_helper
     f_names = [:notice, :success, :error]
     fl = ""
     for name in f_names
      if flash[name]
        fl = fl + "<div class=\"#{name.to_s}\">#{flash[name]}</div>"
        end
        flash[name] = nil;
     end
     if fl.length > 0
       fl = "<div id='flash_messages'>" + fl + "</div>";
     end
     return fl
 end
 
 def streamlined_top_menus
   [
    ["View site", home_path],
    ["Manage Users", {:controller=>"admin/user"}]
   ]
 end
 
 def streamlined_side_menus
   [
    ["Manage Users", {:controller=>"admin/user"}]
   ]
 end
 
 def streamlined_branding
    "<h2>#{CONFIG[:site_title]}</h2>"
 end
 
 def streamlined_footer
    "#{ link_to "<b>Rails funda</b>", "http://github.com/dovadi/rails_funda" }"
 end
end
