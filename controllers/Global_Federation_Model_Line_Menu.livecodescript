script "Global | Federation | Model | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Federation | Model | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called first
   put the display_View of tObject into displayView
   --
   return displayView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

private function _GetModelName shortModelFile
   set the itemdelimiter to "."
   put item 1 of shortModelFile into pageSlug
   put fedwiki_ConstructTitle (pageSlug) into modelName
   return modelName
end _GetModelName

private function _ShortModelFile displayView
   put the selected_Line of displayView into shortModelFile
   return shortModelFile
end _ShortModelFile


--> Global | Federation | Model | Line | Menu
-
on menu_DisplayModel displayView
   put _ShortModelFile (displayView) into shortModelFile
   --
   display_FederationModel shortModelFile
end menu_DisplayModel

on menu_TransportModelHelp displayView
   put _ShortModelFile (displayView) into shortModelFile
   put _GetModelName (shortModelFile) into modelName
   --
   put modelName
end menu_TransportModelHelp

on _
end _

on menu_DeleteModel displayView
   put _ShortModelFile (displayView) into shortModelFile
   lcw_Answer "Are you sure you want to delete the model [[shortModelFile]]?", displayView, shortModelFile
   set the cursor to watch
   --
   federation_DeleteModelFromShortFile shortModelFile
   put the result into deleteShellResult
   --
   display_TransportModels
end menu_DeleteModel
