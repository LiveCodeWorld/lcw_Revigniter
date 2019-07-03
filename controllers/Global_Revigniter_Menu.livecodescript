script "Global_Revigniter_Menu"
--> MetaData
-
license: GPLv3
name: Global_Revigniter_Menu
type: controller
version: 0.2


--> Global | Revigniter | Menu
-
on menu_DroppedUrls
   go to stack "Transporter Drop Urls"   
end menu_DroppedUrls

on menu_DisplayRigControllers
   display_RigControllerArray
end menu_DisplayRigControllers

on _
end _

on submenu_RigFiles
   return "Global | Rig | Files | Menu"
end submenu_RigFiles

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Revigniter | Menu | Props
-

--> Global | Revigniter | Menu | Disabled
-

--> Dev | Menu
-
on menu_Revigniter mTarget, someWhere
   switch someWhere
      case "Documentation"
         put "https://revigniter.com/userGuide/index.html" into someURL
         break
      case "GitHub"
         put "https://github.com/revig/revigniter/" into someURL
         break
      case "Wiki"
         put "http://revigniter.livecode.world/view/welcome-visitors/view/revigniter/view/controllers" into someURL
         break
      case "Search"
         put "https://www.google.co.uk/search?q=revIgniter&oq=revIgniter&aqs=chrome..69i57j69i60j69i61l3j69i65.6584j0j7&sourceid=chrome&ie=UTF-8#q=revIgniter+Livecode" into someURL
         break
      default
         launch url someURL
   end switch
end menu_Revigniter

on _
end _

on menu_LoadServer
   server_LoadDetails "rest.livecode.world"
   display_RigControllerArray
end menu_LoadServer

on menu_SetMenu mTarget, mTitle
   -- ide_SetMenuTitle "Recent", mTitle
   ide_SetScriptEditorTitles mTitle
end menu_SetMenu


--> Dev | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("Recent")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end m_Titles

