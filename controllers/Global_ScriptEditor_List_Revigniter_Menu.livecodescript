script "Global | ScriptEditor | List | Revigniter | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | List | Revigniter | Menu
type: controller
version: 0.4


--> Menu | Init
-
local LocalArray


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

on submenu_HandlerFiles
   return "Global | Handler | Calls | Menu"
end submenu_HandlerFiles

on menu_MenuHelp
   launch_MenuHelp
end menu_MenuHelp
