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

private function _GetHkey displayView
   put the selected_Line of displayView into hKey
   if hkey_Check (hKey) is true then
      return hKey
   else
      return empty
   end if
end _GetHkey

function hkey_Check hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   if exists (hObject) is false then return false
   if hType is not among the items of "M,F,G,S,PM,PF" then return false
   if the number of words of hName is not 1 then return false
   return true
end hkey_Check

private function _IsHkey displayView
   if _GetHkey (displayView) is empty then
      return false
   else
      return true
   end if
   /*
   get the selected_Path of displayView
   switch 
      case item 3 of it is empty
      case item 3 of it is "top"
         return true
      case item 2 of it not empty
         return false
      default
         return false
   end switch
   */
end _IsHkey

-- getprop menu_DisplayDeps [displayView]
return _IsHkey (displayView)
end menu_DisplayDeps

getprop disabled_EditHandler [displayView]
   return _IsHkey (displayView) is false
end disabled_EditHandler


--> Global | Transporter | Dependency | Line | Menu
-
on menu_EditHandler displayView
   put _GetHkey (displayView) into hKey
   --
   hkey_Edit hKey
end menu_EditHandler

on menu_EditLibrary displayView
   get the selected_Path of displayView
   put item 1 of it into libStackName
   --
   edit the script of stack libStackName
end menu_EditLibrary

on _
end _

on menu_UseTransportLibrary displayView
   put _GetHkey (displayView) into hKey
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

on menu_TranportHandlerHkeyArray displayView
   put _GetHkey (displayView) into hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   --
   put the title_Text of displayView into tObject
   --
   put transport_GetLibraryStacks (tObject) into searchObjects
   put walk_GetHkeyArray (hKey, searchObjects) into hKeyArray
   --
   display_Data hKeyArray, shortHkey, "hKeyArray"
end menu_TranportHandlerHkeyArray

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_FindInDisplayed displayView
   put _GetHkey (displayView) into hKey
   put word 1 to 2 of hKey into shortHKey
   put _GetOtherStackObjects (displayView) into otherStackObjects
   --
   put hkey_FindObjects (shortHKey, otherStackObjects)
end menu_FindInDisplayed
