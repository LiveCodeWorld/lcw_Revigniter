script "Global_Revigniter_Display_Controller_Menu"
--> MetaData
-
license: GPLv3
name: Global_Revigniter_Display_Controller_Menu
type: controller
version: 0.1


--> Global | Revigniter | Display | Controller | Menu
-
on menu_DisplayRigControllers
   display_RigControllers
end menu_DisplayRigControllers

on _
end _

on menu_CreateNewController displayView
   local pControllerShortFile, pControllerFolder
   
   rig_SetLocalControllerFolder pControllerFolder
   if pControllerShortFile is empty then
      put lcw_Ask ("Choose a short file for your new controller.", "short.lc") into pControllerShortFile
   end if
   
   put rig_ListControllerFiles() into existingControllers
   if pControllerShortFile is among the lines of existingControllers then
      answer warning "Controller already exists!"
      display_RigController pControllerShortFile
      return false
   end if
   
   local controllerScript, controllerHandlers, scriptDescription, dependencyLibs
   
   put scaffold_GetTemplate ("Rig Controller Handlers") into controllerScriptTemplate
   put server_GetURL() into serverTLD
   
   put rig_ConstructControllerFromScript (controllerScriptTemplate, pControllerShortFile, controllerHandlers, scriptDescription, dependencyLibs) into rigScript
   
   put rig_CreateContainerScript (rigScript, pControllerShortFile) into controllerScript
   rig_CreateLocalControllerStack controllerScript, pControllerShortFile, pControllerFolder
   put the result into scriptStackFile
   --
   rig_StoreController pControllerShortFile, rigScript
   put the result into shellResult
   
   if shellResult is empty then
      lcw_AnswerSheet "Created and stored new controller on the server!"
      display_RigControllers
      put the result into displayView
   else
      beep
      lcw_ExitAndWarn "Failed to store new controller on the server :("
   end if
   return displayView
end menu_CreateNewController


on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Revigniter | Display | Controller | Menu | Props
-

--> Global | Revigniter | Display | Controller | Menu | Disabled
-

--> Dev | Menu
-
on menu_EditViewBehavior arrayView
   put the behavior of arrayView into bObject
   edit the script of bObject
end menu_EditViewBehavior

on submenu_ControllerFiles
   return "Global | Rig | Files | Menu"
end submenu_ControllerFiles

on submenu_ScriptEditor
   return "Global | ScriptEditor | Recent | Revigniter | Menu"
end submenu_ScriptEditor
