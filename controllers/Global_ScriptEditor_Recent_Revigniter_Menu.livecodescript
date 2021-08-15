script "Global | ScriptEditor | Recent | Revigniter | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Recent | Revigniter | Menu
target: scriptObject
type: controller
version: 0.4


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   _InitServerArray
   --
   put scriptEditor_Object() into sObject
   put the script_Metadata ["type"] of sObject into sType
   --
   put the project_Name of sObject into projectName
   put env_ConstructProjectFolder ("lcw_Controllers") into transportFolder
   put the filename of sObject into sFile
   --
   put sType into LocalArray ["sType"]
   put projectName into LocalArray ["projectName"]
   --
   get transportFolder & "stacks/"
   put sFile begins with it into LocalArray ["isTransport"]
   --
   put LocalArray ["rigShortStackFiles"] into rigShortStackFiles
   set the itemdelimiter to slash
   put item -1 of sFile is among the lines of rigShortStackFiles into LocalArray ["isTransportLib"]
   --
   return sObject
end menu_Target

getprop disabled_LibraryOnGithub
   if LocalArray ["isTransportLib"] is true then
      return false
   else
      return true
   end if
end disabled_LibraryOnGithub

getprop disabled_UploadTransportLibrary [sObject]
   put LocalArray ["sType"] into sType
   switch
      case sType contains "library"
         return false
      case sType = "model"
         return false
      default
         return "delete"
   end switch
end disabled_UploadTransportLibrary

private command _InitServerArray
   put LocalArray ["serverArray"] into serverArray
   if serverArray is not an array then
      put server_FetchPrefArray() into serverArray
      put serverArray into LocalArray ["serverArray"]
      put keys (serverArray) into LocalArray ["serverURLs"]
      server_SetURL "rest.livecode.world"
   end if
   
   if LocalArray ["rigShortStackFiles"] is empty then
      put rig_ListStackFiles() into LocalArray ["rigShortStackFiles"]
      -- put rig_ListControllerFiles() into LocalArray ["rigShortControllerFiles"]
   end if
end _InitServerArray

getprop disabled_ListScriptDeps
   if LocalArray ["isTransport"] is true then
      return "delete"
   else
      return false
   end if
end disabled_ListScriptDeps

getprop disabled_ListTransportDeps
   if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_ListTransportDeps

getprop disabled_UploadTransport
   if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_UploadTransport

getprop disabled_TransportOnGithub
   -- LocalArray ["isTransportLib"]
   if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_TransportOnGithub

getprop disabled_CreateTransporterGraphs
   if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_CreateTransporterGraphs



--> Global | ScriptEditor | Recent | Revigniter | Menu
-
on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

on _
end _

on menu_UploadTransport scriptObject
   transport_Upload scriptObject
   put the result into shellResult
   --
   if shellResult contains "Permission denied" then
      put shellResult
      lcw_Answer "Permission denied!", scriptObject
   else
      lcw_Notify "Uploaded controller!"
   end if
end menu_UploadTransport

on menu_ListTransportDeps sObject
   display_TransportObjectDeps sObject
   put the result into displayView
   --
   put the displayed_Data of displayView into objectArray
   display_TransportGetpropIfNeeded sObject, objectArray
end menu_ListTransportDeps

on menu_CreateTransporterGraphs scriptObject
   transporter_CreateGraph scriptObject, true, true
end menu_CreateTransporterGraphs

on menu_TransportOnGithub sObject
   put the stack_Name of sObject into shortFile
   github_LaunchTransport shortFile
end menu_TransportOnGithub

on _
end _

on menu_UploadTransportLibrary scriptObject
   put the stack_Name of scriptObject into stackName
   put merge ("Do you want to save the stack library '[[stackName]]' to rest.livecode.world?") into someQuestion
   put scriptEditor_GetTop() into stackObject
   lcw_Answer someQuestion, stackObject
   
   rig_StoreStack stackName
   put the result into shellResult
   
   -- scp: /var/www/html/system/application/rest.livecode.world/stacks/lib_MediaWiki.livecode: Permission denied
   if shellResult contains "Permission denied" then
      answer warning "Permission denied!"
      put shellResult
   else
      lcw_Notify "Uploaded stack library!"
   end if
end menu_UploadTransportLibrary

on menu_ScriptTools sObject
   display_Script sObject
end menu_ScriptTools

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _ListScriptDeps sObject
   display_ScriptDeps sObject
end _ListScriptDeps

on _LaunchGithub sObject
   put the stack_Name of sObject into stackName
   github_LaunchStack stackName
end _LaunchGithub

on _DisplayGitStatus sObject
   display_GitStatus sObject
end _DisplayGitStatus

on _DisplayTransportLibs scriptObject
   display_TransporterstackLibs scriptObject
end _DisplayTransportLibs

on _
end _

on _Ide
   return "Global | IDE | Menu"
end _Ide

on _SetIdeBehavior
   return "Global | ScriptEditor | Behavior | Menu"
end _SetIdeBehavior

on _Test scriptObject
   put the handler_PermaMarkdown of scriptObject & CR & CR & the menu_PermalinkMarkdown [true] of scriptObject
end _Test

on _EditTemporaryBehavior scriptObject
   edit the script of stack "behavior_RigLocalOveride"
end _EditTemporaryBehavior

on _SetTemporaryBehavior scriptObject, someBoolean
   rig_SetOveride someBoolean
end _SetTemporaryBehavior

on _
end _

on _DisplayObjectGraph scriptObject
   display_CreateScriptObjectGraph scriptObject
   --
   display_ObjectDepArray scriptObject
end _DisplayObjectGraph

on _RevealSvg scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   finder_Reveal overlayFolder
end _RevealSvg

on _DisplaySvgView
   put "View|ScriptEditor|SVG" into viewName
   display_View viewName
end _DisplaySvgView

on _
end _

on _EditStackScript scriptObject
   put the stack_Object of scriptObject into stackObject
   edit the script of stackObject
end _EditStackScript

on _EditStackBehavior scriptObject
   put the stack_Object of scriptObject into stackObject
   put the behavior of stackObject into bObject
   edit the script of bObject   
end _EditStackBehavior

on _
end _

on _SwitchServer stackObject, serverURL
   server_SetURL serverURL
   lcw_Notify server_GetIPaddress()
   display_RigControllerArray
end _SwitchServer

on _ForceLoadServerArray
   put server_FetchPrefArray() into serverArray
   put serverArray into LocalArray ["serverArray"]
   put keys (serverArray) into LocalArray ["serverURLs"]
   
   server_SetURL "rest.livecode.world"
end _ForceLoadServerArray


--> Dev | Menu | Props
-
getprop setTemporaryBehavior_Param [scriptObject]
   put rig_GetOveride() into someBoolean
   return someBoolean
end setTemporaryBehavior_Param

getprop setTemporaryBehavior_Params
   return "true,false"
end setTemporaryBehavior_Params

getprop switchServer_Param
   return server_GetURL()
end switchServer_Param

getprop switchServer_Params
   return LocalArray ["serverURLs"]
end switchServer_Params
