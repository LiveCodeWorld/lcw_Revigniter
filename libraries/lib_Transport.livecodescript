script "lib_Transport"
--> MetaData
-
license: GPLv3
name: lib_Transport
type: library
version: 0.3

/*
This library is for creating and manipulating Transporter wiki pages.
*/


--> Variables
-
constant PlatformRestDomain = "rest.livecode.wiki" -- "rest.livecode.world"


--> Working on
-
function platform_WikiDomain pSubDomain
   -- "livecode.world"
   constant PlatformWikiDomain = "livecode.wiki"
   if pSubDomain is empty then
      return PlatformWikiDomain
   else
      text_AddTrailing pSubDomain, "."
      return pSubDomain & PlatformWikiDomain
   end if
end platform_WikiDomain

function platform_RestUrl restBit
   put "http://" & PlatformRestDomain into restURL
   if restBit is not empty then
      put slash & restBit after restURL
   end if
   return restURL
end platform_RestUrl

function platform_RestDomain
   return PlatformRestDomain
end platform_RestDomain

function transport_ConstructHiddenArray wikiDomain, pageSlug, pPageTitle
   if pPageTitle is empty then
      put fedwiki_ConstructTitle(pageSlug) into pPageTitle
   end if
   put wikiDomain into hiddenArray ["wikiDomain"]
   put pageSlug into hiddenArray ["pageSlug"]
   put pPageTitle into hiddenArray ["pageTitle"]
   --
   return hiddenArray
end transport_ConstructHiddenArray

function transport_GetLibraryStacks tObject
   put the project_Name of tObject into projectName
   if projectName is not "lcw_Controllers" then return "Error, not a transporter"
   --
   put the dep_StackNames of tObject into stackNames
   put tObject into searchHierarchy
   repeat for each item stackName in stackNames
      if exists (stack stackName) is false then
         -- project not loaded
         breakpoint
         next repeat
      end if
      put CR & the name of stack stackName after searchHierarchy
   end repeat
   return searchHierarchy
end transport_GetLibraryStacks

function transport_CheckRosterAuthor wikiDomainToAdd
   -- put server_GetRemoteIP() into remoteIP
   return true
end transport_CheckRosterAuthor


--> Props
-
getprop transport_ObjectDepArray [whichSearch]
   put the transport_DepHkeyArray [whichSearch] of the target into hKeyArray
   put hkeyArray_GetStackDepArray (hkeyArray) into objectDepArray
   return objectDepArray
end transport_ObjectDepArray

getprop transport_DepHkeyArray [whichSearch]
   -- let's do a quick check that the "transport" stack is an uploaded revIgniter controller
   put the long id of the target into tObject
   put the project_Name of tObject into projectName
   if projectName is not "lcw_Controllers" then return "Error, not a transporter"
   --
   put revRuggedID (tObject) into tObject
   switch char 1 of whichSearch
      case "s" -- "server"
         put transport_ListServerLibraryStacks() into searchObjects
         break
      case "e" -- "environment"
         put env_ScriptHierarchy (true) into searchObjects
         break
      default
         -- the actual stacks specified by "the dep_StackNames" that will be loaded
         put transport_GetLibraryStacks (tObject) into searchObjects
   end switch
   --
   put walk_GetObjectHkeyArray (tObject, searchObjects, false) into hKeyArray
   return hKeyArray
end transport_DepHkeyArray

getprop transport_LibraryStacks
   -- the actual stacks that will be used when the transport controller is loaded
   put the long id of the target into tObject
   put the project_Name of tObject into projectName
   if projectName is not "lcw_Controllers" then return "Error, not a transporter"
   --
   put transport_GetLibraryStacks (tObject) into depStackObjects
   return depStackObjects
end transport_LibraryStacks


--> Roster | PageArray
-
function transport_FetchEmptyRosterPageArray rosterName, pTemplateWikiDomain
   if pTemplateWikiDomain is empty then put platform_RestDomain() into pTemplateWikiDomain
   --
   put fedwiki_ConstructSlug (rosterName) into rosterTemplateSlug
   put pageArray_Fetch (pTemplateWikiDomain, rosterTemplateSlug) into pageArray
   -- pageArray_CleanFork pageArray, pForkDomains
   --
   pageArray_SetRoster pageArray, empty, rosterName
   return pageArray
