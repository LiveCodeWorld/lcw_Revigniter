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
on menu_DownloadController arrayView
   put item 1 of the selected_Path of arrayView into shortControllerFile
   --
   rig_DownloadScriptAndCreateStack shortControllerFile
   put the result into scriptStackFile
   --
   -- put the title_Text of arrayView into serverTLD
   -- set the server_TLD of scriptStackFile to serverTLD
   --
   edit the script of stack scriptStackFile
   --
   ide_SetScriptEditorTitles "Revigniter"
end menu_DownloadController

on _
end _

on menu_LaunchGist arrayView
   put item 1 of the selected_Path of arrayView into shortGistFile
   gist_Launch shortGistFile
end menu_LaunchGist

on menu_SaveControllerAsGist arrayView
   put item 1 of the selected_Path of arrayView into shortControllerFile
   put the title_Text of arrayView into serverTLD
   put merge ("This the is Revigniter controller '[[shortControllerFile]]' from the domain '[[serverTLD]]'.") into mergeHelp
   
   put rig_FetchController (shortControllerFile) into rigScript
   rig_SaveControllerAsGist rigScript, shortControllerFile, serverTLD, mergeHelp
   put the result into shortGistFile
   
   gist_Launch shortGistFile
end menu_SaveControllerAsGist

on _
end _

on menu_DeleteController arrayView
   put item 1 of the selected_Path of arrayView into shortControllerFile
   put merge ("Are you sure you want to delete the server file [[shortControllerFile]]?") into someComment
   lcw_Answer someComment
   --
   put the title_Text of arrayView into serverTLD
   rig_DeleteController shortControllerFile, serverTLD
   --
   put rig_FetchControllerPathArray() into controllerPathArray
   set the displayed_Data of arrayView to controllerPathArray
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
on menu_ChangeMenu
   ide_SetMenuTitle "Recent", "Default"
end menu_ChangeMenu

on menu_EditViewBehavior arrayView
   put the behavior of arrayView into bObject
   edit the script of bObject
end menu_EditViewBehavior

on _
end _

on menu_CreateControllerCard arrayView
   -- this is the old way of creating one card per controller in a temporary stack
   -- new way is to create an independent stack per controller
   breakpoint
   
   put item 1 of the selected_Path of arrayView into shortControllerFile
   put the title_Text of arrayView into serverTLD
   
   put rig_FetchController (shortControllerFile) into rigScript
   put rig_CreateContainerScript (rigScript, shortControllerFile) into someScript
   
   -- script_CreateAndEditHashCard someScript, "Temp Revigniter Controllers"
   -- put the result into cardObject
   script_CreateTempCard shortControllerFile, someScript, "Temp Revigniter Controllers"
   put the result into cardObject
   edit the script of cardObject
   
   set the short_ControllerFile of cardObject to shortControllerFile
   set the server_TLD of cardObject to serverTLD
   
   ide_SetScriptEditorTitles "Revigniter"
end menu_CreateControllerCard

