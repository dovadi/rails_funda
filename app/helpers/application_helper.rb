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
end
