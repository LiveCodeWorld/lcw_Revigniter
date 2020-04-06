script "Global_RevIgniter_Remote_Menu"
--> MetaData
-
license: GPLv3
name: Global_revIgniter_Remote_Menu
type: controller
version: 0.4

/*
This menu is used by the scripteditor handler list field when in rig mode.
*/

--> Menu | Init
-
local LocalArray

on menu_Init tObject, hKey
   put hKey into LocalArray ["hKey"]
   --
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   rig_SetOveride true, hObject
end menu_Init

command _SetHkeyInfo @controllerHandler, @localRigStackObject, @controllerName
   put scriptEditor_Object() into localRigStackObject
   put the short name of localRigStackObject into controllerName
   --
   put rev_GetHandlerTreeSelectedInfo() into hInfo
   put word 1 of hInfo into hType
   put word 2 of hInfo into controllerHandler
end _SetHkeyInfo

getprop disabled_GraphTransporter [hKey]
   put hkey_IsTransportHandler (hKey) into isTransporter
   if isTransporter then
      hkey_Deconstruct hKey, hName, hType, hObject, hNum
      put overlay_GetHkeyHash (hKey) into oHash
      put the mainstack_Hash of hObject into mHash
      if oHash = mHash then
         return true
      else
         return false
      end if
   else
      return "delete"
   end if
end disabled_GraphTransporter



--> Global | RevIgniter | Remote | Menu
-
on insert_HelpMenu
   return "Global | Hkey | Help | Menu"
end insert_HelpMenu

on _
end _

on menu_TestLocalTransporter
   _SetHkeyInfo controllerHandler, localRigStackObject, controllerName
   --
   dispatch controllerHandler to localRigStackObject
end menu_TestLocalTransporter

on menu_TestRemoteTransport
   _SetHkeyInfo controllerHandler, localRigStackObject, controllerName
   --
   put the test_RawJSON of localRigStackObject into rawJSON
   if rawJSON is empty then
      put the mock_DropJson of stack "Transporter Drop Urls" into rawJSON
   end if
   
   put rig_ConstructControllerUrl (controllerName, controllerHandler) into restURL
   fedwiki_PostJSON rawJSON, restURL
   put the result into pageJSON
   put json_ToArray (pageJSON) into pageArray
   
   if pageArray is an array then
      display_Array pageArray
   else
      put pageJSON -- an error (not json)
   end if
end menu_TestRemoteTransport

on _
end _

on submenu_Sketches
   return "Dev | Menu"
end submenu_Sketches


--> Dev | Menu
-
on menu_GraphTransporter
   -- _SetHkeyInfo controllerHandler, stackObject
   put LocalArray ["hKey"] into hKey
   --
   transporter_CreateHkeyGraph hKey
end menu_GraphTransporter

on menu_DisplayDeps
   put LocalArray ["hKey"] into hKey
   display_TransportHkeyDeps hKey
end menu_DisplayDeps

on _
end _

on menu_TransportBehaviorOveride
   edit the script of stack "behavior_RigLocalOveride"
end menu_TransportBehaviorOveride

on menu_TestRemote mTarget, controllerHandler
   put test_Remote (mTarget, controllerHandler)
end menu_TestRemote

on menu_TestRemoteArray mTarget, controllerHandler
   put test_Remote (mTarget, controllerHandler) into tEncodedArray
   put rig_DecodeArray (tEncodedArray) into tResultArray
   display_Array tResultArray, controllerHandler
end menu_TestRemoteArray

on _
end _

on menu_DisplayTestUrls
   go to stack "Transporter Drop Urls"
end menu_DisplayTestUrls

on menu_ListShortStackFiles hKey
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
   put the dep_StackNames of hObject into sNames
   --
   put stack_ConvertNamesToShortPaths (stackNames, badNames) into shortFiles
   --
   put shortFiles & CR & CR & badStackNames
end menu_ListShortStackFiles

on _
end _

on menu_SetDroppedUrl
   put scriptEditor_Object() into cardObject
   put lcw_Ask ("Enter a vlue for the droppedURL...") into droppedURL
   set the fedwiki_DroppedURL of cardObject to droppedURL
end menu_SetDroppedUrl

on _
end _

on menu_CreateHandlerGraph hKey, someBoolean
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   
   put the behavior of hObject into bObject
   set the behavior of hObject to empty
   --
   hkey_CreateAndDisplayDeps hkey, projectName, someBoolean
   --
   set the behavior of hObject to bObject
   
   put hkey_SvgFile (hKey) into svgFile
   finder_Reveal imageFile
end menu_CreateHandlerGraph


--> Deps
-
function test_Remote mTarget, controllerHandler
   put the displayed_ControllerName of mTarget into controllerName
   put rig_ConstructControllerUrl (controllerName, controllerHandler) into restURL
   put url restURL into someResult
   return someResult
end test_Remote

function rig_ConstructControllerUrl controllerName, shortControllerFile
   set the itemdelimiter to "."
   put item 1 of shortControllerFile into restPath
   put "https://" & server_GetURL() & "/" into restURL
   
   set the itemdelimiter to "."
   put item 1 of controllerName after restURL
   
   switch restPath
      case empty
      case "index"
         return restURL
      default
         put "/" &  restPath after restURL
         return restURL
   end switch
end rig_ConstructControllerUrl

function _DiplayView
   put server_GetURL() into serverURL
   put display_FindView ("Stack Libraries", serverURL) into displayView
   return displayView
end _DiplayView

private command hkey_CreateAndDisplayDeps hkey, pProjectName, pClusterBoolean
   set the cursor to watch
   
   hkey_CreateDependencyGraph hkey, pProjectName, "hierarchical", pClusterBoolean
   put the result into imageFile
   
   display_HkeySVG hkey
   put the result into displayView
   return displayView
end hkey_CreateAndDisplayDeps

private command hkey_CreateDependencyGraph hKey, pProjectName, pGraphStyle, pClusterBoolean
   put empty into overlayName -- defaults to pGraphStyle or "hierarchical"
   if pClusterBoolean is not false then 
      put empty into clusterRank
   else
      put "none" into clusterRank
   end if
   
   put hkey_DependencyArrayFromObjects (hKey, pProjectName, true) into hKeyArray
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   
   overlay_CreateGraph hkeyMetadataFolder, hkeyArray, overlayName, hKey, pGraphStyle, clusterRank, empty, "svg"
   -- put the result into overlayArray
   -- put overlayArray_GetImageFile (overlayArray, hkeyMetadataFolder) into imageFile
   
   put hkey_SvgFile (hKey, pGraphStyle) into svgFile
   return svgFile
end hkey_CreateDependencyGraph
