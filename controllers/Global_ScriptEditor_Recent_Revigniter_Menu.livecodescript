script "Global_ScriptEditor_Recent_Revigniter_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Recent_Revigniter_Menu
type: controller
version: 0.4


--> Menu | Props
-
local LocalArray

on menu_Init
   put LocalArray ["serverArray"] into serverArray
   if serverArray is not an array then
      put server_FetchPrefArray() into serverArray
      put serverArray into LocalArray ["serverArray"]
      put keys (serverArray) into LocalArray ["serverURLs"]
      
      server_SetURL "rest.livecode.world"
   end if
end menu_Init

getprop menu_Target [mTitlePath]
   put scriptEditor_Object() into scriptObject
   return scriptObject
end menu_Target

getprop disabled_UploadController [scriptObject]
   -- put the short_ControllerFile of scriptObject into shortControllerFile
   put the project_Name of scriptObject into projectName
   if projectName = "lcw_Controllers" then
      put the stack_Name of scriptObject into shortControllerFile
      if shortControllerFile ends with ".lc" then
         return false
      else
         return true
      end if
   else
      return "delete"
   end if
end disabled_UploadController

getprop disabled_UploadStackLibrary [scriptObject]
   put the script_Metadata ["type"] of scriptObject into scriptType
   switch
      case scriptType contains "library"
         return false
      case scriptType = "model"
         return false
      default
         return "delete"
   end switch
end disabled_UploadStackLibrary


--> Global | ScriptEditor | Recent | Revigniter | Menu
-
on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

on submenu_ScriptDeps
   return "Global | Script | Dep | Menu"
end submenu_ScriptDeps

on _
end _

on menu_CheckTransporterDeps sObject
   transport_CheckObjectDeps sObject
end menu_CheckTransporterDeps

on menu_TestTransporterGraphs sObject
   put revRuggedID (sObject) into sObject
   
   local foundHkeys, stillMissing
   put transport_ListMissingHkeys (sObject) into missingHkeys
   hkey_SetFound missingHkeys, foundHkeys, stillMissing
   put hkey_ListObjects (foundHkeys) into extraObjects
   --
   transport_CollectCalls sObject, callObjectArray, missingArray, revIgniterArray
   put the result into depStacks
   --
   line_Add extraObjects, depStacks
   
   put stack_ConvertToNames (depStacks) into shortNames
   replace CR with comma in shortNames
   sort items of shortNames
   put the dep_StackNames of sObject into depStackNames
   sort items of depStackNames
   --
   if shortNames is not depStackNames then
      put rig_ConstructGetProp (shortNames) into newGetPropHandler
      local pTreeMenuTitle, pLineMenuTitle
      display_Text newGetPropHandler, "Getprop", pTreeMenuTitle, pLineMenuTitle
   end if
   
   if stillMissing is not empty then
      display_Lines stillMissing, "Still Missing"
   end if
   if callObjectArray is not empty then
      display_Array callObjectArray, "callObjectArray"
   else
      breakpoint
      put rev_TopScriptEditor() into sEditor
      lcw_Answer ("Tested tranporter" && sObject), sEditor
   end if
end menu_TestTransporterGraphs

on menu_CreateTransporterGraphs scriptObject
   transporter_CreateGraph scriptObject, true, true
end menu_CreateTransporterGraphs

on _
end _

on menu_UploadController scriptObject
   put the stack_Name of scriptObject into shortControllerFile
   --
   put the dep_StackNames of scriptObject into depStackNames
   put stack_ConvertNamesToShortPaths (depStackNames, badNames) into depShortPaths
   --
   put the script_Help of scriptObject into scriptDescription
   --
   put rig_ConstructControllerScript (scriptObject, shortControllerFile, depShortPaths, scriptDescription) into rigScript
   rig_StoreController shortControllerFile, rigScript
   --
   put the result into shellResult
   if shellResult contains "Permission denied" then
      put shellResult
      dispatch "lcw_AnswerSheet" to stackObject with "Permission denied!"
   else
      lcw_Notify "Uploaded controller!"
   end if
