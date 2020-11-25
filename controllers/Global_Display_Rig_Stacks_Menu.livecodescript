script "Global | Display | Rig | Stacks | Menu"
--> MetaData
-
license: GPLv3
name: Global | Display | Rig | Stacks | Menu
type: controller
version: 0.1


--> Global | Display | Rig | Stacks | Menu
-
on menu_UploadBlueLibraries indexView
   put the displayed_Index of indexView into oIndex
   --
   put the coloured_Lines ["0,0,255"] of indexView into blueLines
   set the displayed_Index ["Modified Rig Stacks"] of indexView to blueLines
   --
   _UploadDisplayedShortFiles blueLines, indexView
   --
   set the displayed_Index of indexView to oIndex
end menu_UploadBlueLibraries

on _
end _

on menu_TestDisplayedStacks indexView
   put the displayed_Index of indexView into shortFiles
   rig_CheckFiles shortFiles, indexView
end menu_TestDisplayedStacks

on menu_TestRigStacks indexView
   set the title_Text ["Stack Libraries"] of indexView to server_GetURL()
   --
   stack_SaveEdited "Save All"
   display_TransporterLibs indexView
   put the displayed_Index of indexView into shortFiles
   --
   rig_CheckFiles shortFiles, indexView
end menu_TestRigStacks

on _
end _

on menu_Refresh
   display_TransporterLibs
end menu_Refresh

on menu_RevealLocalRepo
   put rig_GetFolder ("stacks") into folderPath
   finder_Reveal folderPath
end menu_RevealLocalRepo

on _
end _

on menu_DisplayHkeyArray indexView
   put the title_Text of indexView into hKey
   --
   put hkey_GetLinkArray (hKey) into hkeyDepArray
   display_Array hkeyDepArray, hKey
   -- put deps_FromHkeyArray (hKey, hkeyDepArray, pReturnShortHkey) into hKeyDeps
end menu_DisplayHkeyArray

on menu_DisplayHkeyObjectArray indexView
   put the title_Text of indexView into hKey
   --
   put hkey_GetLinkArray (hKey) into hkeyDepArray
   put hkeyArray_GetDepArray (hkeyDepArray) into hkeyObjectArray
   --
   put hKey,"Object Array" into dTitle
   display_Array hkeyObjectArray, dTitle
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Rig | ObjectArray | Menu"
   set the line_Menu of displayView to "Global | Rig | ObjectArray | Line | Menu"
end menu_DisplayHkeyObjectArray


--> Global | Display | Rig | Stacks | Menu | Props
-

--> Global | Display | Rig | Stacks | Menu | Disabled
-
command _UploadDisplayedShortFiles shortFiles, indexView
   -- assumes short file is names after stack name
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      display_Spin shortFiles, indexView
      put the result into lineNum
      set the line_Colour [lineNum] of indexView to red
      --
      set the cursor to busy
      put item 1 of shortFile into stackName
      if exists (stack stackName) is false then
         breakpoint
         next repeat
      end if
      
      rig_StoreStack stackName
      put the result into shellResult
      if shellResult is empty then
         set the deleted_Line of indexView to shortFile
      else
         lcw_Answer ("Failed to upload stack" && kwote (shortFile) & ".")
         breakpoint
      end if
   end repeat
end _UploadDisplayedShortFiles

command _UploadDisplayedStackNames changedRigStackNames, indexView
   repeat for each line stackName in changedRigStackNames
      display_Spin stackName, indexView
      put the result into lineNum
      set the line_Colour [lineNum] of indexView to red
      --
      rig_StoreStack stackName
      put the result into shellResult
      if shellResult is empty then
         set the deleted_Line of indexView to domainName
      else
         lcw_Answer ("Failed to upload stack" && kwote (stackName) & ".")
         breakpoint
      end if
   end repeat
end _UploadDisplayedStackNames
