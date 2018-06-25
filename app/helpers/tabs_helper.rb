module TabsHelper
  
  def active_nav_class(name, action = nil, id = nil)
    # binding.pry
    if action.present?
      return if controller.action_name != action
    end

    if id.present?
      return if params[:id] != id
    end
     
    return 'active' if controller.controller_name =~ /#{name}/i 
     if name == "groups"
        # puts "ctl-name", controller.action_name
       if controller.action_name == "edit_groups"
         return 'active'
       end 
     end
    if name == "all-czars"
     
       if controller.action_name == "all_czars"
        return 'active'
       end 
    end 
  end
end