end transport_FetchEmptyRosterPageArray

function transport_FetchRosterPageArray rosterName, pWikiDomainToAdd, pTemplateWikiDomain
   if transport_CheckRosterAuthor (pWikiDomainToAdd) is false then
      return empty
   end if
   if pTemplateWikiDomain is empty then put platform_RestDomain() into pTemplateWikiDomain
   --
   put fedwiki_ConstructSlug (rosterName) into rosterTemplateSlug
   put pageArray_Fetch (pTemplateWikiDomain, rosterTemplateSlug) into pageArray
   if pageArray is empty then
      return empty
   else
      pageArray_AddToRoster pageArray, pWikiDomainToAdd
      return pageArray
   end if
end transport_FetchRosterPageArray

function transport_ConstructUpdatePageArray lastUpdatedSeconds, postArray
   -- "scrape-report.json"
   put "Scrape Report" into pageTitle
   put server_GetRemoteIP() into remoteIP
   put server_GetRemoteMethod() into sMethod
   --
   if lastUpdatedSeconds is empty then put the seconds into lastUpdatedSeconds
   convert lastUpdatedSeconds to internet date
   put postArray ["index"]["counts"] into scanNum
   if scanNum is empty then put "?" into scanNum
   put postArray ["index"]["sites"] into siteNum
   if siteNum is empty then put "an unknown number of" into siteNum
   put postArray ["index"]["slugs"] into slugNum
   put postArray ["scan"]["pages"] into scanPageNum
   put postArray ["scan"]["sites"] into scanSiteNum
   --
   put merge ("Thanks for update [[scanNum]] on [[lastUpdatedSeconds]]. That makes [[siteNum]] sites indexed to date.") into someMarkdown
   put pageArray_Construct (pageTitle, someMarkdown) into pageArray
   --
   put merge ("We received a [[sMethod]] event from the following ip address:") into someMarkdown
   pageArray_AddMarkdown pageArray, someMarkdown
   pageArray_AddCode pageArray, remoteIP
   --
   pageArray_AddMarkdown pageArray, "We received the following webhook $_POST_RAW:"
   put sMethod & ":" && $_POST_RAW into postMarkDown
   pageArray_AddMarkdown responseArray, postMarkDown
   --
   pageArray_AddMarkdown responseArray, "Here is the raw data we received from the webhook:"
   pageArray_AddMarkdown pageArray, $_POST_RAW
   --
   pageArray_AddMarkdown pageArray, "We will return more useful data here at a later date."
   return pageArray
end transport_ConstructUpdatePageArray


--> Server
-
function server_GetRemoteMethod
   -- REQUEST_METHOD POST
   put $_SERVER ["REQUEST_METHOD"] into remoteMethod
   return remoteMethod
end server_GetRemoteMethod

function server_GetRemoteIP
   -- REMOTE_ADDR 92.237.8.154
   put $_SERVER ["REMOTE_ADDR"] into remoteIP
   return remoteIP
end server_GetRemoteIP

function server_GetRemotePort
   -- REMOTE_PORT 50713
   put $_SERVER ["REMOTE_PORT"] into remotePort
   return remotePort
end server_GetRemotePort

function server_GetRequestMethod
   -- REQUEST_METHOD POST
   put $_SERVER ["REQUEST_METHOD"] into requestMethod
   return requestMethod
end server_GetRequestMethod

function server_GetDocumentRoot
   put $_SERVER ["DOCUMENT_ROOT"] into docROOT
   return docROOT
end server_GetDocumentRoot

function server_GetCgiPath shortFile
   put $_SERVER ["PATH_TRANSLATED"] into pathTranslated
   --
   set the itemdelimiter to slash
   put pathTranslated into textPath
   put shortFile into item -1 of textPath
   --
   return textPath
end server_GetCgiPath


--> Transport | File | Write
-
command transport_CopyWikiPage pageTitle, wikiDomain, pNewTitle, pForkDomains
   -- transport_CopyWikiPage "Register Sites Template", "roster.fedwiki.org"
   put pageArray_FetchByTitle (wikiDomain, pageTitle) into pageArray
   pageArray_Rename pageArray, pNewTitle, pForkDomains
   --
   transport_StorePageArray pageArray
   put the result into jsonPath
   return jsonPath
