script "Global | RevIgniter | Remote | Menu"
--> MetaData
-
license: GPLv3
name: Global | RevIgniter | Remote | Menu
target: hKey
type: controller
version: 0.4

/*This menu is used by the scripteditor handler list field when in rig mode.*/


--> Working on
-
command _SetHkeyInfo @hName, @rigStackObject, @shortController
   -- simplify and use scriptEditor_GetHkey() (mTarget)
   put scriptEditor_GetHkeyLine() into hKeyLine
   hkeyLine_Deconstruct hKeyLine, hName, hType, rigStackObject
   put scriptEditor_Object() into rigStackObject
   --
   put the short name of rigStackObject into shortController
   put hKeyLine_Construct (hName, hType, rigStackObject) into hkey
   return hkey
end _SetHkeyInfo


--> Menu | Init
-
local LocalArray

command _Init tObject
   put scriptEditor_GetHkey() into hKey
   put hKey into LocalArray ["hKey"]
   --
   rig_SetOveride true
end _Init

getprop menu_Target [tObject]
   _Init tObject
   return LocalArray ["hKey"]
end menu_Target


--> Global | RevIgniter | Remote | Menu
-
on submenu_HelpMenu
   return "Global | Hkey | Help | Menu"
end submenu_HelpMenu

on menu_TestLocalTransporter
   _SetHkeyInfo hName, rigStackObject, shortController
   --
   dispatch hName to rigStackObject
end menu_TestLocalTransporter

on menu_TestRemoteTransport
   _SetHkeyInfo hName, rigStackObject, shortController
   --
   put the transporter_RawJSON of rigStackObject into rawJSON
   if rawJSON is empty then
      put transport_GetMockRawJson() into rawJSON
   end if
   
   put rig_ConstructControllerUrl (shortController, hName) into restURL
   fedwiki_PostJSON rawJSON, restURL
   put the result into pageJSON
   --
   if pageJSON is empty then
      display_DebugHistory "menu_TestRemoteTransport"
      lcw_AnswerWarning "No json returned!"
   end if
   
   -- got some JSON
   put json_ToArray (pageJSON) into pageArray
   if pageArray is an array then
      display_Array pageArray
   else
      put pageJSON -- an error (not json)
   end if
end menu_TestRemoteTransport

on _
end _

on submenu_Dev
   return "Global | Handler | Dev | Menu"
end submenu_Dev
