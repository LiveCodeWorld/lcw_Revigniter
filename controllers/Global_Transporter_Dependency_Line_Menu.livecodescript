script "Global | Transporter | Dependency | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Transporter | Dependency | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
   
   put the display_View of tObject into displayView
   --
   put the data_Array of displayView into LocalArray ["dataArray"]
end menu_Init

getprop test_Param [displayView]
   return "b"
end test_Param

getprop test_Params [displayView]
   return "a,b,c"
end test_Params

getprop menu_CheckTarget [displayView]
   return true
end menu_CheckTarget

getprop checked_TestChecked
   return true
end checked_TestChecked

getprop disabled_Test
   return false -- true, "delete"
end disabled_Test

private function _GetOtherStackObjects displayView
   put the displayed_Array of displayView into objectArray
   --
   put the top_Line of displayView into selectedLib
   delete variable objectArray [selectedLib]
   put the keys of objectArray into otherStackObjects
   return otherStackObjects
end _GetOtherStackObjects

private command _ReplaceFoundHkey @objectArray, hKey, selectedLib, foundHkey
   delete variable objectArray [selectedLib][hKey]
   if the keys of objectArray [selectedLib] is empty then
      delete variable objectArray [selectedLib]
   end if
   --
   hkeyLine_Deconstruct foundHkey, hName, hType, hObject
   put empty into objectArray [hObject][foundHkey]
end _ReplaceFoundHkey


--> Global | Transporter | Dependency | Line | Menu
-
on menu_UseTransportLibrary displayView
   put the selected_Line of displayView into hKey
   put word 1 to 2 of hKey into shortHKey
   
   put the displayed_Array of displayView into objectArray
   put the top_Line of displayView into selectedLib
   
   -- let's search the other objects
   put _GetOtherStackObjects (displayView) into otherStackObjects
   put hkey_PublicFind (shortHKey, otherStackObjects) into foundHkey
   --
   if foundHkey is empty then
      -- let's search local versions of all online transport libs
      put transport_ListLibraryStackNames() into stackNames
      put stack_ConvertNamesToObjects (stackNames) into stackObjects
      put hkey_PublicFind (shortHKey, stackObjects) into foundHkey
      if foundHkey is empty then
         lcw_AnswerWarning "Could not find missing handler '[[shortHKey]]'!", displayView, shortHKey
      end if
   end if
   --
   _ReplaceFoundHkey objectArray, hKey, selectedLib, foundHkey
   set the displayed_Array of displayView to objectArray
end menu_UseTransportLibrary

on _
end _

on menu_FindInDisplayed displayView
   put word 1 to 2 of the selected_Line of displayView into shortHKey
   put _GetOtherStackObjects (displayView) into otherStackObjects
   --
   put hkey_FindObjects (shortHKey, otherStackObjects)
end menu_FindInDisplayed

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
