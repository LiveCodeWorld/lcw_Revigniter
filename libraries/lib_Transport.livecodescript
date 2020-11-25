script "lib_Transport"
--> MetaData
-
license: GPLv3
name: lib_Transport
type: library
version: 0.2

/*
This library is for creating and manipulating Transporter wiki pages.
*/


--> Working on
-
function transport_FetchFormPageArray
   transport_SetFormSlugDomain wikiDomain, pageSlug
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   return pageArray
end transport_FetchFormPageArray

command transport_SetFormSlugDomain @wikiDomain, @pageSlug
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiDomain
   end if
   put postArray ["pageSlug"] into pageSlug
   return postArray
end transport_SetFormSlugDomain

function transport_GetFormDomain 
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["wikiDomain"] into wikiDomain
   if wikiDomain is empty then
      set the itemdelimiter to slash
      put item 3 of $HTTP_REFERER into wikiDomain
   end if
   return wikiDomain
end transport_GetFormDomain

function transport_ListHandlers pShortFile
   if pShortFile is empty then put display_GetSelectedTransport() into pShortFile
   put the name of stack pShortFile into transportStack
   --
   put the rig_ControllerHandlers of transportStack into hNames
   replace comma with CR in hNames
   return hNames
end transport_ListHandlers


--> Props
-
getprop transport_ObjectDepArray [whichSearch]
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
   put the rig_ControllerHkeys of tObject into hKeys
   --
   put walk_GetObjectHkeyArray (tObject, searchObjects, false) into hKeyArray
   put hkeyArray_GetDepArray (hkeyArray) into objectDepArray
   --
   return objectDepArray
end transport_ObjectDepArray

getprop transport_LibraryStacks
   -- the actual stacks that will be used when the transport controller is loaded
   put the long id of the target into tObject
   put the project_Name of tObject into projectName
   if projectName is not "lcw_Controllers" then return "Error, not a transporter"
   --
   put transport_GetLibraryStacks (tObject) into depStackObjects
   return depStackObjects
end transport_LibraryStacks


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

command transport_FindUpdateObjectDepArray @objectDepArray, searchObjects
   put objectDepArray ["Missing"] into missingArray
   delete variable objectDepArray ["Missing"]
   --
   put the keys of missingArray into missingShortHkeys
   replace " of Missing" with empty in missingShortHkeys
   --
   put transport_FindMissingObjectDepArray (missingShortHkeys, searchObjects) into foundMissingObjectDepArray
   union objectDepArray with foundMissingObjectDepArray recursively
   --
   return foundMissingObjectDepArray
end transport_FindUpdateObjectDepArray

function transport_FindMissingObjectDepArray missingShortHkeys, searchObjects 
   -- _FilterReviniter missingShortHkeys
   -- put the result into missingRigHkeys
   
   -- lets find all the missingHkeys
   repeat for each line missingShortHkey in missingShortHkeys
      if char 1 to 3 of word 2 of missingShortHkey = "rig" then
         put empty into foundMissingHkeyArray ["revIgniter"][missingShortHkey]
         next repeat
      end if
      
      put hkey_PublicFind (missingShortHkey, searchObjects) into foundMissingHkey
      switch
         case foundMissingHkey is empty
            put "Still Missing" into cantFindArray [missingShortHkey]
            break
         default
            put empty into foundMissingHkeyObjectArray ["found"][foundMissingHkey]
      end switch
   end repeat
   put the keys of foundMissingHkeyObjectArray ["found"] into foundMissingHkeys
   
   -- now lets recursively find the dependencies of each of the foundHkeys
   put hkey_SearchHierarchyDependencyArray (foundMissingHkeys, searchObjects, true) into stillMissingHKeyArray
   put hkeyArray_GetDepArray (stillMissingHKeyArray) into stillMissingObjectDepArray 
   --
   put stillMissingObjectDepArray ["Missing"] into foundStillMissingHkeyArray
   union foundStillMissingHkeyArray with cantFindArray
   put the keys of foundStillMissingHkeyArray into foundStillMissingHkeys
   --
   _FilterReviniter foundStillMissingHkeys
   put the result into stillMissingRigHkeys
   --
   -- split missingRigHkeys by CR as set
   put foundMissingHkeyArray ["revIgniter"] into missingRigHkeys
   split stillMissingRigHkeys by CR as set
   union missingRigHkeys with stillMissingRigHkeys
   --
   if the keys of missingRigHkeys is not empty then
      put missingRigHkeys into stillMissingObjectDepArray ["revIgniter"]
   end if
   --
   if foundStillMissingHkeys is not empty then
      split foundStillMissingHkeys by CR as set
      put foundStillMissingHkeys into stillMissingObjectDepArray ["Missing"]
   end if
   --
   return stillMissingObjectDepArray
end transport_FindMissingObjectDepArray

