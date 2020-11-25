script "Global | HAP | Coder | Menu"
--> MetaData
-
license: GPLv3
name: Global | HAP | Coder | Menu
type: controller
version: 0.2


--> Menu | Props
-
getprop disabled_StartWiki
   put the openprocesses contains "wiki" into isRunning
   return isRunning
end disabled_StartWiki

getprop disabled_StopWiki
   put the openprocesses contains "wiki" into isRunning
   return isRunning is false
end disabled_StopWiki


--> Global | HAP | Coder | Menu
-
on menu_SaveNavigationSettings mTarget
   breakPoint
   put the displayed_NavigationSettings of mTarget into navigationSettingsArray
   set the hap_NavigationSettings of mTarget to navigationSettingsArray
end menu_SaveNavigationSettings

on menu_DisplayProcessedHkeyArray scriptObject
   put the projectOverlay_Array ["processedHkey.array"] of scriptObject into processedHkeyArray  
   display_Array processedHkeyArray, "processedHkeyArray"
end menu_DisplayProcessedHkeyArray

on menu_DisplayDependencyObjectArray scriptObject
   put the textstack_HkeyObjectArray of scriptObject into depObjectArray
   display_Array depObjectArray
end menu_DisplayDependencyObjectArray

on menu_ScriptLibraryDependencies scriptObject
   -- put the missing_HkeyArray of scriptObject into missingHkeyArray
   put the script_DepLibs of scriptObject -- into dependencyStacks
end menu_ScriptLibraryDependencies
