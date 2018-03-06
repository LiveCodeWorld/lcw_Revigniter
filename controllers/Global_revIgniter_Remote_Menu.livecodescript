script "Global_RevIgniter_Remote_Menu"
--> MetaData
-
license: GPLv3
name: Global_revIgniter_Remote_Menu
type: controller
version: 0.3


--> Global | RevIgniter | Remote | Menu
-
on menu_TestLocalTransporter hKey
   -- set the behavior of stack "Temp Revigniter Controllers" to the long id of stack "behavior_RigLocalOveride"
   --
   put rev_GetHandlerTreeSelectedInfo() into hInfo
   put word 1 of hInfo into hType
   put word 2 of hInfo into controllerHandler
   put scriptEditor_Object() into stackObject
   --
   -- put fedwiki_GetDroppedUrl() into droppedURL
   -- put the fedwiki_DroppedURL of cardObject into droppedURL
   
   dispatch controllerHandler to stackObject
   --
   -- set the behavior of stack "Temp Revigniter Controllers" to empty
end menu_TestLocalTransporter

on menu_TestRemoteTransport hKey
   put item 1 of hKey into controllerHandler
   put item 3 of hKey into stackObject
   put the short name of stackObject into controllerName
   put the fedwiki_DroppedURL of stackObject into droppedURL
   --
   put rig_ConstructControllerUrl (controllerName, controllerHandler) into restURL
   put $_POST_RAW into postJSON
   
   fedwiki_PostJSON postJSON, restURL
   put the result into pageJSON
   
   put json_ToArray (pageJSON) into pageArray
   if pageArray is an array then
      display_Array pageArray
   else
      -- an error (not json)
      put pageJSON
   end if
end menu_TestRemoteTransport

on _
end _

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

on menu_DisplayTransporterTests
   go to stack "Transporter Drop Urls"
end menu_DisplayTransporterTests

on menu_GraphTransportHandler hKey
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
   put the behavior of hObject into oBehavior
   set the behavior of hObject to empty
   display_IndexScriptAndDisplaySVG hObject, "LCW"
   set the behavior of hObject to oBehavior
end menu_GraphTransportHandler

on menu_GraphTransportStack hKey
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
   put the behavior of hObject into oBehavior
   set the behavior of hObject to empty
   display_IndexScriptAndDisplaySVG hObject, "LCW"
   set the behavior of hObject to oBehavior
end menu_GraphTransportStack

on _
end _

-- on submenu_UploadScriptOnlyLibrary
-- need to change the target to stackObject
return "Global | Rig | Files | Menu"
end submenu_UploadScriptOnlyLibrary


--> LiveWorld
-
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

command liveworld_SaveHTML someHTML
   -- but here we override it
   put the tempname & ".html" into someFile
   put ("file:" & someFile) into someUrl
   put someHTML into url someUrl
   launch url someUrl
   return someUrl
end liveworld_SaveHTML

function liveworld_FetchTemplate pTemplateName
   -- but here we override it
   put url "https://www.livecode.world/index_template.html" into someTemplate
   return someTemplate
end liveworld_FetchTemplate
