script "Global_ScriptEditor_List_Revigniter_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_List_Revigniter_Menu
type: controller
version: 0.4


--> Variables
-
local LocalArray


--> Menu | Props
-


--> Global | ScriptEditor | List | Revigniter | Menu
-
on insert_Remote
   return "Global | revIgniter | Remote | Menu"
end insert_Remote

on _
end _

on submenu_Graph
   return "Global | Hkey | Walk | Menu"
end submenu_Graph

on submenu_Handler
   return "Global | Handler | Menu"
end submenu_Handler

on submenu_HandlerInfo
   return "Global | Handler | Library | Menu"
end submenu_HandlerInfo

on submenu_HandlerFiles
   return "Global | Handler | Calls | Menu"
end submenu_HandlerFiles

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu | Props
-
getprop setMenu_Param
   return ide_ShortTitle ("List")
end setMenu_Param

getprop setMenu_Params
   put ide_ListShortMenuTitles ("List") into shortNames
   return shortNames
end setMenu_Params


--> Dev | Menu
-
on menu_SetMenu hKey, mTitle
   ide_SetMenuTitle "List", mTitle
end menu_SetMenu
