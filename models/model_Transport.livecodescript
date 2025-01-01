script "model_Transport"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Transport
type: model
version: 0.2

/*
Deleting files is best done securely using ssh and private keys (pki)
Check the help for this model for code that uses a server side transport and rest to do the deletion.
*/


--> Working on
-
function federation_ModelUrl modelName
   put _ModelShortFile (modelName) into shortFile
   put federation_ModelUrlFromShortFile (shortFile) into modelURL
   return modelURL
end federation_ModelUrl

function federation_ModelUrlFromShortFile shortModelFile
   put "http://" & platform_RestDomain() & "/model/" & shortModelFile into modelURL
   return modelURL
end federation_ModelUrlFromShortFile

function federation_FetchStatusModel
   put federation_FetchModel ("Federation Status Model") into atopiaFedray
   return atopiaFedray
end federation_FetchStatusModel

command federation_StoreStatusModel statusData
   federation_StoreModel "Federation Status Model", statusData
   put the result into writeError
   return writeError
end federation_StoreStatusModel


--> Fedray | Model
-
function federation_FetchModel modelName
   if the environment = "development" then
      return federation_RestGetModel (modelName)
   end if
   
   put transport_GetModel (modelName) into modelData
   return modelData
end federation_FetchModel

command federation_StoreModel modelName, modelData
   if the environment = "development" then
      federation_RestPostModel modelData, modelName
      return the result
   end if
   
   transport_SetModel modelName, modelData
   put the result into modelPath
   put pageArray_Construct ("Written", modelPath) into rPageArray
   return rPageArray
end federation_StoreModel

command federation_DeleteModel modelName
   put _ModelPath (modelName) into modelPath
   _DeleteFile modelPath
   return the result
end federation_DeleteModel

command federation_DeleteModelFromShortFile shortModelFile
   put _ModelFolder() & shortModelFile into modelPath
   _DeleteFile modelPath
   return the result
end federation_DeleteModelFromShortFile


--> Display
-
command display_FederationModel nameOrShortFile
   if nameOrShortFile ends with ".json" then
      put federation_RestGetModelFromShortFile (nameOrShortFile) into modelData
   else
      put federation_FetchModel (nameOrShortFile) into modelData
   end if
   --
   display_Data modelData, nameOrShortFile, "Transport Model"
   return the result
end display_FederationModel


--> Federation | REST
-
function federation_RestGetModel modelName
   put federation_ModelUrl (modelName) into modelURL
   put _RestGetModel (modelURL) into modelData
   return modelData
end federation_RestGetModel

command federation_RestPostModel modelData, modelName
   put "TransportModel" into secretName
   if the environment is "server" then
      put rigFetchConfigItem (secretName) into pWord
   else
      put secret_Get (secretName) into pWord
   end if
   --
   put modelData into postData ["modelData"]
   put modelName into postData ["modelName"]
   put pWord into postData ["secret"]
   --
   put "http://" & platform_RestDomain() & "/atopia/writeModel" into postURL
   put jsonrpc_PostArray (postData, postURL) into rPageArray
   --
   return rPageArray
end federation_RestPostModel


--> Named | Federation | Models
-
function fedray_FetchModel
   put federation_FetchModel ("Federation Model") into fedray
   return fedray
end fedray_FetchModel

command fedray_StoreModel fedray
   federation_StoreModel "Federation Model", fedray
   put the result into putError
   return putError
end fedray_StoreModel

function atopia_FetchDomainArray
   put federation_FetchModel ("Atopia Domain Array") into atopiaFedray
   return atopiaFedray
end atopia_FetchDomainArray

command atopia_StoreDomainArray atopiaFedray
   if atopiaFedray is not an array then return "Error, atopiaFedray is not an array. Delete instead?"
   --
   federation_StoreModel "Atopia Domain Array", atopiaFedray
   put the result into writeError
   return writeError
end atopia_StoreDomainArray

function atopia_FetchCatModel
   put federation_FetchModel ("Atopia Category Model") into atopiaCatModel
   return atopiaCatModel
end atopia_FetchCatModel

command atopia_StoreCatModel atopiaCatModel
   federation_StoreModel "Atopia Category Model", atopiaCatModel
   put the result into modelPath
   return modelPath      
end atopia_StoreCatModel


--> Transport | Model | Write
-
function federation_RestGetModelFromShortFile shortModelFile
   put federation_ModelUrlFromShortFile (shortModelFile) into modelURL
   put _RestGetModel (modelURL) into modelData
   return modelData
end federation_RestGetModelFromShortFile

function transport_GetModel modelName
   put _ModelPath (modelName) into modelPath
   put "file:" & modelPath into jsonURL
   put url jsonURL into utf8JSON
   get textDecode (utf8JSON, "UTF-8")
   put json_ToArray (it) into modelData
   return modelData
end transport_GetModel

command transport_SetModel modelName, modelData
   put json_FromArray (modelData) into modelJSON
   
   # Encode modeJSON for storage
   put textEncode (modelJSON, "UTF-8") into utf8JSON
   
   # Relative file for rigWriteFile
   put _ModelRelativePath (modelName) into relativeFile
   
   # Write encodedJSON
   rigLoadHelper "file"
   if rigWriteFile (relativeFile, utf8JSON) is FALSE then
      return "Error, could not write file:" & relativeFile
   else
      return relativeFile
   end if
end transport_SetModel


--> Transport | Model | Files | List
-
function transport_ListModelFiles
   put _ModelFolder() into modelFolder
   put rig_ListFiles (modelFolder) into shortFiles
   return shortFiles
end transport_ListModelFiles


--> Private | Files
-
private function _RestGetModel modelURL
   put url modelURL into utf8JSON
   put textEncode (utf8JSON, "UTF-8") into rJSON
   put json_ToArray (rJSON) into modelData
   return modelData
end _RestGetModel


--> Private | Files
-
private function _ModelShortFile modelName
   put fedwiki_ConstructSlug (modelName) into modelSlug
   put modelSlug & ".json" into shortFile
   return shortFile
end _ModelShortFile

private function _ModelRelativePath modelName
   put _ModelShortFile (modelName) into shortFile
   put "./model/" & shortFile into relativeFile
   return relativeFile
end _ModelRelativePath

private function _ModelPath modelName
   put _ModelShortFile (modelName) into shortFile
   put _ModelFolder() into modelFolder
   put modelFolder & shortFile into modelPath
   return modelPath
end _ModelPath

private function _ModelFolder
   put _DocumentRoot() into modelFolder
   put "model/" after modelFolder
   return modelFolder
end _ModelFolder

private function _DocumentRoot
   if the environment is "server" then
      -- put server_GetDocumentRoot() & slash into modelFolder
      put $_SERVER ["DOCUMENT_ROOT"] & slash into modelFolder
   else
      put "/var/www/" & platform_RestDomain() & "/" into modelFolder
   end if
   return modelFolder
end _DocumentRoot

private command _DeleteFile sFile
   if the environment is "server" then
      delete file sFile
   else
      put platform_RestDomain() into restDomain
      ssh_DeleteFile "fortyfoxes", restDomain, sFile
   end if
   return the result
end _DeleteFile
