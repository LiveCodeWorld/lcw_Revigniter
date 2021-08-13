script "model_Transport"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Transport
type: model
version: 0.1


--> Working on
-
function jwt_ConstructToken userName
   put the seconds into tIAT
   put tIAT + 10 into tNBF
   put tIAT + 60 into tEXP
   
   put "jwt test" into tJWTpayloadA ["sub"]
   put userName into tJWTpayloadA ["name"]
   put "true" into tJWTpayloadA ["admin"]
   
   # NOTE: SECONDS NEED TO BE A STRING, OTHERWISE THE DATA OF JSONEXPORT IS NOT VALID.
   put tIAT & "" into tJWTpayloadA ["iat"]
   put tNBF & "" into tJWTpayloadA ["nbf"]
   put tEXP & "" into tJWTpayloadA ["exp"]
   put uuid() into tJWTpayloadA ["jti"]
   
   put rigJWTencode( , tJWTpayloadA) into tJWT
   return tJWT
end jwt_ConstructToken

function transport_FetchAtopiaCatModel
   put "Atopia Category Model" into modelName
   put transport_FetchModel (modelName) into atopiaCatModel
   return atopiaCatModel
end transport_FetchAtopiaCatModel

command transport_StoreAtopiaCatModel atopiaCatModel
   transport_WriteModel "Atopia Category Model", atopiaCatModel
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

command transport_PostDeleteShortModelFile shortModelFile
   put shortModelFile into postData ["shortModelFile"]
   put _GetPostTransportModel (postData) into rPageArray
   return rPageArray
end transport_PostDeleteShortModelFile

command transport_PostDeleteModel modelName
   put modelName into postData ["modelName"]
   put _GetPostTransportModel (postData) into rPageArray
   return rPageArray
end transport_PostDeleteModel

command transport_StoreAtopiaCatModel atopiaCatModel
   transport_WriteModel "Atopia Category Model", atopiaCatModel
   put the result into modelPath
   return modelPath
end transport_StoreAtopiaCatModel


--> Transport | Model | Rest
-
command transport_WriteModelPostData postData, storedSecret
   put postData ["secret"] into someSecret
   --
   if someSecret is storedSecret then 
      -- put rigFetchSegment (3, "Atopia Model") into modelName
      put postData ["modelName"] into modelName
      put postData ["modelData"] into modelData
      --
      transport_WriteModel modelName, modelData
      put the result into jsonPath
      --
      put pageArray_Construct ("writeModel", jsonPath) into rPageArray
   else
      put pageArray_Construct ("Error", "Not authenticated") into rPageArray
   end if
   return rPageArray
end transport_WriteModelPostData


--> Transport | Model | Rest
-
function transport_FetchModel modelName
   put transport_ConstructModelShortFile (modelName) into shortModelFile
   put transport_FetchModelFromShortFile (shortModelFile) into modelData
   return modelData
end transport_FetchModel

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
   put jsonrpc_Post (postJSON, "https://rest.livecode.world/atopia/writeModel") into rPageJson
   --
   put json_ToArray [rPageJson] into rPageArray
   return rPageArray
end transport_PostProtectedModel


--> Transport | Model | Write
-
command transport_WriteModel modelName, modelData
   put json_FromArray (modelData) into modelJSON
   transport_WriteModelJSON modelName, modelJSON
   put the result into modelPath
   return modelPath
end transport_WriteModel

command transport_DeleteModel modelName
   put transport_GetModelPath (modelName) into modelPath
   delete file modelPath
   if the result is empty then
      return modelPath
   else
      put "Error," && the result & CR&CR & modelPath into errorMsg
      return errorMsg
   end if
end transport_DeleteModel

command transport_DeleteShortModelFile shortModelFile
   put transport_GetModelFolder() into modelFolder
   put modelFolder & shortModelFile into modelPath
   --
   delete file modelPath
   if the result is empty then
      return modelPath
   else
      put "Error," && the result & CR&CR & modelPath into errorMsg
      return errorMsg
   end if
end transport_DeleteShortModelFile

command transport_WriteModelJSON modelName, modelJSON
   rigLoadHelper "file"
   --
   put transport_ConstructModelShortFile (modelName) into shortFile
   put "./model/" & shortFile into relativeFile
   if rigWriteFile (relativeFile, modelJSON) is FALSE then
      put "Error, could not write file" & CR&CR & jsonPath into errorMsg
      return errorMsg
   else
      put transport_GetModelPath (modelName) into modelPath
      return modelPath
   end if
end transport_WriteModelJSON


--> Transport | Model | Files | List
-
function transport_ListModelFiles
   put transport_GetModelFolder() into modelFolder
   put rig_ListFiles (modelFolder) into shortFiles
   return shortFiles
end transport_ListModelFiles


--> Transport | Model | Files
-
function transport_ConstructModelShortFile modelName
   put fedwiki_ConstructSlug (modelName) into modelSlug
   put modelSlug & ".json" into shortFile
   return shortFile
end transport_ConstructModelShortFile

function transport_GetModelPath modelName
   put transport_ConstructModelShortFile (modelName) into shortFile
   put transport_GetModelFolder() into modelFolder
   put modelFolder & shortFile into modelPath
   return modelPath
end transport_GetModelPath

function transport_GetModelFolder
   put transport_GetDocumentRoot() into modelFolder
   put "model/" after modelFolder
   return modelFolder
end transport_GetModelFolder

function transport_GetDocumentRoot
   if the environment is "server" then
      -- put server_GetDocumentRoot() & slash into modelFolder
      put $_SERVER ["DOCUMENT_ROOT"] into modelFolder
   else
      put "/var/www/rest.livecode.world/" into modelFolder
   end if
   return modelFolder
end transport_GetDocumentRoot


--> Private
-
function _GetPostTransportModel postData
   put secret_Get ("TransportModel") into pWord
   put pWord into postData ["secret"]
   --
   put json_FromArray (postData) into postJSON
   put jsonrpc_Post (postJSON, "https://rest.livecode.world/atopia/deleteShortModelFile") into rPageJson
   --
   put json_ToArray (rPageJson) into rPageArray
   return rPageArray
end _GetPostTransportModel
