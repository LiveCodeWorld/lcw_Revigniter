script "Global | Transporter | Tree | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Transporter | Tree | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Events
-
on drop_DoTransport displayView, someURL
   put the displayed_Array of displayView into dArray
   --
   transport_AddDroppedUrl dArray, someUrl
   --
   set the displayed_Array of displayView to dArray
end drop_DoTransport

on mDouble_DoTransport displayView, someURL, somePath
   if the optionKey is "down" then hkey_Edit
   --
   put display_GetSelectedTransport() into shortFile
   --
   if the shiftKey is "Down" or exists (stack shortFile) is false then
      -- lcw_Answer "Cannot locate local tranporter, launch URL instead?"
      launch url someURL
   else
      put the name of stack shortFile into tController
      put transport_GetSelectedHandler() into hName
      --
      dispatch hName to tController
   end if
end mDouble_DoTransport


--> Menu | Init
-
getprop selectTransporter_Param
   return display_GetSelectedTransport()
end selectTransporter_Param

getprop selectTransporter_Params
   put scriptEditor_ListTabNames() into shortFiles
   filter shortFiles with "*.lc"
   return shortFiles
end selectTransporter_Params

getprop disabled_SelectHandler [displayView]
   put display_GetSelectedTransport() into shortFile
   if shortFile is empty then
      return true
   else
      return false
   end if
end disabled_SelectHandler

getprop selectHandler_Param
   put transport_GetSelectedHandler() into hName
   return hName
end selectHandler_Param

getprop selectHandler_Params
   put transport_ListHandlers() into hNames
   return hNames
end selectHandler_Params


--> Global | Transporter | Tree | Menu
-
on menu_SelectTransporter displayView, shortFile
   transport_SetSelected shortFile, displayView
end menu_SelectTransporter

on menu_SelectHandler displayView, hName
   transport_SetSelectedHandler hName
end menu_SelectHandler

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_OldStack
   go to stack "Transporter Drop Urls"
end menu_OldStack

on menu_SystemWindow displayView, someBoolean
   put the stack_Name of displayView into stackName
   set the systemwindow of stack stackName to someBoolean
end menu_SystemWindow

getprop systemWindow_Param [displayView]
   put the stack_Name of displayView into stackName
   put the systemwindow of stack stackName into someBoolean
   return someBoolean
end systemWindow_Param

getprop systemWindow_Params
   return "true,false"
end systemWindow_Params

on menu_EditTransportOverride
   edit the script of stack "behavior_RigLocalOveride"
end menu_EditTransportOverride

on menu_MenuController
   put menu_GetGlobalController ("Global | Transporter | Tree | Menu") into mController
   edit the script of mController
end menu_MenuController


--> Deps
-
