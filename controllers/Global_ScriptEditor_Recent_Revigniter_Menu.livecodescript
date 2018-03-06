script "Global_ScriptEditor_Recent_Revigniter_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Recent_Revigniter_Menu
type: controller
version: 0.4


--> Menu | Props
-
local LocalArray

on menu_Init
   put LocalArray ["serverArray"] into serverArray
   if serverArray is not an array then
      put server_FetchPrefArray() into serverArray
      put serverArray into LocalArray ["serverArray"]
      put keys (serverArray) into LocalArray ["serverURLs"]
      
      server_LoadDetails "rest.livecode.world"
   end if
end menu_Init

getprop menu_Target [mTitlePath]
   put scriptEditor_Object() into scriptObject
   return scriptObject
end menu_Target

command _SetControllerProps scriptObject, @shortControllerFile, @serverTLD, @depLibs, @localRigScript
   put the dep_StackNames of scriptObject into depStackNames
   --
   if depStackNames is empty then
      answer "Controller does not contain a dep_StackNames property!)" with "OK" or "Cancel" as sheet
      if it is "Cancel" then
         put "getprop dep_StackNames" into someFunction
         put CR & "    return 'lib_Fedwiki'" after someFunction
         put CR & "end dep_StackNames" after someFunction
         replace "'" with quote in someFunction
         put someFunction
         exit to top
      end if
   end if
   --
   put stack_ConvertNamesToShortPaths (depStackNames, badNames) into depShortPaths
   --
   put the short_ControllerFile of scriptObject into shortControllerFile
   if shortControllerFile is empty then
      put lcw_Ask ("What filename do you want to give this controller?", "some_controller.lc") into shortControllerFile
   end if
   --
   put the server_TLD of scriptObject into serverTLD
   if shortControllerFile is empty then
      put lcw_Ask ("What TLD do you want to give this controller?", "rest.livecode.world") into serverTLD
   end if
   --
   put the script_Help of scriptObject into scriptDescription
   --
   put rig_ConstructControllerScript (scriptObject, shortControllerFile, depShortPaths, scriptDescription) into localRigScript
   return localRigScript
end _SetControllerProps


--> Global | ScriptEditor | Recent | Revigniter | Menu
-
on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

on _
end _

on menu_UploadController scriptObject
   _SetControllerProps scriptObject, shortControllerFile, serverTLD, depLibs, rigScript
   --
   rig_StoreController shortControllerFile, rigScript
   put the result into shellResult
   if shellResult contains "Permission denied" then
      put shellResult
      lcw_Answer "Permission denied!"
   else
      lcw_Notify "Uploaded controller!"
   end if
end menu_UploadController

on menu_UploadStackLibrary scriptObject
   put the stack_Name of scriptObject into stackName
   lcw_Answer "Do you want to save this stack library to rest.livecode.world?"
   
   rig_StoreStack stackName
   put the result into shellResult
   
   -- scp: /var/www/html/system/application/rest.livecode.world/stacks/lib_MediaWiki.livecode: Permission denied
   if shellResult contains "Permission denied" then
      answer warning "Permission denied!"
      put shellResult
   else
      lcw_Notify "Uploaded stack library!"
   end if
end menu_UploadStackLibrary

on _
end _

on menu_DroppedUrls
   go to stack "Transporter Drop Urls"   
end menu_DroppedUrls

on menu_DisplayRigControllers
   display_RigControllerArray
end menu_DisplayRigControllers

on menu_DisplayRigLibs
   display_RigLibs
end menu_DisplayRigLibs

on menu_CreateNewController
   rig_CreateNewController
end menu_CreateNewController

on _
end _

on menu_RevigniterHelp
   launch url "https://revigniter.com/userGuide/toc.html"
end menu_RevigniterHelp

on menu_DisplayControllerArray scriptObject
   display_StackDeps scriptObject -- lib_DisplayStack
end menu_DisplayControllerArray

on menu_DisplayScriptArray scriptObject
   display_ScriptArray scriptObject
end menu_DisplayScriptArray

on _
end _

