script "Global_Display_Rig_Stacks_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Display_Rig_Stacks_Line_Menu
type: controller
version: 0.1


--> Global | Display | Rig | Stacks | Line | Menu
-
on menu_UploadStackLibrary indexView
   put the selected_Line of indexView into shortFile
   
   -- let's guess the stackName
   set the itemdelimiter to "."
   put item 1 of shortFile into stackName
   if exists (stack stackName) is false then
      put merge ("Cannot find stack '[[stackName]]'. Please start the project or find the library some other way?") into someQuestion
      dispatch "lcw_AnswerSheet" to indexView with someQuestion
      return false
   end if
   
   put merge ("Do you want to save the stack library '[[stackName]]' to rest.livecode.world?") into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   
   rig_StoreStack stackName
   put the result into shellResult
   if shellResult contains "Permission denied" then
      answer warning "Permission denied!"
      put shellResult
   else
      lcw_Notify merge ("Uploaded stack library '[[stackName]]'!")
   end if
end menu_UploadStackLibrary

on menu_Check indexView
   put the selected_Line of indexView into shortFile
   rig_CheckFile shortFile, indexView
   put the result into changedHow
   switch word 1 of changedHow
      case "missing"
         break
      case "changed"
         break
      case "good"
         break
   end switch
   put changedHow
end menu_Check


--> Global | Display | Rig | Stacks | Line | Menu | Props
-

--> Global | Display | Rig | Stacks | Line | Menu | Disabled
-
