﻿script "lib_RevigniterTools"
--> MetaData
-
license: GPLv3
name: lib_RevigniterTools
type: library
version: 0.4

/*
Here we provide tools for manipulating RevIgniter scripts so that we can use them locally
for debugging, testing and development purposes. The idea is that code on the server 
is the same as far as possible as code help and run locally.

There is a local Revigniter controller folder that is versioned in GitHub, and can be accessed using:

- function rig_GetLocalControllerFolder()
- command rig_StoreLocalControllerFolder

Thre is no equivalent for RevIgniter stack libraries, as they are stored locally in whatever project makes sence,
rather than a single flat folder as the server does. Having an aditional copy of this folder locally would cause 
problems regarding duplication of files. Instead we access local stack libraries using the stack name.
*/


--> Rig | Create
-
command rig_CreateController controllerShortFile
   local controllerFolder, controllerScript, controllerHandlers, scriptDescription, dependencyLibs
   
   rig_SetLocalControllerFolder controllerFolder
   
   put rig_ListControllerFiles() into existingControllers
   if controllerShortFile is among the lines of existingControllers then
      answer warning "Controller already exists!"
      display_RigController controllerShortFile
      return false
   end if
   
   put scaffold_Get ("Rig Controller Handlers") into controllerScriptTemplate
   put server_GetURL() into serverTLD
   
   put rig_ConstructControllerFromScript (controllerScriptTemplate, controllerShortFile, controllerHandlers, scriptDescription, dependencyLibs) into rigScript
   
   put rig_CreateContainerScript (rigScript, controllerShortFile) into controllerScript
   rig_CreateLocalControllerStack controllerScript, controllerShortFile, controllerFolder
   put the result into scriptStackFile
   --
   rig_StoreController controllerShortFile, rigScript
   put the result into shellResult
   
   if shellResult is empty then
      lcw_Answer "Created and stored new controller on the server!", displayView
      display_Transporters
      put the result into displayView
      return displayView
   else
      beep
      lcw_ExitAndWarn "Failed to store new controller on the server :("
   end if
end rig_CreateController


--> Rig | Files
-
function rig_LocalControllerStackPath shortController
   put rig_GetLocalControllerFolder() into controllerFolder
   --
   set the itemdelimiter to slash
   put item 1 to -2 of controllerFolder & "/stacks/" into stackFolder
   set the itemdelimiter to "."
   put stackFolder & shortController into scriptStackFile
   put "livecodescript" into item -1 of scriptStackFile
   --
   return scriptStackFile
end rig_LocalControllerStackPath

function rig_LocalControllerScriptPath shortController
   put rig_GetLocalControllerFolder() into controllerFolder
   put controllerFolder & shortController into controllerScriptPath
   return controllerScriptPath
end rig_LocalControllerScriptPath

function rig_GetLocalControllerFolder
   put pref_FetchValue ("rigControllerFolder") into controllerFolder
   text_AddTrailing controllerFolder, slash
   return controllerFolder
end rig_GetLocalControllerFolder

command rig_StoreControllerFolder controllerFolder
   text_AddTrailing controllerFolder, slash
   pref_SaveValue "rigControllerFolder", controllerFolder
   put the result into dataArray
   return dataArray
end rig_StoreControllerFolder


--> Working on
-
function rig_ConstructDepScriptLines shortLibPaths, pOldWay
   put rig_ListStackFiles() into serverShortStackFiles
   --
   replace CR with comma in shortLibPaths
   repeat for each item shortController in shortLibPaths
      if pOldWay is not false then
         -- start using stack (gRigA["APPPATH"] & "stacks/lib_Fedwiki.livecode")
         put "stacks/" & shortController into relPath
         put "start using stack (gRigA[" & kwote("APPPATH") & "] &" && kwote(relPath) & ")" into scriptLine
      else
         put rig_GetControllerStackName (shortController) into stackName
         
         -- some checks
         switch
            case exists (stack stackName) is false
               breakpoint
               next repeat
            case _QuickUploadedTest (stackName, serverShortStackFiles) is false
               breakpoint
               next repeat
            default
               put "rigLoadStack" && kwote(stackName) into scriptLine
         end switch
      end if
      --
      put CR & scriptLine after scriptLines
   end repeat
   delete char 1 of scriptLines
   return scriptLines