function transport_GetLibraryStacks tObject
   put the project_Name of tObject into projectName
   if projectName is not "lcw_Controllers" then return "Error, not a transporter"
   --
   put the dep_StackNames of tObject into stackNames
   put tObject into searchHierarchy
   repeat for each item stackName in stackNames
      if exists (stack stackName) is false then
         breakpoint
         next repeat
      end if
      put CR & the name of stack stackName after searchHierarchy
   end repeat
   return searchHierarchy
end transport_GetLibraryStacks

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
function transport_ListMissingHkeys sObject
   transport_CollectCalls sObject, callObjectArray, missingArray, revIgniterArray
   put keys (missingArray) into mKeys
   repeat for each line mKey in mKeys
      put word 1 to 2 of mKey into shortMissing
      put shortMissing & CR after missingHkeys
   end repeat
   delete char -1 of missingHkeys
   return missingHkeys
end transport_ListMissingHkeys

command transport_CollectCalls sObject, @callObjectArray, @missingArray, @revIgniterArray
   put the rig_ControllerHkeys of sObject into hKeys
   repeat for each line hKey in hKeys
      put hkey_GetLinkArray (hKey) into hkeyLinkArray
      hkeyArray_SetObjectArray callObjectArray, hkeyLinkArray
   end repeat
   
   put revRuggedID (sObject) into sObject
   delete variable callObjectArray [sObject]
   put callObjectArray ["Missing"] into missingArray
   delete variable callObjectArray ["Missing"]
   put callObjectArray ["revIgniter"] into revIgniterArray
   delete variable callObjectArray ["revIgniter"]
   put keys (callObjectArray) into depStacks
   return depStacks
end transport_CollectCalls

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


--> Tranport | Help
-
command transport_CreateHelp hKey, pScriptHelp
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   if the result = "index" then
      put _TransportHkeyCurlyData (hKey) into curlyData
      help_Create pageTitle, "transport", curlyData, pScriptHelp
   else
      -- updates "Welcome Visitors" every time! Could check.
      transport_CreateRouteWelcomeHelp hKey
      transport_CreateRouteHelp hKey
   end if
   put the result into shellResult
   return shellResult
end transport_CreateHelp

command transport_CreateRouteWelcomeHelp routeHkey
   hkey_Normalize routeHkey
   put routeHkey into indexHkey
   put "index" into word 2 of indexHkey
   _TransportInfo indexHkey, indexDomain, indexTitle, indexSlug, iObject   
   _TransportInfo routeHkey, rootDomain, routeTitle, routeSlug, rObject
   
   -- check Welcome-visitors for subdomain
   put transport_FetchPageArray (indexHkey) into pageArray
   switch
      case pageArray is empty
         breakpoint -- Welcome-visitors for subdomain does not exist. Let's create it
         break
      case pageArray ["title"] is not indexTitle
         breakpoint -- 
         
         help_Create indexTitle, "transport", curlyData, pScriptHelp
         put the result into pageArray
         if pageArray is not an array then
            breakpoint
            return empty
         end if
         
         pageArray_Rename pageArray, "Welcome Visitors"
         pageArray_StripJournal pageArray
         pageArray_AddFork pageArray, "transport.livecode.world,handler.livecode.world,library.livecode.world,model.livecode.world,fedwiki.org"
         break
      default
         breakpoint -- Welcome-visitors for subdomain already exists so let's update metadata
         
         put pageArray_Fetch (rootDomain, "welcome-visitors") into pageArray -- get old subpage welcome
         put _TransportHkeyCurlyData (indexHkey) into curlyData -- update with latest index.lc metadata
         curly_MergePageArray pageArray, curlyData
   end switch
   --
   pageArray_Store rootDomain, "welcome-visitors", pageArray
   return pageArray
end transport_CreateRouteWelcomeHelp

command transport_CreateRouteHelp hKey
   put _TransportHkeyCurlyData (hKey) into curlyData
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   --
   put pageArray_Fetch ("transport.livecode.world", "transport-route-template") into pageArray
   pageArray_Rename pageArray, pageTitle
   --
   curly_MergePageArray pageArray, curlyData
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "transport.livecode.world,handler.livecode.world,library.livecode.world,model.livecode.world,fedwiki.org"
   --
   pageArray_Store wikiDomain, pageSlug, pageArray
   put the result into shellResult
   return shellResult
end transport_CreateRouteHelp

command transport_UpdateHelp hKey
   put transport_FetchPageArray (hKey) into pageArray
   put _TransportHkeyCurlyData (hKey) into curlyData
   curly_MergePageArray pageArray, curlyData
   transport_StorePageArray hKey, pageArray
end transport_UpdateHelp

