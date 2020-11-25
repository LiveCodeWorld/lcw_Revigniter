script "Global | Transporter | Dependency | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Transporter | Dependency | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [tObject]
   put tObject into LocalArray ["tObject"]  
   put the display_View of tObject into displayView
   --
   put the title_Text of displayView into transportStack
   put the displayed_Array of displayView into objectDepArray
   --
   put transportStack into LocalArray ["transportStack"]
   put objectDepArray into LocalArray ["objectDepArray"]
   --
   delete variable objectDepArray [controllerStack]
   delete variable objectDepArray ["Missing"]
   delete variable objectDepArray ["revIgniter"]
   --
   delete variable objectDepArray [transportStack]
   put the keys of objectDepArray into otherStackObjects
   put otherStackObjects into LocalArray ["otherStackObjects"]
   --
   return displayView
end menu_Target

getprop disabled_FindMissing
   put LocalArray ["objectDepArray"]["Missing"] into missingArray
   if missingArray is an array then
      return false
   else
      return true
   end if
   return false -- true, "delete"
end disabled_FindMissing

private function _GetTransportStack displayView
   return LocalArray ["transportStack"]
end _GetTransportStack

private function _GetTransportLibs displayView
   return LocalArray ["otherStackObjects"]
end _GetTransportLibs


--> Global | Transporter | Dependency | Menu
-
on menu_FindMissing displayView
   put LocalArray ["objectDepArray"] into objectDepArray
   --
   put transport_ListServerLibraryStacks() into searchObjects
   transport_FindUpdateObjectDepArray objectDepArray, searchObjects
   set the displayed_Data of displayView to objectDepArray
   set the stack_Label of displayView to "Server Transport Deps"
   --
   put env_ScriptHierarchy (true) into searchObjects
   transport_FindUpdateObjectDepArray objectDepArray, searchObjects
   set the displayed_Data of displayView to objectDepArray
   -- set the stack_Label of displayView to "Environment Transport Deps"
   --
   menu_DisplayGetpropHandler displayView
end menu_FindMissing

on menu_UpdateTransport displayView
   put _GetTransportStack (displayView) into tObject
   --
   transport_Upload tObject
   --
   put the result into shellResult
   put the short_File of tObject into shortFile
   if shellResult contains "Permission denied" then
      put shellResult
      lcw_AnswerWarning "Failed to upload transporter '[[shortFile]]", displayView, shortFile
   else
      lcw_Answer "Uploaded transporter '[[shortFile]]. Do you want to check the libs?", displayView, shortFile
   end if
   --
   menu_DisplayTransportLibs
end menu_UpdateTransport

on menu_DisplayTransportLibs
   put _GetTransportLibs (displayView) into otherStackObjects
   put stack_ConvertObjectsToShortPaths (otherStackObjects) into otherShortPaths
   --
   display_ServerStacks otherShortPaths
   put the result into displayView
   --
   rig_CheckFiles otherShortPaths, displayView
   put the result into resultArray
   --
   if the keys of resultArray = "good" then
      lcw_AnswerWarning "Nothing to update!", displayView
   else
      lcw_Answer "Upload blue and red dependency libs to server!", displayView
      --
      menu_DoGlobal "menu_UploadBlueLibraries", "Global | Display | Rig | Stacks | Menu", displayView
   end if
end menu_DisplayTransportLibs

on _
end _

on menu_CreateTransporterGraphs displayView
   put _GetTransportStack (displayView) into tStack
   --
   transporter_CreateGraph tStack, true, true
end menu_CreateTransporterGraphs

on _
end _

on menu_Refresh displayView
   put the title_Text of displayView into tObject
   --
   display_TransportObjectDeps tObject
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_IdeDictionary
   edit the script of stack "lib_IDE"
   edit the script of stack "lib_IdeHack"
end menu_IdeDictionary

on menu_DisplayGetpropHandler displayView
   put the title_Text of displayView into tObject
   put the displayed_Data of displayView into objectDepArray
   --
   display_TransportGetpropIfNeeded tObject, objectDepArray
   put the result into someError
   if item 1 of the result is "error" then
      lcw_AnswerWarning someError, displayView
   else
      put someError into getpropDisplayView
      lcw_Answer "The scripts 'getprop dep_StackNames' handler is not correct. Please update script.", getpropDisplayView
      edit the script of tObject
   end if
end menu_DisplayGetpropHandler

on menu_DisplayWalkHierarchy displayView
   put LocalArray ["tObject"] into tObject
   put the walk_Hierarchy of tObject into walkHierarchy
   --
   put revRuggedID (tObject) into tObject
   display_Data walkHierarchy, tObject, "the walk_Hierarchy"
end menu_DisplayWalkHierarchy
