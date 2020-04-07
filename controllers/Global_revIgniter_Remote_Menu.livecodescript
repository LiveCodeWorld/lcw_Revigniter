script "Global_RevIgniter_Remote_Menu"
--> MetaData
-
license: GPLv3
name: Global_revIgniter_Remote_Menu
type: controller
target: hKey
version: 0.4

/*
This menu is used by the scripteditor handler list field when in rig mode.
*/

--> Working on
-
command _SetHkeyInfo @hName, @rigStackObject, @shortController
   -- simplify and use scriptEditor_GetHkey() (mTarget)
   put scriptEditor_GetHkeyLine() into hKeyLine
   hkeyLine_Deconstruct hKeyLine, hName, hType, rigStackObject
   --
   put scriptEditor_Object() into rigStackObject
   put the short name of rigStackObject into shortController
   --
   put hKeyLine_Construct(hName, hType, rigStackObject) into hkey
   return hkey
end _SetHkeyInfo


--> Menu | Init
-
local LocalArray

on menu_Init tObject
   put scriptEditor_GetHkey() into hKey
   put hKey into LocalArray ["hKey"]
   --
   rig_SetOveride true
end menu_Init

getprop menu_Target [tObject]
   return LocalArray ["hKey"]
end menu_Target

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
on submenu_HelpMenu
   return "Global | Hkey | Help | Menu"
end submenu_HelpMenu

on _
end _

on menu_TestLocalTransporter
   _SetHkeyInfo hName, rigStackObject, shortController
   --
   dispatch hName to rigStackObject
end menu_TestLocalTransporter

on menu_TestRemoteTransport
   _SetHkeyInfo hName, rigStackObject, shortController
   --
   put the test_RawJSON of rigStackObject into rawJSON
   if rawJSON is empty then
      put the mock_DropJson of stack "Transporter Drop Urls" into rawJSON
   end if
   
   put rig_ConstructControllerUrl (shortController, hName) into restURL
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
on menu_GraphTransporter hKey
   transporter_CreateHkeyGraph hKey
end menu_GraphTransporter

on menu_DisplayDeps hKey
   display_TransportHkeyDeps hKey
end menu_DisplayDeps

on menu_CreateHandlerGraph hKey
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

on _
end _

on menu_RigLocalOverideBehavior
   edit the script of stack "behavior_RigLocalOveride"
end menu_RigLocalOverideBehavior


--> Deps
-
function rig_ConstructControllerUrl shortController, shortControllerFile
   set the itemdelimiter to "."
   put item 1 of shortControllerFile into restPath
   put "https://" & server_GetURL() & "/" into restURL
   
   set the itemdelimiter to "."
   put item 1 of shortController after restURL
   
   switch restPath
      case empty
      case "index"
         return restURL
      default
         put "/" &  restPath after restURL
         return restURL
   end switch
end rig_ConstructControllerUrl

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
