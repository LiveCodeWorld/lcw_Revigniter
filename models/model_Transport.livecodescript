script "model_Transport"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Transport
type: model
version: 0.2


--> Display
-
command migrate_StatusModel
   get federation_FetchStatusModel()
   federation_StoreStatusModel it
   --
   display_TransportModels
   display_FederationModel "Federation Status Model"
end migrate_StatusModel

command display_FederationModel nameOrShortFile
   if nameOrShortFile ends with ".json" then
      put transport_FetchModelFromShortFile (nameOrShortFile) into modelData
   else
      put federation_FetchModel (nameOrShortFile) into modelData
   end if
   --
   display_Data modelData, nameOrShortFile, "Transport Model"
   return the result
end display_FederationModel

function federation_FetchStatusModel
   put federation_FetchModel ("Federation Status Model") into atopiaFedray
   return atopiaFedray
end federation_FetchStatusModel

command federation_StoreStatusModel statusData
   federation_StoreModel "Federation Status Model", statusData
   put the result into writeError
   return writeError
end federation_StoreStatusModel


--> Working on | Delete
-
command transport_PostDeleteModel modelName
   put modelName into postData ["modelName"]
   _PostDeleteFile postData
   put the result into rPageArray
   return rPageArray
end transport_PostDeleteModel

command transport_PostDeleteShortModelFile shortModelFile
   put shortModelFile into postData ["shortModelFile"]
   _PostDeleteFile postData
   put the result into rPageArray
   return rPageArray
end transport_PostDeleteShortModelFile

private command _PostDeleteFile postData
   put secret_Get ("TransportModel") into pWord
   put pWord into postData ["secret"]
   --
   put json_FromArray (postData) into postJSON
   put jsonrpc_Post (postJSON, "https://rest.livecode.world/atopia/deleteShortModelFile") into rPageJson
   --
   put json_ToArray (rPageJson) into rPageArray
   return rPageArray
end _PostDeleteFile

command transport_DeleteModel modelName
   put _ModelPath (modelName) into modelPath
   _DeleteFile modelPath
   return the result
end transport_DeleteModel

command transport_DeleteShortModelFile shortModelFile
   put _ModelFolder() & shortModelFile into modelPath
   _DeleteFile modelPath
   return the result
end transport_DeleteShortModelFile

private command _DeleteFile sFile
   if the environment is "server" then
      delete file sFile
   else
      ssh_DeleteFile "fortyfoxes", "rest.livecode.world", sFile
   end if
   return the result
end _DeleteFile


--> Working on
-

--> Atopia | DomainArray | Model
-
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


--> Fedray | Model
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


--> Fedray | Model
-
function federation_FetchModel modelName
   -- was "transport_FetchModel"
   if the environment = "development" then
      -- this would work on the server as well
      put _ModelShortFile (modelName) into shortModelFile
      put transport_FetchModelFromShortFile (shortModelFile) into modelData
   else
      put transport_GetModel (modelName) into modelData
   end if
   return modelData
end federation_FetchModel

command federation_StoreModel modelName, modelData
   -- was "transport_StoreModel"
   if the environment = "development" then
      put secret_Get ("TransportModel") into pWord
      transport_PostProtectedModel modelData, modelName, pWord
      put the result into rPageArray
   else
      transport_SetModel modelName, modelData
      put the result into modelPath
      put pageArray_Construct ("Written", modelPath) into rPageArray
   end if
   return rPageArray
end federation_StoreModel


--> Transport | Model | Write
-
function transport_GetModel modelName
   put transport_GetModelJSON (modelName) into modelJSON
   put json_ToArray (modelJSON) into modelData
   return modelData
end transport_GetModel

command transport_SetModel modelName, modelData
   put json_FromArray (modelData) into modelJSON
   transport_SetModelJSON modelName, modelJSON
   put the result into modelPath
   return modelPath
end transport_SetModel

