script "lib_DisplayTransport"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayTransport
type: library
version: 0.1


/*
Here we define handlers that create projects and project specific stacks (libraries, menus, controllers, behaviors, modules etc"
*/


--> Variables
-
local LocalArray


--> Working on
-
on graph_TidyLinkArray @hkeyArray
   -- before graph arrays have been created
   -- let's just process hkeyArray for transportation purposes
   put the long id of me into processObject
   -- hkeyArray_Process hkeyArray, processObject
end graph_TidyLinkArray

on hkey_Rename hkey
   hkey_Deconstruct hkey, hName, hType, hObject, hNum
   switch
      case hName = "transporter_RawJSON"
         return empty
      case hName begins with "rig"
         put "revIgniter" into hObject -- could be "stack 'revIgniter'"?
         put hKeyLine_Construct (hName, hType, hObject) into rigKey
         return rigKey
      default
         return hKey
   end switch
end hkey_Rename


--> Events
-
on mDoubleUp_PageArray displayView, sText, sPath
   -- replace "¬†" with space in sText
   -- replace "‚Äô" with empty in sText
   display_HtmlText sText
   put sText
end mDoubleUp_PageArray

on mDoubleUp_ObjectDeps displayView, someValue, sPath
   switch the number of lines of sPath
      case 4
         put line -1 of sPath into hKey
         put line -2 of sPath into shortMissingHkey
         --
         put the displayed_Object of displayView into sObject
         put the displayed_HkeyArray of displayView into hkeyArray
         --
         hkey_Edit hKey
         --
         display_MissingHkey hkeyArray, sObject
         break
      case 3
         put line 3 of sPath into objectHkeyParent
         hkey_Edit objectHkeyParent
         break
      default
         put line -1 of sPath into hObject
         hkey_Edit hObject
   end switch
end mDoubleUp_ObjectDeps


--> Working on
-


--> Display | Transport
-
command display_Transporters pDisplayArray
   put transport_List (pDisplayArray) into sData
   --   
   display_Tools sData, "rest.livecode.world", "Revigniter | Display | Controller", "Transporters" --, "lcw_Revigniter"
   put the result into displayView
   --
   return displayView
end display_Transporters

on mDoubleUp_RevigniterDisplayController dView shortFile
   -- rig_EditController shortFile
   
   put transport_ControllerStackPath (shortFile) into cStackPath
   edit the script of stack cStackPath
end mDoubleUp_RevigniterDisplayController

command display_RigControllerArray
   put "rest.livecode.world" into serverURL
   put "revIgniter Controller Array" into stackLabel
   --
   put rig_FetchControllerPathArray() into controllerPathArray
   --
   put display_FindView (stackLabel, serverURL) into displayView
   if exists (displayView) then
      set the displayed_Data of displayView to controllerPathArray
   else
      display_Array controllerPathArray, serverURL, stackLabel
      put the result into displayView
      display_SetInteractions displayView, "Revigniter | Display | Controller", ""
   end if
   return displayView
end display_RigControllerArray


--> Display | Tranport | Dropper
-
command display_TransportDropper
   put transport_GetDroppedUrlIndex() into urlIndex
   repeat for each line someURL in urlIndex
      transport_AddDroppedUrl urlArray, someUrl
   end repeat
   --
   display_Data urlArray, "Dropped URL's", "Transporter"
   put the result into displayView
   put the stack_Name of displayView into stackName
   set the systemwindow of stack stackName to true
   --
   display_SetInteractions displayView, "Transporter | Tree", "mDouble_DoTransport"
   --
   set the drop_Command of displayView to "drop_DoTransport"
   put menu_GetGlobalController ("Global | Transporter | Tree | Menu") into mController
   set the mouse_Target of displayView to mController
   --
   return displayView
end display_TransportDropper

