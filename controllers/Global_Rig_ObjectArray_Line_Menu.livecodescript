script "Global | Rig | ObjectArray | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Rig | ObjectArray | Line | Menu
type: controller
version: 0.1


--> Global | Rig | ObjectArray | Line | Menu
-
on menu_FindMissing dView
   put display_FindView ("Object Array") into dView
   --
   put the title_Text of dView into hKey
   -- put the displayed_Array of dView into objectArray
   put the selected_Path of dView into pItems -- Missing,F pageArray_ConstructJournal of Missing,
   put item 1 of pItems into dObject
   put item 2 of pItems into dHkey
   --
   put hkey_GetLinkArray (hKey) into hkeyArray
   put hkeyArray_ExtractParentKeys (dHkey, hKeyArray) into parentKeys
   --
   display_HkeyLines parentKeys, "Parent Hkeys"
end menu_FindMissing


--> Global | Rig | ObjectArray | Line | Menu | Props
-

--> Global | Rig | ObjectArray | Line | Menu | Disabled
-