end menu_UploadController

on menu_UploadStackLibrary scriptObject
   put the stack_Name of scriptObject into stackName
   put merge ("Do you want to save the stack library '[[stackName]]' to rest.livecode.world?") into someQuestion
   put rev_TopScriptEditor() into stackObject
   dispatch "lcw_AnswerSheet" to stackObject with someQuestion
   
   rig_StoreStack stackName
   put the result into shellResult
   
   -- scp: /var/www/html/system/application/rest.livecode.world/stacks/lib_MediaWiki.livecode: Permission denied
   if shellResult contains "Permission denied" then
      answer warning "Permission denied!"
      put shellResult
   else
      lcw_Notify "Uploaded stack library!"
   end if
end menu_UploadStackLibrary

on _
end _

on menu_DroppedUrls
   go to stack "Transporter Drop Urls"   
end menu_DroppedUrls

on menu_DisplayRigControllers
   display_RigControllers
end menu_DisplayRigControllers

on menu_DisplayRigStackLibs
   display_RigStackLibs
end menu_DisplayRigStackLibs

on _
end _

on menu_RevigniterHelp
   launch url "https://revigniter.com/userGuide/toc.html"
end menu_RevigniterHelp

on _
end _

on menu_DisplayGitStatus scriptObject
   display_GitStatus scriptObject
end menu_DisplayGitStatus

on _
end _

on submenu_Ide
   return "Global | IDE | Menu"
end submenu_Ide

on submenu_Rig
   return "Global | Rig | Files | Menu"
end submenu_Rig

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Recent | Revigniter | Menu | Props
-
getprop temporary_Behavior [scriptObject] 
   put the behavior of scriptObject into bObject
   put bObject is not empty into someBoolean
   return someBoolean
end temporary_Behavior

getprop remote_OrLocals
   return "local,remote"
end remote_OrLocals

getprop server_URL
   return server_GetURL()
end server_URL

getprop server_URLs
   return LocalArray ["serverURLs"]
end server_URLs


--> Dev | Menu
-
on menu_EditTemporaryBehavior scriptObject
   edit the script of stack "behavior_RigLocalOveride"
end menu_EditTemporaryBehavior

on menu_SetTemporaryBehavior scriptObject, someBoolean
   rig_SetOveride someBoolean, scriptObject
end menu_SetTemporaryBehavior

on _
end _

on menu_DisplayObjectGraph scriptObject
   local pGraphStyle, pProcessObject, projectName
   --
   display_ObjectGraph scriptObject, projectName, pGraphStyle, pProcessObject, false
   --
   display_ObjectDepArray scriptObject
end menu_DisplayObjectGraph

on menu_RevealSvg scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   finder_Reveal overlayFolder
end menu_RevealSvg

on menu_DisplaySvgView
   put "View|ScriptEditor|SVG" into viewName
   display_View viewName
end menu_DisplaySvgView

on _
end _

on menu_EditStackScript scriptObject
   put the stack_Object of scriptObject into stackObject
   edit the script of stackObject
end menu_EditStackScript

on menu_EditStackBehavior scriptObject
   put the stack_Object of scriptObject into stackObject
   put the behavior of stackObject into bObject
   edit the script of bObject   
end menu_EditStackBehavior

on _
end _

on menu_SwitchServer stackObject, serverURL
   server_SetURL serverURL
   lcw_Notify server_GetIPaddress()
   display_RigControllerArray
end menu_SwitchServer

on menu_ForceLoadServerArray
   put server_FetchPrefArray() into serverArray
   put serverArray into LocalArray ["serverArray"]
   put keys (serverArray) into LocalArray ["serverURLs"]
   
   server_SetURL "rest.livecode.world"
end menu_ForceLoadServerArray
