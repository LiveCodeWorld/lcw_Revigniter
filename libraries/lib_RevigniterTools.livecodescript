script "lib_RevigniterTools"
--> MetaData
-
license: GPLv3
name: lib_RevigniterTools
type: library
version: 0.3


--> Rig | rigScript
-
getprop rig_ControllerHandlers   
   put the script of the target into someScript
   put the revAvailableHandlers of the target into handlerTable -- revAvailableHandlers only return first handler
   put rig_ExtractControllerHandlers (handlerTable, someScript) into controllerHandlers
   return controllerHandlers
end rig_ControllerHandlers

getprop rig_ControllerHandlerArray
   put the script of the target into someScript
   put the revAvailableHandlers of the target into handlerTable -- revAvailableHandlers only return first handler
   
   put rig_ExtractControllerHandlers (hTable, someScript) into controllerHandlers
   put rig_FilterControllerScript (someScript, hTable) into controllerScript
   
   return controllerHandlers
end rig_ControllerHandlerArray

getprop rig_Script [pShortControllerFile]
   /*
   Here we want to be able to get the revIgniter script of any object. 
   Specificall of script-only stacks that are libraries or proxies for Livecode server (.lc) scripts.
   
   Typically you will want to do something like:
   
   put the script_Container of the target into scriptContainer
   put the displayed_ShortControllerFile of me into pShortControllerFile
   put the rig_Script [pShortControllerFile] of scriptContainer into rigScript
   
   pShortControllerFile is important as it is used to generate the name for the initialisation handler.
   If you do not pass a value the script will take the short name of the stack as a guess,
   this default behavior works well for scrip-only stack versions of controllers.
   
   These stack based versions of controller scripts use the following convention for a controller named "test_controller.lc":
   
   - a script-only stack is created named the same as the controller ("test_controller.lc")
   - the script of ths stack is set to the handlers of the controller,
   along with any comments, but with the "<lc... ?lc> tags removed using the 
   
   */
   
   put the long id of the target into scriptObject
   put rig_ConstructControllerScript (scriptObject, pShortControllerFile) into rigScript
   return rigScript
end rig_Script


--> Display
-
command display_ControllerHandlers controllerScript, pControllerShortFile, serverTLD
   -- script is missing ?
   breakpoint
end display_ControllerHandlers


--> Rig | Create
-
command rig_DownloadScriptAndCreateStack shortController, pControllerFolder
   -- assumes the controller is in "/var/www/html/system/application/rest.livecode.world/controllers/"
   -- put server_GetURL() into pServerURL
   put "rest.livecode.world" into pServerURL
   rig_SetLocalControllerFolder pControllerFolder
   
   -- save the controller.lc version locally
   put rig_FetchController (shortController, pServerURL) into rigScript
   put pControllerFolder & shortController into controllerFile
   put rigScript into url ("binfile:" & controllerFile)
   
   -- save the Livecode script version locally to a script only stack shortController.livecodescript
   put rig_CreateContainerScript (rigScript, shortController) into controllerScript
   rig_CreateLocalControllerStack controllerScript, shortController, pControllerFolder
   put the result into scriptStackFile
   --
   put the long id of stack scriptStackFile into stackObject
   set the short_ControllerFile of stackObject to shortController
   set the server_TLD of stackObject to pServerURL -- is this right?
   --
   return scriptStackFile
end rig_DownloadScriptAndCreateStack

command rig_CreateLocalControllerStack controllerScript, shortController, pControllerFolder
   rig_SetLocalControllerFolder pControllerFolder
   set the itemdelimiter to slash
   put item 1 to -2 of pControllerFolder & "/stacks/" into stackFolder
   set the itemdelimiter to "."
   put stackFolder & shortController into scriptStackFile
   put "livecodescript" into item -1 of scriptStackFile
   
   if exists (stack scriptStackFile) then
      set the script of stack scriptStackFile to controllerScript
   else
      create script only stack shortController
      set the script of stack shortController to controllerScript
      set the filename of stack shortController to scriptStackFile
      save stack shortController
   end if
   --
   if exists (stack "behavior_RigLocalOveride") then
      set the behavior of stack scriptStackFile to the long id of stack "behavior_RigLocalOveride"
   else
      breakpoint
   end if
   return scriptStackFile
end rig_CreateLocalControllerStack

command rig_CreateNewController pControllerShortFile, pControllerFolder
   breakpoint
   
   if pControllerShortFile is empty then
      put lcw_Ask ("Choose a short file for your new controller.", "short.lc") into pControllerShortFile
   end if
   
   put rig_ListControllerFiles() into existingControllers
   if pControllerShortFile is among the lines of existingControllers then
      answer warning "Controller already exists!"
      display_RigController pControllerShortFile
      return false
   end if
   
   local controllerScript, controllerHandlers, scriptDescription, dependencyLibs
   
   -- put script_ConstructCommand ("index", "--", false) into controllerScript
   put scaffold_GetTemplate ("Rig Controller Handlers") into controllerScriptTemplate
   put server_GetURL() into serverTLD
   
   -- display
   display_ControllerHandlers controllerScriptTemplate, pControllerShortFile, serverTLD
   put the result into displayView
   
   put rig_ConstructControllerFromScript (controllerScriptTemplate, pControllerShortFile, controllerHandlers, scriptDescription, dependencyLibs) into rigScript
   -- script_CreateAndEditHashCard controllerScript, "Temp Revigniter Controllers"
   
   put rig_CreateContainerScript (rigScript, pControllerShortFile) into controllerScript
   rig_CreateLocalControllerStack controllerScript, pControllerShortFile, pControllerFolder
   put the result into scriptStackFile
   --
   rig_StoreController pControllerShortFile, rigScript
   return displayView
