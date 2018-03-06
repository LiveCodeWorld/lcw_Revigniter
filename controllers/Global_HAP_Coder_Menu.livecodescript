script "Global_HAP_Coder_Menu"
--> MetaData
-
license: GPLv3
name: Global_HAP_Coder_Menu
type: controller
version: 0.2


--> Menu | Props
-
/*
on menu_Init  
   local shortStackArray, filteredStackNameArray, filteredShortStackArray
   
   put library_ListScriptLibNames() into scriptOnlyLibNames
   sort scriptOnlyLibNames
   put scriptOnlyLibNames into LocalArray ["scriptOnlyLibNames"]
   
   put view_ListStackFiles() into serverStackFiles
   put serverStackFiles into LocalArray ["server_StackFiles"]
   
   put view_ListControllerFiles() into LocalArray ["server_ControllerFiles"]
   
   put server_GetURL() into projectName
   stackFile_DeconstructShortFileIndex serverStackFiles, shortStackArray, filteredStackNameArray, filteredShortStackArray
   put keys (filteredStackNameArray) into projectLibraryNames
   sort projectLibraryNames
   put projectLibraryNames into LocalArray ["projectLibraryNames"]
   put shortStackArray into LocalArray ["shortStackArray"]
   put filteredStackNameArray into LocalArray ["filteredStackNameArray"]
   put filteredShortStackArray into LocalArray ["filteredShortStackArray"]
   
   put stack_ListEditedNames() into editedStackNames
   put editedStackNames into LocalArray ["editedStackNames"]
   
   put stack_ListEditedScriptOnlyLibraryNames (projectLibraryNames, scriptOnlyLibNames, editedStackNames) into editedScriptOnlyLibraryNames
   put editedScriptOnlyLibraryNames into LocalArray ["editedScriptOnlyLibraryNames"]
end menu_Init

getprop menu_Target
   put menu_GetTargetObject() into mTarget
   put the script_Container of mTarget into scriptContainer
   return scriptContainer
end menu_Target

-- getprop menu_Controller
return the long id of me
end menu_Controller
*/


--> Global | HAP | Coder | Menu
-
on menu_SaveNavigationSettings mTarget
   breakPoint
   put the displayed_NavigationSettings of mTarget into navigationSettingsArray
   set the hap_NavigationSettings of mTarget to navigationSettingsArray
end menu_SaveNavigationSettings

on menu_DisplayProcessedHkeyArray scriptObject
   put the textStack_HkeyArray of scriptObject into processedHkeyArray  
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


--> Global | HAP | Coder | Menu | Props
-

--> Global | HAP | Coder | Menu | Disabled
-
getprop disabled_StartWiki
   put the openprocesses contains "wiki" into isRunning
   return isRunning
end disabled_StartWiki

getprop disabled_StopWiki
   put the openprocesses contains "wiki" into isRunning
   return isRunning is false
end disabled_StopWiki