function transport_GetModelJSON modelName
   put _LocalModelLocal (modelName) into jsonURL
   put url jsonURL into encodedJSON
   put textDecode (encodedJSON, "UTF-8") into modelJSON
   return modelJSON
end transport_GetModelJSON

command transport_SetModelJSON modelName, modelJSON
   # Encode modeJSON for storage
   rigLoadHelper "file"
   put textEncode (modelJSON, "UTF-8") into encodedJSON
   
   # Relative file for rigWriteFile
   put _ModelRelativePath (modelName) into relativeFile
   
   # Write encodedJSON
   if rigWriteFile (relativeFile, encodedJSON) is FALSE then
      put "Error, could not write file" & CR&CR & jsonPath into errorMsg
      return errorMsg
   else
      put _ModelPath (modelName) into modelPath
      return modelPath
   end if
end transport_SetModelJSON


--> Transport | AtopiaCat | Model
-
function transport_FetchAtopiaCatModel
   put federation_FetchModel ("Atopia Category Model") into atopiaCatModel
   return atopiaCatModel
end transport_FetchAtopiaCatModel

command transport_StoreAtopiaCatModel atopiaCatModel
   federation_StoreModel "Atopia Category Model", atopiaCatModel
   --
   put the result into modelPath
   return modelPath      
end transport_StoreAtopiaCatModel

command transport_PostAtopiaCatModel atopiaCatModel
   put "Atopia Category Model" into modelName
   put secret_Get ("TransportModel") into pWord
   --
   transport_PostProtectedModel atopiaCatModel, modelName, pWord
   --
   return the result
end transport_PostAtopiaCatModel

command transport_PostDeleteCatModelFromShortFile shortModelFile
   put secret_Get ("TransportModel") into postData ["secret"]
   put shortModelFile into postData ["modelName"]
   --
   put modelName into postData ["modelName"]
   --
   deleteShortModelFile
end transport_PostDeleteCatModelFromShortFile

command transport_StoreAtopiaCatModel atopiaCatModel
   federation_StoreModel "Atopia Category Model", atopiaCatModel
   put the result into modelPath
   return modelPath
end transport_StoreAtopiaCatModel


--> Transport | Model | Rest
-
function transport_FetchModelFromShortFile shortModelFile
   put transport_FetchModelTextFromShortFile (shortModelFile) into modelJSON
   put json_ToArray (modelJSON) into modelData
   return modelData
end transport_FetchModelFromShortFile

function transport_FetchModelTextFromShortFile shortModelFile
   put "https://rest.livecode.world/model/" & shortModelFile into modelURL
   put url modelURL into modelText
   return modelText
end transport_FetchModelTextFromShortFile

command transport_PostProtectedModel modelData, modelName, pWord
   put modelData into postData ["modelData"]
   put modelName into postData ["modelName"]
   put pWord into postData ["secret"]
   --
   put json_FromArray (postData) into postJSON
   -- put textDecode (postJSON, "UTF-8") into postJSON -- seems to cause an issue sometimes???
   --
   put jsonrpc_Post (postJSON, "https://rest.livecode.world/atopia/writeModel") into utf8Json
   put textEncode (utf8Json, "UTF-8") into rPageJson
   --
   put json_ToArray (rPageJson) into rPageArray
   return rPageArray
end transport_PostProtectedModel


--> Transport | Model | Files | List
-
function transport_ListModelFiles
   put _ModelFolder() into modelFolder
   put rig_ListFiles (modelFolder) into shortFiles
   return shortFiles
end transport_ListModelFiles


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
      put "/var/www/rest.livecode.world/" into modelFolder
   end if
   return modelFolder
end _DocumentRoot


--> Private
-
private function jsonrpc_POST someJSON, restUrl, pOAuthToken, pExtraHeaders, pVersionNum
   rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   post someJSON to url restUrl
   put it into jsonResult
   return jsonResult
end jsonrpc_POST

private function _LocalModelLocal modelName
   put _ModelPath (modelName) into modelPath
   put "file:" & modelPath into jsonURL
   return jsonURL
end _LocalModelLocal

function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get
