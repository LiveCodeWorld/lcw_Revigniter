script "Global | Handler | Dev | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Handler | Dev | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

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


--> Global | Handler | Dev | Menu
-
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

on submenu_Handler
   return "Global | Handler | Menu"
end submenu_Handler

on submenu_HandlerInfo
   return "Global | Handler | Library | Menu"
end submenu_HandlerInfo

on _DisplayDeps hKey
   display_TransportHkeyDeps hKey
end _DisplayDeps

on _GraphTransporter hKey
   transporter_CreateHkeyGraph hKey
end _GraphTransporter

on _CreateHandlerGraph hKey
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
end _CreateHandlerGraph

on _HandlerListFieldBehavior
   edit the script of stack "behavior_IdeHandlerListField"
end _HandlerListFieldBehavior

on _RigLocalOverideBehavior
   edit the script of stack "behavior_RigLocalOveride"
end _RigLocalOverideBehavior