end rig_ConstructDepScriptLines

function rig_GetControllerStackName shortController
   -- should work but some old stacks have ".livecode" as an extension
   -- a basic naming convention assumption that a stacks short file is its name + extension
   set the itemdelimiter to "."
   put item 1 of shortController into stackName
   return stackName
end rig_GetControllerStackName

function _QuickUploadedTest stackName, serverShortStackFiles
   -- hacky but effective test
   replace ".livecodescript" with empty in serverShortStackFiles -- do this first
   replace ".livecode" with empty in serverShortStackFiles
   --
   put stackName is among the lines of serverShortStackFiles into isThere
   return isThere
end _QuickUploadedTest


--> Rig
-
command rig_SetLocalControllerFolder @controllerFolder
   -- utility
   if controllerFolder is empty then
      put rig_GetLocalControllerFolder() into controllerFolder
      if there is not a folder controllerFolder then
         put controllerFolder
         answer folder "Select a folder for your controllers..." as sheet
         if it is empty then
            answer warning "Cannot locate controller folder. Please set one!"
            exit to top
         else
            put it & slash into controllerFolder
            rig_StoreControllerFolder controllerFolder
         end if
      end if
   end if
   text_AddTrailing controllerFolder, slash
end rig_SetLocalControllerFolder

function rig_ExtractDependencies buttonScript
   return empty
end rig_ExtractDependencies

function rig_ConstructGetProp stackNames
   -- just in case
   put word 1 to -1 of stackNames into stackNames
   replace CR with comma in stackNames
   --
   put "getprop dep_StackNames" into getProphandler
   put CR & "    return" && kwote (stackNames) after getProphandler
   put CR & "end dep_StackNames" after getProphandler
   --
   return getProphandler
end rig_ConstructGetProp


--> Rig | rigScript
-
getprop rig_RouteNames
   put the script_HandlerNames ["M"] of the target into routeNames
   filter routeNames without "_*"
   replace "mouseUp" with "index" in routeNames
   return routeNames
end rig_RouteNames

getprop rig_ControllerHandlers   
   put the script of the target into someScript
   put the revAvailableHandlers of the target into handlerTable
   sort numeric handlerTable by word 3 of each
   put rig_ExtractControllerHandlers (handlerTable, someScript) into controllerHandlers
   return controllerHandlers
end rig_ControllerHandlers

getprop rig_ControllerHkeys
   put the long id of the target into hObject
   put revRuggedID (hObject) into hObject
   --
   put the rig_ControllerHandlers of the target into hNames
   repeat for each item hName in hNames
      put hKeyLine_Construct (hName, "M", hObject) into hKeyLine
      put hKeyLine & CR after hkeys
   end repeat
   delete char -1 of hkeys
   return hkeys
end rig_ControllerHkeys

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


--> Rig | Create
-
command rig_DownloadScriptAndCreateStack shortController, pControllerFolder
   -- assumes the controller is in "/var/www/html/system/application/rest.livecode.world/controllers/"
   if shortController is empty then
      return empty
   end if
   
   put "rest.livecode.world" into pServerURL
   rig_SetLocalControllerFolder pControllerFolder
   put pControllerFolder & shortController into controllerFile
   
   -- save the controller.lc version locally
   put rig_FetchController (shortController, pServerURL) into rigScript
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
   put rig_LocalControllerStackPath (shortController) into scriptStackFile
   --
   if exists (stack scriptStackFile) then
      set the script of stack scriptStackFile to controllerScript
   else
      create script only stack shortController
      set the script of stack shortController to controllerScript
      set the filename of stack shortController to scriptStackFile
      save stack shortController
   end if
   --
   rig_SetOveride true
   --
   return scriptStackFile
end rig_CreateLocalControllerStack


