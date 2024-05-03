script "model_TransportFiles"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_TransportFiles
type: model
version: 0.1


--> Transport | List
-
function transport_List pListHow
   switch pListHow
      case "remote array"
         put rig_FetchControllerPathArray() into sData
         break
      case "remote"
         put rig_ListControllerFiles() into sData
      default -- "local"
         put transport_ListLocalNames() into sData
   end switch
   return sData
end transport_List

function transport_ListLocalNames
   -- tranport stack names are named ".lc"
   put transport_StackFolder() into sFolder
   put folder_ListStackNames (sFolder) into tNames
   sort lines of tNames
   return tNames
end transport_ListLocalNames

function transport_ListLocalShortFiles
   -- tranport stack filess are named ".livecodescript"
   put transport_StackFolder() into sFolder
   put file_ListShort (sFolder) into tNames
   sort lines of tNames
   return tNames
end transport_ListLocalShortFiles


--> Transport | Create
-
command transport_Create controllerShortFile, controllerHandlers, scriptDescription, dependencyLibs
   -- for server version see "rig_CreateController"
   
   # Check it is new
   put transport_ListLocalShortFiles() into existingShortFiles
   set the itemdelimiter to "."
   put controllerShortFile into testShortFile
   put livecodescript into item 2 of testShortFile
   if testShortFile is among the lines of existingShortFiles then
      return "Error, controller already exists!"
   end if
   
   # Constuct Rig script
   put scaffold_Get ("Rig Controller Handlers") into controllerScriptTemplate   
   put rig_ConstructControllerFromScript (controllerScriptTemplate, controllerShortFile, controllerHandlers, scriptDescription, dependencyLibs) into rigScript
   
   # Create and save Controller Stack
   put rig_CreateContainerScript (rigScript, controllerShortFile) into controllerScript
   transport_CreateControllerStack controllerScript, controllerShortFile, controllerFolder
   put the result into cStackPath
   
   # Save Rig Script
   transport_StoreRigScript controllerShortFile, rigScript
   
   return cStackPath
end transport_Create

command transport_CreateControllerStack controllerScript, shortController, pControllerFolder
   -- mirror of "rig_CreateLocalControllerStack"
   put transport_ControllerStackPath (shortController) into cStackPath
   --
   if exists (stack cStackPath) then
      breapoint
      set the script of stack cStackPath to controllerScript
   else
      create script only stack shortController
      set the script of stack shortController to controllerScript
      set the filename of stack shortController to cStackPath
      save stack shortController
      --
      set the stack_IsKnown of stack shortController to true
   end if
   --
   return cStackPath
end transport_CreateControllerStack

command transport_DeleteController shortController
   put transport_ControllerStackPath (shortController) into cStackPath
   if exists (stack cStackPath) then
      set the stack_IsKnown of stack cStackPath to false
      delete stack cStackPath
      revDeleteFile cStackPath
      --
      put transport_RigScriptPath (shortController) into rigScritPath
      revDeleteFile rigScritPath
   else
      return empty
   end if
end transport_DeleteController

command transport_StoreRigScript shortFile, rigScript
   put transport_RigScriptPath (shortFile) into controllerPath
   text_Set controllerPath, rigScript
   return controllerPath
end transport_StoreRigScript

function transport_ControllerStackPath controllerName
   -- controllerName git or git.lc or git.livecodescript
   put transport_StackFolder() into stackFolder
   --
   set the itemdelimiter to "."
   put stackFolder & controllerName into scriptStackFile
   put "livecodescript" into item -1 of scriptStackFile
   --
   return scriptStackFile
end transport_ControllerStackPath


--> Transport | Folder
-
function transport_RigScriptPath pShortpath
   -- mirror of "rig_ApplicationPath()"
   put transport_ControllerFolder() into controllerPath
   if pShortpath is not empty then put pShortpath after controllerPath
   return controllerPath
end transport_RigScriptPath

function transport_ControllerFolder
   put project_GetFolder ("lcw_Controllers", "controllers") into sFolder
   return sFolder
end transport_ControllerFolder

function transport_StackFolder
   -- mirror of "rig_GetLocalControllerFolder()"
   put project_GetFolder ("lcw_Controllers", "stacks") into sFolder
   return sFolder
end transport_StackFolder
