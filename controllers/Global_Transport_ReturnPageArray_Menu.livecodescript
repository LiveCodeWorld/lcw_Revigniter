script "Global | Transport | ReturnPageArray | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Transport | ReturnPageArray | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-


--> Global | Transport | ReturnPageArray | Menu
-
on menu_EditJson displayView
   put the displayed_Array of displayView into pageArray
   --
   put json_FromArray (pageArray) into someJSON
   --
   atom_DisplayText someJSON, "json"
end menu_EditJson

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment mTarget
   put mTarget
end menu_Experiment


--> Deps
-