command transport_AddDroppedUrl @prettyArray, someUrl
   url_Deconstruct someUrl, someProtocol, urlDomain, urlPath, shortName, fileExtension, uName, pWord
   url_DeconstructTopDomain urlDomain, topDomainName, subDomainBit
   if subDomainBit is empty then
      put empty into prettyArray [topDomainName]["url"][someUrl]
   else
      put empty into prettyArray [topDomainName][subDomainBit]["url"][someUrl]
   end if
end transport_AddDroppedUrl


--> Display | Tranport | StackLibs
-
command display_TransporterstackLibs cObject
   put the dep_StackNames of cObject into stackNames
   replace comma with CR in stackNames
   set the itemdelimiter to slash
   repeat for each line stackName in stackNames
      put the filename of stack stackName into stackPath
      put item -1 of stackPath into shortFile
      put shortFile & CR after shortStackFiles
   end repeat
   delete char -1 of shortStackFiles
   --
   display_ServerStacks shortStackFiles
end display_TransporterstackLibs

command display_TransporterLibs pDisplayView
   put rig_ListStackFiles() into shortStackFiles
   --
   display_ServerStacks shortStackFiles, pDisplayView
end display_TransporterLibs

command display_ServerStacks shortStackFiles, pDisplayView
   put server_GetURL() into serverURL
   if exists (pDisplayView) is false then put display_FindView ("Stack Libraries", serverURL) into pDisplayView
   
   if exists (pDisplayView) then
      set the displayed_index of pDisplayView to shortStackFiles
   else 
      display_Lines shortStackFiles, serverURL, "mDoubleUp_CheckRigStack", "Stack Libraries", true
      put the result into pDisplayView
      --
      put rig_GetFolder ("stacks") into folderPath
      set the folder_Path of pDisplayView to folderPath
      set the title_Menu of pDisplayView to "Global | Display | Rig | Stacks | Menu"
   end if
   set the line_Menu of pDisplayView to "Global | Display | Rig | Stacks | Line | Menu"
   return pDisplayView
end display_ServerStacks


--> Display | Transport | Deps
-
command display_TransportObjectDeps tObject, pWhichSearch
   -- put the transport_ObjectDepArray [pWhichSearch] of tObject into objectDepArray
   put the transport_DepHkeyArray [pWhichSearch] of tObject into hKeyArray
   put hkeyArray_GetStackDepArray (hkeyArray) into objectDepArray
   --
   if item 1 objectDepArray is "error" then lcw_AnswerWarning "Not a transporter!"
   switch char 1 of pWhichSearch
      case "e"
         put "Environment Transport Deps" into stackLabel
         break
      case "s"
         put "Server Transport Deps" into stackLabel
         break
      default
         put "Actual Transport Deps" into stackLabel
   end switch
   --
   display_Data objectDepArray, tObject, stackLabel
   put the result into displayView
   --
   display_SetInteractions displayView, "Transporter | Dependency", "mDoubleUp_ObjectDeps"
   --
   set the displayed_Object of displayView to tObject
   set the displayed_HkeyArray of displayView to hKeyArray
   set the displayed_Transport of displayView to tObject
   set the displayed_SearchType of displayView to pWhichSearch
   --
   return displayView
end display_TransportObjectDeps

command display_TransportGetpropIfNeeded tObject, objectDepArray
   delete variable objectDepArray [tObject]
   delete variable objectDepArray ["revIgniter"]
   put objectDepArray ["Missing"] is not empty into someMissing
   delete variable objectDepArray ["Missing"]
   --
   put the keys of objectDepArray into calculatedDepStackObjects
   put stack_ConvertObjectsToNames (calculatedDepStackObjects) into calculatedDepStackNames
   sort calculatedDepStackNames
   --
   put the dep_StackNames of tObject into actualDepStackNames
   replace comma with CR in actualDepStackNames
   sort actualDepStackNames
   --
   switch
      case calculatedDepStackNames is actualDepStackNames
         return "Error, not displaying as actual = calculated dependency stack names"
         break
      case someMissing is true
         return "Error, There are missing handlers for this transporter. Are you sure you want to create a 'dep_StackNames' handler?"
      default
         display_TransportGetPropHandler calculatedDepStackNames, tObject
         put the result into displayView
         return displayView
   end switch
