script "Global_Revigniter_Display_Controller_Menu"
--> MetaData
-
license: GPLv3
name: Global_Revigniter_Display_Controller_Menu
type: controller
version: 0.1


--> Global | Revigniter | Display | Controller | Menu
-
on menu_DisplayRigControllers mTarget
   get the view_Name of mTarget
   if it = "View|Tree|Widget with Title" then
      server_LoadDetails "rest.livecode.world"
      put rig_FetchControllerPathArray() into controllerPathArray
      get the displayed_Array of mTarget
      set the displayed_Data of mTarget to controllerPathArray
   else
      display_RigControllerArray
   end if
end menu_DisplayRigControllers

on menu_CreateNewController
   rig_CreateNewController
end menu_CreateNewController

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Revigniter | Display | Controller | Menu | Props
-

--> Global | Revigniter | Display | Controller | Menu | Disabled
-

--> Dev | Menu
-
-- on menu_EditViewBehavior arrayView
   put the behavior of arrayView into bObject
   edit the script of bObject
end menu_EditViewBehavior
