﻿script "Global | Rig | Files | Menu"
--> MetaData
-
license: GPLv3
name: Global | Rig | Files | Menu
target: stackObject
type: controller
version: 0.2


--> Menu | Init
-
getprop menu_Target [tObject]
   put the title_Text of tObject into stackName
   if exists (stack stackName) then
      put the name of stack stackName into stackObject
      return stackObject
   else
      return empty
   end if
end menu_Target

getprop menu_Target [stackObject]
   if word 1 of stackObject = "stack" and exists (stackObject) then
      return true
   else
      return false
   end if
end menu_Target

getprop switchServer_Param
   return server_GetURL()
end switchServer_Param

getprop switchServer_Params
   put server_FetchPrefArray() into serverArray
   return keys (serverArray)
end switchServer_Params

getprop fetchRigScript_Params
   put rig_ListControllerFiles() into shortControllerFiles
   return shortControllerFiles
end fetchRigScript_Params

-- getprop disabled_RevealLocalControllerFolder
put rig_FetchLocalControllerFolder() into someFolder
if there is a folder someFolder then
   return false
else
   return true
end if
end disabled_RevealLocalControllerFolder

getprop disabled_CheckRemoteStack [stackObject]
   put the short name of stackObject into shortControllerFile
   set the itemdelimiter to "."
   if item -1 of shortControllerFile = "lc" then
      -- let's assume it is a rig controller script and not a stack
      return true
   else
      return false
   end if
end disabled_CheckRemoteStack

getprop disabled_UploadLocalStack
   return LocalArray ["stackExists"] is false
end disabled_UploadLocalStack

getprop disabled_CheckRemoteStack
   return LocalArray ["stackExists"] is false
end disabled_CheckRemoteStack


--> Global | Rig | Files | Menu
-
on menu_SwitchServer stackObject, serverURL
   server_SetURL serverURL
   lcw_Notify server_GetIPaddress()
end menu_SwitchServer

on menu_FetchRigScript stackObject, rigController 
   rig_DownloadScriptAndCreateStack rigController
   put the result into scriptStackFile
   edit the script of stack scriptStackFile
end menu_FetchRigScript

on _
end _

on menu_DisplayRigScript scriptObject
   rig_SetOveride true, scriptObject
   --
   put the short_ControllerFile of scriptObject into shortController
   -- put the server_TLD of cardObject into serverTLD
   --
   put rig_ConstructControllerScript (scriptObject, shortController) into rigScript
   --   
   if the shiftKey is "Down" then
      display_Text rigScript, shortController, "Global | Rig | Files | Menu"
      rig_SetOveride false, scriptObject
   else
      atom_DisplayText rigScript, "lc", true
   end if
end menu_DisplayRigScript

on menu_UploadRigScript scriptObject
   put the short_ControllerFile of scriptObject into shortController
   --
   put rig_ConstructControllerScript (scriptObject, shortController) into rigScript
   
   rig_StoreController shortController, rigScript
   put the result into shellResult
   if shellResult is empty then
      put rigScript
      answer "Uploaded controller to server!"
   else
      put shellResult
      answer warning "Problem uploading controller to the server!"
   end if
end menu_UploadRigScript

on _
end _

on menu_UpoadControllerAndStacks scriptObject
   breakpoint
   put LocalArray ["editedScriptOnlyLibraryNames"] into editedScriptOnlyLibraryNames
   put LocalArray ["server_StackFiles"] into serverStackFiles
   
   server_UploadStacks editedScriptOnlyLibraryNames
end menu_UpoadControllerAndStacks

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditLocalBehavior scriptObject
   put the behavior of scriptObject into bObject
   edit the script of stack "behavior_RigLocalOveride"
end menu_EditLocalBehavior

on menu_CheckRigScript scriptObject
   breakpoint
   set the cursor to watch
   --
   put the short_ControllerFile of scriptObject into shortController
   -- put the server_TLD of cardObject into serverTLD
   --
   put rig_FetchController (shortControllerFile) into remoteRigScript
   put url ("file:" & stackPath) into localRigScript
   --
   put remoteRigScript = localRigScript into areTheSame
   if areTheSame is true then
      answer "The scripts are the same!"
   else
      answer "The script on the server and the local script differ!"
   end if
end menu_CheckRigScript

on menu_SetLocalControllerFolder
   rig_AskSetLocalControllerFolder
end menu_SetLocalControllerFolder

on menu_RevealLocalControllerFolder
   put rig_FetchLocalControllerFolder() into someFolder
   finder_Reveal someFolder
end menu_RevealLocalControllerFolder

on _
end _

on menu_UploadLocalStack stackObject
   put the short name of stackObject into stackName
   
   set the cursor to watch
   rig_StoreStack stackName
   if the result is not empty then
      put the result
   else
      answer "Re-uploaded local stack to the server"
   end if
end menu_UploadLocalStack

on menu_CheckRemoteStack stackObject
   set the cursor to watch
   
   put _getRemoteStackData (stackObject) into serverStackData
   put the filename of stackObject into localStackFile
   put url ("file:" & localStackFile) into localStackData
   
   put localStackData = serverStackData into stacksAreTheSame
   if stacksAreTheSame is true then
      answer "The stacks are the same!"
   else
      -- display_Lines localStackData, "Local stack"
      -- display_Lines serverStackData, "Remote server stack"
      answer "The stack on the server and the local stack differ!"
   end if
end menu_CheckRemoteStack

on _
end _

on menu_FetchServerStack serverStackFile
   breakpoint
   put the hap_StackFolder of me into hapStackFolder
   set the itemdelimiter to "."
   put rig_FetchStack (serverStackFile) into scriptOnlyStack
   put hapStackFolder & serverStackFile into newStackFilePath
   put word 1 of scriptOnlyStack = "Ôªøscript" into isScriptOnly
   if isScriptOnly is true then
      put scriptOnlyStack into url ("file:" & newStackFilePath)
   else
      put scriptOnlyStack into url ("binfile:" & newStackFilePath)
   end if
   set the stack_IsKnow of stack newStackFilePath to true
end menu_FetchServerStack

on menu_DeleteServerStack serverStackFile
   breakpoint
   put merge ("Are you sure you want to delete the stack '[[serverStackFile]]' from the server?") into someWarning
   answer warning someWarning with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   set the cursor to watch
   rig_DeleteStack serverStackFile
   refresh
end menu_DeleteServerStack


--> Deps
-
command rig_AskSetLocalControllerFolder
   put rig_FetchLocalControllerFolder() into rigControllerFolder
   answer folder "Select the folder to store all your controllers..." with rigControllerFolder
   put it into rigControllerFolder
   if it is empty then exit to top
   text_AddTrailing rigControllerFolder, slash
   
   rig_StoreControllerFolder rigControllerFolder
   return rigControllerFolder
end rig_AskSetLocalControllerFolder

private function _getRemoteStackData stackObject
   if exists (stackObject) is false then return empty
   -- put the short name of stackObject into shortControllerFile
   put the filename of stackObject into stackPath
   set the itemdelimiter to slash
   put item -1 of stackPath into shortControllerFile
   put rig_FetchStack (shortControllerFile) into serverStackData
   if char 1 to 3 of serverStackData = "Ôªø" then
      delete char 1 to 3 of serverStackData
   end if
   return serverStackData
end _getRemoteStackData