end transport_CopyWikiPage

command transport_StorePageArray pageArray, pWikiDomain
   -- Should use a password
   put pageArray ["title"] into pageTitle
   if pageTitle is empty then
      -- don't write if the array is not a pageArray
      return empty
   end if
   
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   put pageSlug & ".json" into  shortFile
   --
   put json_FromArray (pageArray) into pageJSON
   transport_WriteFile shortFile, pageJSON, pWikiDomain
   put the result into jsonPath
   return jsonPath
end transport_StorePageArray

command transport_WriteFile shortFile, someText
   rigLoadHelper "file"
   --
   put transport_GetJsonPath (shortFile) into jsonPath
   --
   put "./" & shortFile into relativeFile
   if rigWriteFile (relativeFile, someText) is FALSE then
      put "Error, could not write file" & CR&CR & jsonPath into errorMsg
      return errorMsg
   else
      return jsonPath
   end if
   
   /*
   -- non rigLoadHelper version
   put transport_GetJsonPath (shortFile, pWikiDomain) into jsonPath
   put pageJSON into url ("file:" & jsonPath)
   put the result into tResult
   if tResult is empty then
      return jsonPath
   else
      put "Error," && tResult & CR&CR & jsonPath into errorMsg
      return errorMsg
   end if
   */
end transport_WriteFile

function transport_GetJsonPath shortFile
   put server_GetDocumentRoot() into jsonPath
   put slash & shortFile after jsonPath
   return jsonPath
end transport_GetJsonPath


--> Transport | Form
-
function transport_GetFormValue someKey
   put transport_GetDroppedArray() into postArray
   put postArray [someKey] into someValue
   return someValue
end transport_GetFormValue

function transport_FetchFormPageArray
   transport_SetFormSlugDomain wikiDomain, pageSlug
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   return pageArray
end transport_FetchFormPageArray

command transport_SetFormTitleDomain @wikiDomain, @pageTitle
   put transport_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiDomain
   end if
   put postArray ["pageTitle"] into pageTitle
   return postArray
end transport_SetFormTitleDomain

command transport_SetFormSlugDomain @wikiDomain, @pageSlug
   put transport_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiDomain
   end if
   put postArray ["pageSlug"] into pageSlug
   return postArray
end transport_SetFormSlugDomain

function transport_GetFormDomain 
   put transport_GetFormValue ("wikiDomain") into wikiDomain
   if wikiDomain is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiDomain
   end if
   return wikiDomain
end transport_GetFormDomain

function transport_ListHandlers pShortFile
   if pShortFile is empty then put display_GetSelectedTransport() into pShortFile
   if exists (stack pShortFile) is false then return empty
   --
   put the name of stack pShortFile into transportStack
   --
   put the rig_ControllerHandlers of transportStack into hNames
   replace comma with CR in hNames
   return hNames
end transport_ListHandlers


--> Transport
-
command transport_Upload tObject
   put the project_Name of tObject into projectName
   if projectName is not "lcw_Controllers" then return "Error, not a transporter"
   --
   put the stack_Name of tObject into shortControllerFile
   put the dep_StackNames of tObject into depStackNames
   put the script_Help of tObject into scriptDescription
   --
   put stack_ConvertNamesToShortPaths (depStackNames, badNames) into depShortPaths
   put rig_ConstructControllerScript (tObject, shortControllerFile, depShortPaths, scriptDescription) into rigScript
   rig_StoreController shortControllerFile, rigScript
   put the result into shellResult
   return shellResult
end transport_Upload

function transport_ListServerLibraryStacks
   put transport_FetchLibraryStackArray() into resultArray
   put the keys of resultArray ["known"] into stackObjects
   sort stackObjects
   return stackObjects
end transport_ListServerLibraryStacks

function transport_FetchLibraryStackArray
   put rig_ListStackFiles() into shortStackFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortStackFiles
      set the cursor to busy
      put item 1 of shortFile into stackName
      if exists (stack stackName) then
         put the name of stack stackName into stackObject
         put stackName into resultArray ["known"][stackObject]
      else
         put stackName into resultArray ["missing"][stackName]
      end if
   end repeat
   return resultArray