function transport_HelpURL hKey, pCheckURL
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   if pCheckURL is true then
      put fedwiki_IsWikiPage (wikiDomain, pageSlug) into isWiki
      if isWiki is false then
         return empty
      end if
   end if
   put fedwiki_ConstructUrlFromSlug (wikiDomain, pageSlug) into someURL
   return someURL
end transport_HelpURL

function transport_IndexHkey hObject
   put hKeyLine_Construct ("index", "c", hObject) into hKey
   return hKey
end transport_IndexHkey

function transport_IndexDotText hObject
   put transport_IndexHkey (hObject) into hKey
   put hkey_GetDotText (hKey) into dotText
   return dotText   
end transport_IndexDotText


--> Transport | Model
-
function transport_FetchPageArray hKey
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   return pageArray
end transport_FetchPageArray

command transport_StorePageArray hKey, pageArray
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   pageArray_Store wikiDomain, pageSlug, pageArray
   put the result into shellResult
   return shellResult
end transport_StorePageArray


--> Private
-
private command _FilterReviniter @stillMissingHkeys
   put stillMissingHkeys into revIgniterHkeys
   filter revIgniterHkeys with "* rig*"
   filter stillMissingHkeys without "* rig*"
   return revIgniterHkeys
end _FilterReviniter

function _OldRawJson displayHow
   switch displayHow
      case "Stored Json"
         put the transporter_RawJSON of _fieldObject() into dropJSON
         put test_ExtractDroppedUrl (dropJSON) into droppedURL
         return droppedURL
      default
         put the selectedtext of _fieldObject() into droppedURL
         return droppedURL
   end switch
end _OldRawJson

private function _TransportHkeyCurlyData hKey
   put help_HkeyCurlyData (hKey) into curlyData
   --
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   put the result into hName
   put hName into curlyData ["all"]["hName"]
   put pageTitle into curlyData ["all"]["transportName"]
   --
   _SetTransportMetadata curlyData, hKey
   _SetCurlyRestURL curlyData, hObject, hName
   _SetCurlyTransportRoutes curlyData, hObject
   _SetTransportWhere curlyData, hKey
   --
   return curlyData
end _TransportHkeyCurlyData

private command _SetTransportWhere @curlyData, hKey
   _TransportInfo hKey, wikiDomain, pageTitle, pageSlug, hObject
   put storyArray_ConstructReference (pageSlug, wikiDomain, wikiDomain, pageTitle) into itemArray
   curly_SetReplaceArray curlyData, itemArray, "4ecda1442570d900"
end _SetTransportWhere

private function _TransportObjectCurlyData sObject
   put the github_HandlerURL [shortHkey] of sObject && "github" into githubLink
   put githubLink into curlyData ["all"]["github link"]
   --
   _SetCurlyRestURL curlyData, sObject
   --
   put the dep_StackNames of sObject into depStackNames
   put fedwiki_MarkdownIndex (depStackNames) into curlyData ["all"]["Deps List"]
   --
   put transport_IndexDotText (hObject) into dotText
   --
   return curlyData
end _TransportObjectCurlyData

private command _SetTransportMetadata @curlyData, hKey
   put hkey_GetType (hKey) into handlerType
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the github_RelativePath of hObject into relPath
   --
   put "Type: transport" & CR after handlerMetaData
   put "Project:" && the project_Name of hObject & CR after handlerMetaData
   put "Github:" && relPath & CR after handlerMetaData
   delete char -1 of handlerMetaData
   --
   put handlerMetaData into curlyData ["id"]["da8cf69872f38050"]
end _SetTransportMetadata

private command _SetCurlyTransportRoutes @curlyData, sObject
   put the rig_ControllerHandlers of sObject into handlerNames
   replace comma with CR in handlerNames
   line_Delete "index", handlerNames
   if handlerNames is not empty then
      put fedwiki_MarkdownIndex (handlerNames) into curlyData ["id"]["642e249b4a7faa02"]
   end if
end _SetCurlyTransportRoutes

private command _SetCurlyRestURL @curlyData, sObject, hName
   put the stack_Name of sObject into stackName
   set the itemdelimiter to "."
   put item 1 of stackName into shortFile
   put "https://rest.livecode.world/" & shortFile into restURL
   if hName is not "index" then
      put slash & hName after restURL
   end if
   put "POST" && restURL into curlyData ["id"]["10ea2af363e51a5f"]
   put restURL into curlyData ["all"]["restURL"]
end _SetCurlyRestURL

private command _TransportInfo hKey, @wikiDomain, @pageTitle, @pageSlug, @hObject
   put "transport.livecode.world" into wikiDomain
   --
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the stack_Name of hObject into stackName
   --
   if hName = "index" then
      put help_ConstructTransportTitle (stackName) into pageTitle
   else
      set the itemdelimiter to "."
      put hName into pageTitle
      put item 1 of stackName into subdomain
      put tolower (subdomain) & "." before wikiDomain
   end if
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   return hName
end _TransportInfo
