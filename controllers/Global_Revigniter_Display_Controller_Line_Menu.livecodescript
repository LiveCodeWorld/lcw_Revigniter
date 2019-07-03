script "Global_Revigniter_Display_Controller_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Revigniter_Display_Controller_Line_Menu
type: controller
version: 0.2

local LocalArray

/*
This menu is for the array based display of revIgniter controllers.
*/

--> Global | Revigniter | Display | Controller | Line | Menu
-
on menu_DownloadController displayView
   put _ControllerFile (displayView) into shortFile
   --
   rig_EditController shortFile
end menu_DownloadController

on _
end _

on menu_LaunchGist arrayView
   put item 1 of the selected_Path of arrayView into shortGistFile
   gist_Launch shortGistFile
end menu_LaunchGist

on menu_SaveControllerAsGist displayView
   put _ControllerFile (displayView) into shortControllerFile
   --
   put the title_Text of displayView into serverTLD
   put merge ("This the is Revigniter controller '[[shortControllerFile]]' from the domain '[[serverTLD]]'.") into mergeHelp
   
   put rig_FetchController (shortControllerFile) into rigScript
   rig_SaveControllerAsGist rigScript, shortControllerFile, serverTLD, mergeHelp
   put the result into shortGistFile
   
   gist_Launch shortGistFile
end menu_SaveControllerAsGist

on _
end _

on menu_DeleteController displayView
   put _ControllerFile (displayView) into shortControllerFile
   put the title_Text of displayView into serverTLD
   --
   put merge ("Are you sure you want to delete the server file [[shortControllerFile]]?") into someComment
   lcw_Answer someComment
   --
   rig_DeleteController shortControllerFile, serverTLD
   --
   _Refresh displayView
end menu_DeleteController

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Revigniter | Display | Controller | Line | Menu | Props
-

--> Global | Revigniter | Display | Controller | Line | Menu | Disabled
-

--> Dev | Menu
-
on menu_Refresh displayView
   _Refresh displayView
end menu_Refresh

on menu_ChangeMenu
   ide_SetMenuTitle "Recent", "Default"
end menu_ChangeMenu


--> Deps
-
private command _Refresh displayView
   put the view_Name of displayView into viewName
   switch viewName
      case "View|Tree|Widget with Title"
         put rig_FetchControllerPathArray() into controllerPathArray
         set the displayed_Data of displayView to controllerPathArray
         break
      default
         display_RigControllers displayView
   end switch
end _Refresh

private function _ControllerFile displayView
   put the view_Name of displayView into viewName
   switch viewName
      case "View|Tree|Widget with Title"
         put item 1 of the selected_Path of displayView into shortControllerFile
         break
      default -- "View|Index|Simple"
         put the selected_Line of displayView into shortControllerFile
   end switch
   return shortControllerFile
end _ControllerFile