end transport_FetchLibraryStackArray

function transport_ListLibraryStackNames
   -- assumes short file is named same as stack name
   put rig_ListStackFiles() into shortStackFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortStackFiles
      put item 1 of shortFile into stackName
      put stackName & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return stackNames
end transport_ListLibraryStackNames

function transporter_GetRawJSON displayHow
   switch displayHow
      case "Stored Json"
         put the selectedtext of _fieldObject() into jsonName
         put dropped_GetJson (jsonName) into dropJSON
         break
      default
         put transport_GetMockRawJson() into droppedURL
         put transporter_ConstructDroppedJSON (droppedURL) into dropJSON
   end switch
   return dropJSON
end transporter_GetRawJSON

function transport_GetMockRawJson
   put display_FindView ("Transporter", "Dropped URL's") into displayView
   if exists (displayView) is true then
      put the selected_Value of displayView into droppedURL
      put transporter_ConstructDroppedJSON (droppedURL) into rawJSON
   else
      -- breakpoint
      -- put the transporter_RawJSON of stack "Transporter Drop Urls" into rawJSON
      put empty into rawJSON
   end if
   return rawJSON
end transport_GetMockRawJson

function transporter_ConstructDroppedJSON droppedURL
   -- {"text":"https://media.ccc.de/v/32c3-7403-a_new_kid_on_the_block#video","html":""}
   put droppedURL into dropArray ["text"]
   put droppedURL into dropArray ["url"]
   put empty into dropArray ["html"]
   put json_FromArray (dropArray) into someJSON
   return someJSON
end transporter_ConstructDroppedJSON


--> Transport | Check
-
command transporter_CreateGraph hObject, pDisplayGraphs, pForceReIndex
   put the behavior of hObject into oBehavior
   set the behavior of hObject to empty
   put the long id of me into processObject
   --
   put transport_GetLibraryStacks (hObject) into searchHierarchy
   put the rig_ControllerHkeys of hObject into hKeys
   repeat for each line hkey in hKeys
      set the cursor to busy
      put transport_GraphIsNew (hKey) is false into graphIsOld
      put pForceReIndex is true OR graphIsOld into graphAgain
      if graphAgain then
         if pDisplayGraphs is true then
            display_ClusterDepGraph hkey, searchHierarchy, true, processObject
         else
            graph_HkeyCreateCluster hkey, searchHierarchy, true, processObject
         end if  
      end if
   end repeat
   set the behavior of hObject to oBehavior
   return hKeys
end transporter_CreateGraph

command transporter_CreateHkeyGraph hKey
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
   put transport_GetLibraryStacks (hObject) into searchHierarchy
   --
   put the behavior of hObject into oBehavior
   set the behavior of hObject to empty
   display_ClusterDepGraph hkey, searchHierarchy, true
   set the behavior of hObject to oBehavior
end transporter_CreateHkeyGraph

function transport_GraphIsNew hKey
   put hkey_IsTransportHandler (hKey) into isTransporter
   if isTransporter is false then return empty
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put overlay_GetHkeyHash (hKey) into oHash
   put the mainstack_Hash of hObject into mHash
   if oHash = mHash then
      return true
   else
      return false
   end if
end transport_GraphIsNew

function transport_ShortFileDeps hObject
   local allDepShortFiles
   put the rig_ControllerHkeys of hObject into hKeys
   repeat for each line hKey in hKeys
      put transport_HkeyShortFileDeps (hKey) into depShortFiles
      line_Add depShortFiles, allDepShortFiles
   end repeat
   return allDepShortFiles
end transport_ShortFileDeps

function transport_HkeyShortFileDeps hKey
   put deps_HkeyStackNames (hKey) into stackNames
   put stack_ConvertNamesToShortPaths (stackNames, badObjects) into depShortFiles
   sort depShortFiles
   return depShortFiles
end transport_HkeyShortFileDeps

command transport_UpdatePageGraph @pageArray, hKey
   put hkey_DotFile (hKey) into dotFile
   put url ("file:" & dotFile) into dotText
   --
   put pageArray_FindItemType ("graphviz", pageArray) into itemNum
   if itemNum > 0 then
      put dotText into pageArray ["story"][itemNum]["text"]
   end if
end transport_UpdatePageGraph