end display_TransportGetpropIfNeeded

command display_TransportGetPropHandler depStackNames, pTitle
   if pTitle is empty then put "Getprop" into pTitle
   --
   put rig_ConstructGetProp (depStackNames) into newGetPropHandler
   display_Lines newGetPropHandler, pTitle, empty, "Transporter Handler"
   put the result into indexView
   --
   set the field_Style of indexView to "text"
   return indexView
end display_TransportGetPropHandler


--> Transport | Display | Old
-
command display_TransportHkeyDeps hKey
   breakpoint
   hkey_Normalize hKey
   --
   put deps_HkeyStackNames (hKey) into depStackNames
   display_TransportDeps depStackNames
   put the result into displayView
   --
   set the title_Text of displayView to hKey
end display_TransportHkeyDeps

command display_TransportDeps depStackNames
   breakpoint
   sort items of depStackNames
   put stack_ConvertNamesToShortPaths (depStackNames, badNames) into depShortFiles
   --
   display_ServerStacks depShortFiles
   put the result into displayView
   --
   if badNames is not empty then
      display_Lines badNames, "Bad Objects"
   end if
   return displayView
end display_TransportDeps


--> Display | Transport | Handlers
-
command display_ControllerHandlers controllerScript, pControllerShortFile, serverTLD
   server_SetURL "rest.livecode.world"
   --
   put rig_ListControllerFiles() into shortStackFiles
   display_Lines shortStackFiles, "Rig Controllers", "mDoubleUp_CheckRigControllers"
   put the result into displayView
   set the title_Menu of displayView to "Global | Revigniter | Display | Controller | Menu"
   set the line_Menu of displayView to "Global | Revigniter | Display | Controller | Line | Menu"
   --
   put rig_GetFolder ("controllers") into folderPath
   set the folder_Path of displayView to folderPath
end display_ControllerHandlers


--> Display | Transport | Return
-
command display_TransportReturnPageArray pageArray, pTitle
   if pTitle is empty then
      put display_GetSelectedTransport() into pTitle
      -- put "transport_ReturnPageArray()" into pTitle
   end if
   --   
   display_Data pageArray, pTitle, "Transport"
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Transport | ReturnPageArray | Menu"
   set the line_Menu of displayView to "Global | Transport | ReturnPageArray | Line | Menu"
   set the mouse_DoubleUp of displayView to "mDoubleUp_PageArray"
   set the mouse_Target of displayView to the long id of me
   --
   return displayView
end display_TransportReturnPageArray


--> Deps
-
function transport_GetDroppedUrlIndex
   put the text of fld 1 of stack "Transporter Drop Urls" into urlIndex
   return urlIndex
end transport_GetDroppedUrlIndex

function transport_GetSelectedHandler
   put LocalArray ["SelectedHandle"] into hName
   if hName is empty then put "index" into hName
   return hName
end transport_GetSelectedHandler

command transport_SetSelectedHandler hName
   put hName into LocalArray ["SelectedHandle"]
end transport_SetSelectedHandler

function display_GetSelectedTransport
   put LocalArray ["Selected Tranporter Short File"] into shortFile
   if exists (stack shortFile) then return shortFile
   
   put display_FindView ("revIgniter Controllers") into tDisplayView
   if exists (tDisplayView) is false then return empty
   
   put the selected_Line of tDisplayView into shortFile
   put shortFile into LocalArray ["Selected Tranporter Short File"]
   return shortFile
end display_GetSelectedTransport

command transport_SetSelected shortFile, displayView
   put shortFile into LocalArray ["Selected Tranporter Short File"]
   --
   put display_FindView ("revIgniter Controllers") into tDisplayView
   if exists (tDisplayView) then
      set the selected_Line of tDisplayView to shortFile
   end if
end transport_SetSelected


--> Deps
-