end rig_CreateNewController


--> Rig | Controller | Folder
-
command rig_SetLocalControllerFolder @controllerFolder
   if controllerFolder is empty then
      put rig_FetchLocalControllerFolder() into controllerFolder
      if there is not a folder controllerFolder then
         put controllerFolder
         put empty into controllerFolder
         answer warning "Cannot locate controller folder. Please set one!"
         exit to top
      end if
   end if
end rig_SetLocalControllerFolder

function rig_FetchLocalControllerFolder
   put pref_FetchValue ("rigControllerFolder") into rigControllerFolder
   return rigControllerFolder
end rig_FetchLocalControllerFolder

command rig_StoreControllerFolder rigControllerFolder
   pref_SaveValue "rigControllerFolder", rigControllerFolder
   put the result into  dataArray
   return dataArray
end rig_StoreControllerFolder

function rig_FetchStackFolder
   -- should mege with rig_LocalControllerFolder()
   put pref_FetchValue ("rigStackFolder") into rigStackFolder
   return rigStackFolder
end rig_FetchStackFolder

command rig_StoreStackFolder rigStackFolder
   pref_SaveValue "rigStackFolder", rigStackFolder
   put the result into  dataArray
   return dataArray
end rig_StoreStackFolder


--> Rig | Controller | Script
-
function rig_CreateContainerScript rigScript, pControllerShortFile
   put word 1 to -1 of rigScript into rigScript
   
   _StripInitCommand rigScript, pControllerShortFile
   put the result into getpropHandler
   _StripHeaderFromRigScript rigScript
   
   repeat with lineNum = 1 to the number of lines of rigScript
      if char 1 to 3 of line lineNum of rigScript = "   " then
         delete char 1 to 3 of line lineNum of rigScript
      end if
   end repeat
   
   if getpropHandler is not empty then
      put getpropHandler & CR & CR before rigScript
   end if
   
   put word 1 to -1 of rigScript into rigScript
   if line -1 of rigScript = "?>" then
      delete line -1 of rigScript
      put word 1 to -1 of rigScript into rigScript
   end if
   
   return rigScript
end rig_CreateContainerScript

function rig_ConstructControllerScript scriptObject, shortControllerFile, pDepShortPaths, pScriptDescription
   if pScriptDescription is empty then
      put the script_Markdown of scriptObject into pScriptDescription
   end if
   if pDepShortPaths is empty then
      -- put the dep_ControllerLibs of scriptObject into pDepShortPaths
      put the dep_StackNames of scriptObject into stackNames
      put stack_ConvertNamesToShortPaths (stackNames, badNames) into pDepShortPaths
   end if
   
   put the script of scriptObject into someScript
   put the revAvailableHandlers of scriptObject into hTable
   put rig_ExtractControllerHandlers (hTable, someScript) into controllerHandlers
   
   put rig_FilterControllerScript (someScript, hTable) into controllerScript
   text_Indent controllerScript
   text_Indent pScriptDescription
   put rig_ConstructControllerFromScript (controllerScript, shortControllerFile, controllerHandlers, pScriptDescription, pDepShortPaths) into rigScript
   return rigScript
end rig_ConstructControllerScript

function rig_ConstructControllerFromScript controllerScript, shortControllerFile, controllerHandlerList, scriptDescription, pShortDepLibFiles
   -- controllerScript must has getprop and setprop handers stripped out
   replace CR with comma in controllerHandlerList
   put scaffold_GetTemplate ("revIgniter Controller Template") into scriptTemplate
   put scaffold_GetTemplate ("revIgniter Dependency Section")  into dependencyTemplate
   
   set the itemdelimiter to "."
   put item 1 of shortControllerFile into shortControllerName
   -- not sure if we need to expose this
   if shortControllerName is not among the items of controllerHandlerList then
      if controllerHandlerList is empty then
         put shortControllerName into controllerHandlerList
      else
         put comma & shortControllerName after controllerHandlerList
      end if
   end if
   
   put shortControllerFile into pathToController
   put rig_ConstructDepScriptLines (pShortDepLibFiles, "   ") into initScriptLines -- was rig_ConstructInitScriptLines
   text_Indent initScriptLines, "      "
   --
   put rig_FilterControllerScript (controllerScript, hTable) into publicHandlers
   put rig_ExtractDependencies (controllerScript) into handlerDependencies
   put merge (scriptTemplate) into rigScript
   --
   if handlerDependencies is not empty then
      put merge (dependencyTemplate) into dependencySection
      text_Indent dependencySection, "   "
      put CR & CR after rigScript
      put dependencySection after rigScript
   end if
   
   put "<?lc" & CR before rigScript
   put CR & CR & "?>" after rigScript
   return rigScript
