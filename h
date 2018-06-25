
[1mFrom:[0m /home/ubuntu/workspace/app/helpers/tabs_helper.rb @ line 5 TabsHelper#active_nav_class:

     [1;34m3[0m: [32mdef[0m [1;34mactive_nav_class[0m(name, action = [1;36mnil[0m, id = [1;36mnil[0m)
     [1;34m4[0m:    binding.pry
 =>  [1;34m5[0m:   [32mif[0m action.present?
     [1;34m6[0m:     [32mreturn[0m [32mif[0m controller.action_name != action
     [1;34m7[0m:   [32mend[0m
     [1;34m8[0m: 
     [1;34m9[0m:   [32mif[0m id.present?
    [1;34m10[0m:     [32mreturn[0m [32mif[0m params[[33m:id[0m] != id
    [1;34m11[0m:   [32mend[0m
    [1;34m12[0m: 
    [1;34m13[0m:   [31m[1;31m'[0m[31mactive[1;31m'[0m[31m[0m [32mif[0m controller.controller_name =~ [35m[1;35m/[0m[35m#{name}[0m[35m[1;35m/[0m[35m[35mi[0m[35m[0m
    [1;34m14[0m:   [32mif[0m(name == [31m[1;31m'[0m[31mgroups[1;31m'[0m[31m[0m) && (controller.action_name == [31m[1;31m'[0m[31medit_groups[1;31m'[0m[31m[0m) 
    [1;34m15[0m:     [32mreturn[0m [31m[1;31m'[0m[31mactive[1;31m'[0m[31m[0m 
    [1;34m16[0m:   [32mend[0m
    [1;34m17[0m:   [32mif[0m (name == [31m[1;31m'[0m[31mboard[1;31m'[0m[31m[0m) && (controller.controller_name == [31m[1;31m'[0m[31mboards[1;31m'[0m[31m[0m) 
    [1;34m18[0m:      [32mreturn[0m [31m[1;31m'[0m[31mactive[1;31m'[0m[31m[0m
    [1;34m19[0m:   [32mend[0m
    [1;34m20[0m:   [32mif[0m (name == [31m[1;31m'[0m[31mall-czars[1;31m'[0m[31m[0m) && (controller.controller_name == [31m[1;31m'[0m[31mregions[1;31m'[0m[31m[0m) 
    [1;34m21[0m:      [32mreturn[0m [31m[1;31m'[0m[31mactive[1;31m'[0m[31m[0m
    [1;34m22[0m:   [32mend[0m
    [1;34m23[0m:   
    [1;34m24[0m: [32mend[0m

