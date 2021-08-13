script "Global | Display | Rig | Stacks | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Display | Rig | Stacks | Line | Menu
type: controller
version: 0.1


--> Global | Display | Rig | Stacks | Line | Menu
-
on menu_UploadStackLibrary indexView
   put _GuessAndCheckStackName (indexView) into stackName
   --
   put merge ("Do you want to save the stack library '[[stackName]]' to rest.livecode.world?") into someQuestion
   lcw_Answer someQuestion, indexView 
   
   rig_StoreStack stackName
   put the result into shellResult
   if shellResult contains "Permission denied" then
      answer warning "Permission denied!"
      put shellResult
   else
      lcw_Notify merge ("Uploaded stack library '[[stackName]]'!")
   end if
end menu_UploadStackLibrary

private function _GuessAndCheckStackName indexView
   put the selected_Line of indexView into shortFile
   
   -- let's guess the stackName
   set the itemdelimiter to "."
   put item 1 of shortFile into stackName
   if exists (stack stackName) is false then
      put merge ("Cannot find stack '[[stackName]]'. Please start the project or find the library some other way?") into someQuestion
      lcw_AnswerWarning someQuestion, indexView, stackName
      return empty
   end if
   --
   return stackName
end _GuessAndCheckStackName

on menu_Check indexView
   put the selected_Line of indexView into shortFile
   rig_CheckAndSaveFile shortFile, indexView
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

on _
end _

on menu_EditLocalLibrary indexView
   put _GuessAndCheckStackName (indexView) into stackName
   --
   edit the script of stack stackName
end menu_EditLocalLibrary
