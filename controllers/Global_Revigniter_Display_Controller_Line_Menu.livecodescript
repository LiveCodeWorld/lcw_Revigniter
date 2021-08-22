script "Global | Revigniter | Display | Controller | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Revigniter | Display | Controller | Line | Menu
type: controller
version: 0.2

/*
This menu is for the array based display of revIgniter controllers.
*/

--> Menu | Props
-
private command _Refresh displayView
   put the view_Name of displayView into viewName
   switch viewName
      case "View|Tree|Widget with Title"
         put rig_FetchControllerPathArray() into controllerPathArray
         set the displayed_Data of displayView to controllerPathArray
         break
      default
         display_Transporters displayView
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


--> Global | Revigniter | Display | Controller | Line | Menu
-
on menu_TransportHelp displayView
   put _ControllerFile (displayView) into shortFile
   put the name of stack shortFile into sObject
   --
   launch_ObjectHelp sObject
   if the result is empty then
      put the name of sObject into oName
      lcw_Answer "Do you want to create the transport help page for [[sObject]]? This will overwrite any existing page.", displayView, sObject
      
      ask_PushGithub sObject
      help_CreateFromObject sObject
      launch_ObjectHelp sObject
   end if
end menu_TransportHelp

on menu_DownloadController displayView
   put _ControllerFile (displayView) into shortFile
   --
   rig_EditController shortFile
end menu_DownloadController

on menu_EditLocalControllerStack displayView
   put _ControllerFile (displayView) into shortFile
   --
   put rig_LocalControllerStackPath (shortFile) into stackPath
   if exists (stack stackPath) then
      edit the script of stack stackPath
   else
      put stackPath
      put "Cannot locate stack [[shortFile]]!" into someQuestion
      lcw_AnswerWarning someQuestion, displayView, "shortFile", shortFile
   end if
end menu_EditLocalControllerStack

on menu_EditLocalControllerScript displayView
   put _ControllerFile (displayView) into shortFile
   --
   put rig_LocalControllerScriptPath (shortFile) into scriptPath
   --
   finder_Reveal scriptPath
   atom_Edit scriptPath
end menu_EditLocalControllerScript

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

on menu_LaunchGithub displayView
   put _ControllerFile (displayView) into shortFile
   github_LaunchTransport shortFile
end menu_LaunchGithub

on menu_LaunchGist displayView
   put _ControllerFile (displayView) into shortFile
   gist_Launch shortFile
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

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _Refresh displayView
   _Refresh displayView
end _Refresh

on _SeetDefaultIdeMenu
   ide_SetMenuTitle "Recent", "Default"
end _SeetDefaultIdeMenu
