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


--> Fedserver | Model
-
/*
Federation server models are stored on pages named "ServerName Model" on the wiki "server.fedwiki.org"

Each server model has the following structure:

- federationServerArray ["domains"] = fedray
- federationServerArray ["pageNum"]
- federationServerArray ["ipAddress"]
- federationServerArray ["domainNum"]

of which "fedray" is the most important
*/

function fedserver_FetchModel serverName
   put _ConstructServerPageSlug (serverName) into pSlug
   --
   put fedwiki_FetchPluginJSON (pSlug, "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into fedserverModel
   if fedserverModel is false then return empty
   return fedserverModel
end fedserver_FetchModel

command fedserver_StoreModel serverName, fedserverModel
   put _ConstructServerPageSlug (serverName) into pSlug
   --
   put json_FromArray (fedserverModel) into someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pSlug, "server.fedwiki.org", apiKey
   put the result into putError
   return putError
end fedserver_StoreModel


--> Fedray | Model | List
-
/*
Federation models are wiki pages on "roster.fedwiki.org" named "[[ModelName]] Model"
The wiki pages contain a json plugin which stored the model 
*/

constant FedModelDomain = "roster.fedwiki.org"

function federation_ModelDomain
   return FedModelDomain
end federation_ModelDomain

function federation_ModelExists modelTitle
   put federation_ListModels() into modelTitles
   set the wholematches to true
   put modelTitle is among the lines of modelTitles into modelExists
   return modelExists
end federation_ModelExists

command federation_Launch modelTitle
   put federation_ModelDomain() into modelDomain
   fedwiki_Launch modelDomain, modelTitle
   return the result
end federation_Launch

function federation_ListModels
   put fedwiki_ListSitemapPages (FedModelDomain) into pageTitles
   filter pageTitles with "* Model"
   return pageTitles
end federation_ListModels

command federation_CreateModelPage modelTitle
   if federation_ModelExists (modelTitle) then
      return merge ("Error, model '[[modelTitle]]' already exists. Delete first if you want to create it anew.")
   end if
   
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   put empty into forkDomains
   --
   put pageArray_FetchTemplate (FedModelDomain, "Model Template", modelTitle, forkDomains) into pageArray
   pageArray_Store FedModelDomain, pageSlug, pageArray
   --
   return pageArray
end federation_CreateModelPage

command federation_DeleteModelPage modelTitle
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   pageArray_Delete FedModelDomain, pageSlug
   return the result
end federation_DeleteModelPage


--> Fedray | Model
-
function federation_FetchModel modelName
   put transport_FetchModel (modelName) into fedray
   return fedray
   
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   put fedwiki_FetchPluginData (pageSlug, FedModelDomain) into fedray
   if fedray is false then return empty
   return fedray
end federation_FetchModel

command federation_StoreModel modelName, fedray
   transport_StoreModel modelName, modelData
   return the result
   
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   -- put atopia_GetJsonSecret() into apiKey
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   put json_FromArray (fedray) into someJSON
   fedwiki_PutPluginJSON someJSON, pageSlug, FedModelDomain, apiKey
   put the result into putError
   return putError
end federation_StoreModel

function transport_FetchModel modelName
   if the environment = "development" then
      -- this would work on the server as well
      put transport_ConstructModelShortFile (modelName) into shortModelFile
      put transport_FetchModelFromShortFile (shortModelFile) into modelData
   else
      put transport_GetModel (modelName) into modelData
   end if
   return modelData
end transport_FetchModel

command transport_StoreModel modelName, modelData
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
end transport_StoreModel


--> Atopia | DomainArray | Model
-
function atopia_FetchDomainArray
   put transport_FetchModel ("Atopia Domain Array") into atopiaFedray
   return atopiaFedray
   
   /*
   -- also "fedserver_FetchFedray" of model_FedServer
   put fedwiki_FetchPluginJSON ("atopia-domain-index", "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into atopiaFedray
   if atopiaFedray is false then return empty
   return atopiaFedray
   */
end atopia_FetchDomainArray

command atopia_StoreDomainArray atopiaFedray
   if atopiaFedray is not an array then return "Error, atopiaFedray is not an array. Delete instead?"
   --
   transport_StoreModel "Atopia Domain Array", atopiaFedray
   
   /*
   put json_FromArray (atopiaFedray) into someJSON
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   fedwiki_PutPluginJSON someJSON, "atopia-domain-index", "server.fedwiki.org", apiKey
   */
   
   put the result into writeError
   return writeError
end atopia_StoreDomainArray


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
   put transport_ConstructModelShortFile (modelName) into shortFile
   put "./model/" & shortFile into relativeFile
   
   # Write encodedJSON
   if rigWriteFile (relativeFile, encodedJSON) is FALSE then
      put "Error, could not write file" & CR&CR & jsonPath into errorMsg
      return errorMsg
   else
      put transport_GetModelPath (modelName) into modelPath
      return modelPath
   end if
end transport_SetModelJSON

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


--> Transport | AtopiaCat | Model
-
function transport_FetchAtopiaCatModel
   put transport_FetchModel ("Atopia Category Model") into atopiaCatModel
   return atopiaCatModel
end transport_FetchAtopiaCatModel

command transport_StoreAtopiaCatModel atopiaCatModel
   transport_StoreModel "Atopia Category Model", atopiaCatModel
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
   transport_StoreModel "Atopia Category Model", atopiaCatModel
   put the result into modelPath
   return modelPath
end transport_StoreAtopiaCatModel

-- command transport_WriteModelPostData postData, storedSecret
put postData ["secret"] into someSecret
--
if someSecret is storedSecret then 
   -- put rigFetchSegment (3, "Atopia Model") into modelName
   put postData ["modelName"] into modelName
   put postData ["modelData"] into modelData
   --
   transport_SetModel modelName, modelData
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
   put textDecode (postJSON, "UTF-8") into postJSON
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
      put $_SERVER ["DOCUMENT_ROOT"] & slash into modelFolder
   else
      put "/var/www/rest.livecode.world/" into modelFolder
   end if
   return modelFolder
end transport_GetDocumentRoot


--> Private
-
private function _LocalModelLocal modelName
   put transport_GetModelPath (modelName) into modelPath
   put "file:" & modelPath into jsonURL
   return jsonURL
end _LocalModelLocal

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