--> Rig | Controller | Script
-
function rig_CreateContainerScript rigScript, shortController
   if shortController is empty then return empty
   set the itemdelimiter to "."
   put item 1 of shortController into cName
   set the itemdelimiter to comma
   --
   _StripInitCommand rigScript, cName
   put the result into getpropHandler
   --
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

function rig_ConstructControllerScript scriptObject, shortController, pDepShortPaths, pScriptDescription
   if pScriptDescription is empty then
      put the script_Help of scriptObject into pScriptDescription
   end if
   if pDepShortPaths is empty then
      -- put the dep_ControllerLibs of scriptObject into pDepShortPaths
      put the dep_StackNames of scriptObject into stackNames
      put stack_ConvertNamesToShortPaths (stackNames, badNames) into pDepShortPaths
   end if
   --
   put the script of scriptObject into someScript
   put the revAvailableHandlers of scriptObject into hTable
   put _MakeControllerScript (someScript, hTable, shortController, pDepShortPaths, pScriptDescription) into rigScript
   --
   return rigScript
end rig_ConstructControllerScript

private function _MakeControllerScript someScript, hTable, shortController, pDepShortPaths, pScriptDescription
   put rig_ExtractControllerHandlers (hTable, someScript) into controllerHandlers
   put rig_FilterControllerScript (someScript, hTable) into controllerScript
   text_Indent controllerScript
   text_Indent pScriptDescription
   put rig_ConstructControllerFromScript (controllerScript, shortController, controllerHandlers, pScriptDescription, pDepShortPaths) into rigScript
   return rigScript
end _MakeControllerScript

function rig_ConstructControllerFromScript controllerScript, shortControllerFile, controllerHandlerList, scriptDescription, pShortDepLibFiles
   -- controllerScript must has getprop and setprop handers stripped out
   replace CR with comma in controllerHandlerList
   
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
   put rig_ConstructDepScriptLines (pShortDepLibFiles) into initScriptLines -- was rig_ConstructInitScriptLines
   text_Indent initScriptLines, "      "
   --
   put rig_FilterControllerScript (controllerScript, hTable) into publicHandlers
   --
   put scaffold_Get ("revIgniter Controller Template") into scriptTemplate
   put merge (scriptTemplate) into rigScript   
   --
   /*
   put scaffold_Get ("revIgniter Dependency Section")  into dependencyTemplate
   put rig_ExtractDependencies (controllerScript) into handlerDependencies
   if handlerDependencies is not empty then
      put merge (dependencyTemplate) into dependencySection
      text_Indent dependencySection, "   "
      put CR & CR after rigScript
      put dependencySection after rigScript
   end if
   */
   
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
   
   -- script_DeleteHandler controllerScript, "G dep_StackNames", hTable
   -- remove getprop and setprops (well the one we use for now)
   script_StripPropHandlers controllerScript, hTable
   
   return controllerScript
end rig_FilterControllerScript


--> Deps
-
private command _StripHeaderFromRigScript @rigScript
   put word 1 to -1 of rigScript into rigScript
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

private command _StripInitCommand @rigScript, cName
   script_SetHandlerOffsets startHandler, endHandler, cName, "command", rigScript
   --
   if endHandler = 0 then return empty
   
   put the result into initHandler
   delete char startHandler to endHandler of rigScript
   --
   put the number of lines of initHandler into maxLine
   repeat with lineNum = 2 to (maxLine -1)
      get line lineNum of initHandler
      -- was start using stack (gAPPPATH & "stacks/lib_HTML.livecode")
      -- start using stack (gRigA["APPPATH"] & "stacks/lib_Fedwiki.livecode")
      
      -- put token 2 of it into stackName -- for rigLoadStack "lib_Audioboom"
      put token -2 of it into pathBit
      set the itemdelimiter to slash
      put item -1 of pathBit into shortControllerFile
      set the itemdelimiter to "."
      put item 1 of shortControllerFile into stackName
      
      put stackName & CR after stackNames
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
   
   put rig_ConstructGetProp (stackNames) into getProphandler
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
