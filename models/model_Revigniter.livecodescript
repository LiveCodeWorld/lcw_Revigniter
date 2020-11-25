script "model_Revigniter"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: model_Revigniter
type: model
version: 0.3


--> Rig | Model
-
command rig_EditController shortFile   
   rig_DownloadScriptAndCreateStack shortFile
   put the result into scriptStackFile
   edit the script of stack scriptStackFile
   ide_SetScriptEditorTitles "Revigniter"
   return scriptStackFile
end rig_EditController

command rig_DeleteController shortControllerFile, serverTLD
   rig_CheckFileForDeletion shortControllerFile, serverTLD
   put the result into serverFilePath
   --
   put server_GetURL() into remoteDomain
   put server_GetSshUser() into sshUser
   ssh_DeleteFile sshUser, remoteDomain, serverFilePath
   put the result into shellResult
   return shellResult
end rig_DeleteController

function rig_FetchController shortFile, pServerURL
   put rig_GetFolder ("controllers") & shortFile into somePath
   put rig_FetchFile (somePath, pServerURL) into someData
   return someData
end rig_FetchController

function rig_FetchStack shortFile, pServerURL
   put rig_GetFolder ("stacks") & shortFile into somePath
   put rig_FetchFile (somePath, pServerURL) into someData
   return someData
end rig_FetchStack

function rig_FetchSystemHelper shortFile, pServerURL
   put rig_GetFolder ("helpers") & shortFile into somePath
   put rig_FetchFile (somePath, pServerURL) into someData
   return someData
end rig_FetchSystemHelper

function rig_FetchProjectFile shortFile, shortFolder, pServerURL  
   put rig_GetFolder ("helpers") & shortFile into somePath
   put rig_FetchFile (somePath, pServerURL) into someData
   return someData
end rig_FetchProjectFile

function rig_FetchSystemFile shortStackFile, shortFolder, pServerURL  
   put rig_GetSystemFolder (shortFolder) & shortStackFile into somePath
   put rig_FetchFile (somePath, pServerURL) into someData
   return someData
end rig_FetchSystemFile

command rig_StoreController shortFile, rigScript
   put rig_ApplicationPath ("controllers/" & shortFile) into somePath
   rig_StoreData rigScript, somePath
   put the result into shellResult
   return shellResult
end rig_StoreController

command rig_StoreStacks stackNames
   repeat for each line stackName in stackNames
      set the cursor to busy
      rig_StoreStack stackName
   end repeat
end rig_StoreStacks

command rig_StoreStack stackName
   if exists (stack stackName) is false then
      return merge ("error, stack '[[stackName]]' does not exist")
   end if
   
   put the name of stack stackName into stackObject
   set the behavior of stack stackName to empty -- hack to prevent missing behaviors on server
   save stackObject
   
   put the filename of stack stackName into localFile
   set the itemdelimiter to slash
   put item -1 of localFile into shortFile
   put rig_GetFolder ("stacks") & shortFile into somePath
   
   rig_UploadLocalFile localFile, somePath
   return the result
end rig_StoreStack