end rig_ConstructControllerFromScript

function rig_ExtractControllerHandlers handlerTable, someScript
   put script_HkeysFromAvailable (handlerTable, someScript, "name") into controllerHandlers
   replace "mouseUp" with "index" in controllerHandlers
   replace CR with comma in controllerHandlers
   return controllerHandlers
end rig_ExtractControllerHandlers

function rig_FilterControllerScript someScript, hTable
   -- rename "mouseUp" though we don't bother any more as we can use script edito menus to test
   put word 1 to -1 of someScript into controllerScript
   replace "on mouseUp" with "on index" in controllerScript
   replace "end mouseUp" with "end index" in controllerScript
   
   -- remove getprop and setprops (well the one we use for now)
   script_DeleteHandler controllerScript, "G dep_StackNames", hTable
   
   return controllerScript
end rig_FilterControllerScript

function rig_ExtractDependencies buttonScript
   return empty
end rig_ExtractDependencies


--> Revigniter | Controllers | Create
-
function rig_ConstructInitScriptLines stackObjects
   replace CR with comma in stackObjects
   repeat for each item stackObject in stackObjects
      -- get the short file of the library stack
      set the itemdelimiter to slash
      get the filename of stackObject
      put item -1 of it into shortLibraryFile
      set the itemdelimiter to comma
      
      -- start using stack (gAPPPATH & "stacks/lib_Audioboom.livecode")
      put "stacks/" & shortLibraryFile into relPath
      put "start using stack (gAPPPATH &" && kwote (relPath) & ")" into scriptLine
      
      put CR & scriptLine after scriptLines
   end repeat
   delete char 1 of scriptLines
   return scriptLines
end rig_ConstructInitScriptLines

function rig_ConstructDepScriptLines shortLibPaths
   replace CR with comma in shortLibPaths
   repeat for each item shortLibPath in shortLibPaths
      -- start using stack (gAPPPATH & "stacks/lib_Audioboom.livecode")
      put "stacks/" & shortLibPath into relPath
      put "start using stack (gAPPPATH &" && kwote (relPath) & ")" into scriptLine
      put CR & scriptLine after scriptLines
   end repeat
   delete char 1 of scriptLines
   return scriptLines
end rig_ConstructDepScriptLines


--> Deps
-
private command _StripHeaderFromRigScript @rigScript
   put the number of lines of rigScript into maxNum
   repeat maxNum
      put word 1 to 2 of line 1 of rigScript into firstTwoWords
      if firstTwoWords is among the items of "private command,private function" then
         exit repeat
      end if
      
      put word 1 of line 1 of rigScript into firstWord
      if firstWord is among the items of "command,on,function,getprop,setprop" then
         exit repeat
      end if
      
      delete line 1 of rigScript
   end repeat
end _StripHeaderFromRigScript
   
private command _StripInitCommand @rigScript, pControllerShortFile
   if pControllerShortFile is empty then return empty
   
   set the itemdelimiter to "."
   put item 1 of pControllerShortFile into cName
   --
   script_SetHandlerOffsets startHandler, endHandler, cName, "command", rigScript
   --
   if endHandler = 0 then return empty
   
   put the result into initHandler
   delete char startHandler to endHandler of rigScript
   --
   put the number of lines of initHandler into maxLine
   repeat with lineNum = 2 to (maxLine -1)
      get line lineNum of initHandler
      --  start using stack (gAPPPATH & "stacks/lib_HTML.livecode")
      put token -2 of it into pathBit
      --
      set the itemdelimiter to slash
      put item -1 of pathBit into shortControllerFile
      
      -- bit of a hack
      set the itemdelimiter to "."
      put item 1 of shortControllerFile into stackName
      if there is a stack stackName then
         put the filename of stack stackName into stackPath
         set the itemdelimiter to slash
         put item -1 of stackPath into testShortFile
         if testShortFile = shortControllerFile then
            put stackName & comma after shortControllerFiles
         else
            -- can't find stack
            put shortControllerFile & comma after shortControllerFiles
         end if
      else
         -- can't find stack
         put shortControllerFile & comma after shortControllerFiles
      end if
   end repeat
   delete char -1 of shortControllerFiles
   
   put "getprop dep_StackNames" into getProphandler
   put CR & "    return" && kwote (shortControllerFiles) after getProphandler
   put CR & "end dep_StackNames" after getProphandler
   --
   return getProphandler
end _StripInitCommand

private command text_Indent @someText, pIndentChars
   if pIndentChars is empty then put "   " into pIndentChars
   repeat for each line someLine in someText
      put pIndentChars & someLine & CR after newText
   end repeat
   delete char -1 of newText
   put newText into someText
end text_Indent
