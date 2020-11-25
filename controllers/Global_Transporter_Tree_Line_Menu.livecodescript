script "Global | Transporter | Tree | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Transporter | Tree | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target tObject   
   -- do something when the menu first loads
   return empty
end menu_Target


--> Global | Transporter | Tree | Line | Menu
-
on menu_TestScrape displayView
   put the selected_Line of displayView into someURL
   --
   put listenNotes_PageArrayFromScrape (someURL) into pageArray
   --
   display_PageArray pageArray
end menu_TestScrape

on menu_LaunchUrl displayView
   put the selected_Line of displayView into someURL
   launch url someURL
end menu_LaunchUrl

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