on menu_TemporaryBehavior scriptObject, someBoolean
   if someBoolean is true then
      set the behavior of stack "Temp Revigniter Controllers" to the long id of stack "behavior_RigLocalOveride"
   else
      set the behavior of stack "Temp Revigniter Controllers" to empty
   end if
end menu_TemporaryBehavior

on _
end _

on menu_LaunchGist scriptObject
   _SetControllerProps scriptObject, shortControllerFile, serverTLD, depLibs, localRigScript
   rig_LaunchGist shortControllerFile
   put the result into gistURL
   if gistURL is empty then
      answer warning "There is not gist yet for this file!" as sheet
   end if
end menu_LaunchGist

on menu_SaveControllerAsGist scriptObject, remoteOrLocal
   -- put the stack_Name of scriptObject into shortControllerFile
   put the short name of scriptObject into shortControllerFile
   --
   _SetControllerProps scriptObject, shortControllerFile, serverTLD, depLibs, localRigScript
   put rig_FetchController (shortControllerFile) into remoteRigScript
   put merge ("This is Revigniter controller '[[shortControllerFile]]' from the domain '[[serverTLD]]'.") into mergeHelp
   --
   switch remoteOrLocal
      case "local"
         if localRigScript is not remoteRigScript then
            answer "Do you want to save the local rigScript to RevIgniter?" with "Yes" or "No" as sheet
            if it is "Yes" then
               rig_StoreController shortControllerFile, localRigScript
            end if
         end if
         put localRigScript into rigScript
         break
      case "remote"
         put remoteRigScript into rigScript
         break
   end switch
   --
   rig_SaveControllerAsGist rigScript, shortControllerFile, serverTLD, mergeHelp
   put the result into shortGistFile
   gist_Launch shortGistFile
end menu_SaveControllerAsGist

on _
end _

on submenu_Rig
   return "Global | Rig | Files | Menu"
end submenu_Rig

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Recent | Revigniter | Menu | Props
-
getprop temporary_Behavior [scriptObject] 
   put the behavior of scriptObject into bObject
   put bObject is not empty into someBoolean
   return someBoolean
end temporary_Behavior

getprop remote_OrLocals
   return "local,remote"
end remote_OrLocals

getprop server_URL
   return server_GetURL()
end server_URL

getprop server_URLs
   return LocalArray ["serverURLs"]
end server_URLs


--> Global | ScriptEditor | Recent | Revigniter | Menu | Disabled
-
getprop disabled_UploadController [scriptObject]
   put the short_ControllerFile of scriptObject into shortControllerFile
   if shortControllerFile is empty then
      return "delete"
   else
      return false
   end if
end disabled_UploadController
   
getprop disabled_UploadStackLibrary [scriptObject]
   put the script_Metadata ["type"] of scriptObject into scriptType
   if scriptType contains "library" then
      return false
   else
      return "delete"
   end if
end disabled_UploadStackLibrary


--> Dev | Menu
-
on menu_RevealSvg scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   finder_Reveal overlayFolder
end menu_RevealSvg

on menu_DisplaySvgView
   put "View|ScriptEditor|SVG" into viewName
   display_View viewName
end menu_DisplaySvgView

on menu_OldGraphController scriptObject
   breakpoint
   display_IndexScriptAndDisplaySVG scriptObject
   put the result into rigHkeyArray
end menu_OldGraphController

on _
end _

on menu_EditStackScript scriptObject
   put the stack_Object of scriptObject into stackObject
   edit the script of stackObject
end menu_EditStackScript

on menu_EditStackBehavior scriptObject
   put the stack_Object of scriptObject into stackObject
   put the behavior of stackObject into bObject
   edit the script of bObject   
end menu_EditStackBehavior

on _
end _

on menu_SwitchServer stackObject, serverURL
   server_LoadDetails serverURL
   lcw_Notify server_GetIPaddress()
   display_RigControllerArray
end menu_SwitchServer

on menu_ForceLoadServerArray
   put server_FetchPrefArray() into serverArray
   put serverArray into LocalArray ["serverArray"]
   put keys (serverArray) into LocalArray ["serverURLs"]
   
   server_LoadDetails "rest.livecode.world"
end menu_ForceLoadServerArray

-- on submenu_Coder
return "Global | HAP | Coder | Menu"
end submenu_Coder
