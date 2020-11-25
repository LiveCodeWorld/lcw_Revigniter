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

on menu_DisplayRigStackLibs
   display_TransporterLibs
end menu_DisplayRigStackLibs

on menu_RevigniterHelp
   launch url "https://revigniter.com/userGuide/toc.html"
end menu_RevigniterHelp

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
      lcw_Answer "Created and stored new controller on the server!", displayView
      display_Transporters
      put the result into displayView
   else
      beep
      lcw_ExitAndWarn "Failed to store new controller on the server :("
   end if
   return displayView
end menu_CreateNewController

on _
end _

on menu_TransportGitStatus
   -- put the git_Folder of sObject into gitCheckoutFolder
   put env_GetFolder ("lcw_Controllers") into gitFolder
   --
   display_GitFolderStatus gitFolder
end menu_TransportGitStatus

on menu_RevealLocalProjects indexView
   put env_GetRepoFolder() into repoFolder
   --
   finder_Reveal repoFolder
end menu_RevealLocalProjects

on _
end _

on menu_Refresh arrayView
   display_Transporters arrayView
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev



--> Dev | Menu
-
on menu_TestTerminal
   terminal_PasteScript "ls -la"
   put the result
end menu_TestTerminal

on menu_NewTerminalTab
   terminal_PasteInNewTab "ls -la"
   put the result
end menu_NewTerminalTab

on _
end _

on menu_TestCertificates
   put "./tmp/certbot-auto certificates" into sCommand
   ssh_DoRemoteShell "root", "rest.livecode.world", sCommand
   put the result
end menu_TestCertificates

on menu_UpdateLetsEncrypt
   put "./tmp/certbot-auto certificates" into remoteShell
   --
   put ssh_ConstructRemoteShell (remoteShell, "rest.livecode.world", "root")
end menu_UpdateLetsEncrypt

on _
end _

on menu_EditTransportOverride
   edit the script of stack "behavior_RigLocalOveride"
end menu_EditTransportOverride
