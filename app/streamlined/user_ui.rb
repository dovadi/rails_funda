module UserAdditions
  
end
User.class_eval { include UserAdditions }

Streamlined.ui_for(User) do
  user_columns :login,
               :email, 
               :name,  
               :roles, {:show_view => [:list, {:fields=>[:name]}]},
               :state, {:update_only => true, :enumeration => User.states}
               
  edit_columns :login, 
               :email, 
               :name,
               :roles,{ :quick_add => true},
               :state, {:enumeration => User.states}
               # :password, {:field_type=>'password'},
               #              :password_confirmation, {:field_type=>'password'}
                
end   
