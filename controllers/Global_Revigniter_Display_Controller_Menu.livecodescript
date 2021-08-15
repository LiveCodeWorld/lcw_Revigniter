script "Global | Revigniter | Display | Controller | Menu"
--> MetaData
-
license: GPLv3
name: Global | Revigniter | Display | Controller | Menu
type: controller
version: 0.2


--> Menu | Props
-

--> Global | Revigniter | Display | Controller | Menu
-
on menu_DisplayDroppedUrls
   display_TransportDropper
end menu_DisplayDroppedUrls

on menu_DisplayTransportLibs
   display_TransporterLibs
end menu_DisplayTransportLibs

on menu_RevigniterHelp
   launch url "https://revigniter.com/userGuide/toc.html"
end menu_RevigniterHelp

on _
end _

on menu_CreateNewController
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
      lcw_Answer "Created and stored new controller on the server!", displayView
      display_Transporters
      put the result into displayView
      return displayView
   else
      beep
      lcw_ExitAndWarn "Failed to store new controller on the server :("
   end if
end menu_CreateNewController

on _
end _

on menu_TransportGitStatus
   -- put the git_Folder of sObject into gitCheckoutFolder
   put env_GetFolder ("lcw_Controllers") into gitFolder
   --
   display_GitFolderStatus gitFolder
end menu_TransportGitStatus

on menu_RevealLocalProjects
   put env_GetRepoFolder() into repoFolder
   --
   finder_Reveal repoFolder
end menu_RevealLocalProjects

on _
end _

on menu_Refresh displayView
   display_Transporters displayView
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev



--> Dev | Menu
-
on _ProcessAllControllers displayView
   put the displayed_Index of displayView into shortControllers
   repeat for each line shortController in shortControllers
      display_Spin shortController, displayView
      --
      rig_DownloadScriptAndCreateStack shortController
      put the result into scriptStackFile
      --
      put the name of stack scriptStackFile into stackObject
      transport_Upload stackObject
      put the result into shellResult
   end repeat
end _ProcessAllControllers

on _TestTerminal
   terminal_PasteScript "ls -la"
   put the result
end _TestTerminal

on _NewTerminalTab
   terminal_PasteInNewTab "ls -la"
   put the result
end _NewTerminalTab

on _
end _

on _TestCertificates
   put "./tmp/certbot-auto certificates" into sCommand
   ssh_DoRemoteShell "root", "rest.livecode.world", sCommand
   put the result
end _TestCertificates

on _UpdateLetsEncrypt
   put "./tmp/certbot-auto certificates" into remoteShell
   --
   put ssh_ConstructRemoteShell (remoteShell, "rest.livecode.world", "root")
end _UpdateLetsEncrypt

on _
end _

on _EditTransportOverride
   edit the script of stack "behavior_RigLocalOveride"
end _EditTransportOverride
