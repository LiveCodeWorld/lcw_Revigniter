script "behavior_RigLocalOveride"
--> MetaData
-
license: GPLv3
name: behavior_RigLocalOveride
type: behavior
version: 0.2

/*
This library is for debuging purposes.

It allows easy exploration of Revigniter controllers.
When the behavior of stack "Temp Revigniter Controllers" is set to this stack these handlers will intercept the relevant calls.

Moving from behavior to frontscript. Not sure yet which to use.
There is an issue with using a frontscript which involves saving teh stacks to the server.
Stacks with behaviors set can make the server complain it cannot find the stack.
Front scritps would not have this issue.

See also older stack "behavior_FedwikiOverides"

--

These are here in order to prevent higher level property handlers from messing with the value set.

put the script_Markdown of scriptObject into scriptDescription
put the dep_ControllerLibs of scriptObject into dependencyLibs

They should not be required, as removing them will allow the properties to be accessed directly 
as they are named the same as the handler.

--> Fedwiki | Props
-
getprop script_Help
   -- where do we store the script help for a file that is not a Livecode object?
   return "Here is some test help"
end script_Help

getprop script_Markdown
   return "Here is some test help"
end script_Markdown

getprop dep_ControllerLibs
   put the dep_StackNames of me into stackNames
   put stack_ConvertNamesToShortPaths (stackNames, badNames) into shortFiles
   return shortFiles
end dep_ControllerLibs


--> Rig | Props | Safety
-
getprop short_ControllerFile
   -- put the uOPN ["shortControllerFile"] of me into shortFile
   put the short_ControllerFile of me into shortFile
   return shortFile
end short_ControllerFile

setprop short_ControllerFile shortFile
   --set the uOPN ["shortControllerFile"] of me to shortFile
   set the short_ControllerFile of me to shortFile
   return the long id of me
end short_ControllerFile

getprop server_TLD
   -- put the uOPN ["server_TLD"] of me into topLevelDomain
   put the server_TLD of me into topLevelDomain
   return topLevelDomain
end server_TLD

setprop server_TLD topLevelDomain
   --set the uOPN ["server_TLD"] of me to topLevelDomain
   set the server_TLD of me to topLevelDomain
   return the long id of me
end server_TLD

function secret_GetCached secretName, pArrayKey
   if pArrayKey is empty then put SecretLabel into pArrayKey
   --
   put SecretArray [pArrayKey][secretName] into someSecret
   if someSecret is not empty then return someSecret -- cached
   
   put secret_Get (secretName, pArrayKey) into someSecret
   put someSecret into SecretArray [pArrayKey][secretName]
   return someSecret
end secret_GetCached
*/


--> Model | Secret | Override
-
function secret_Get secretName, pArrayKey
   /*
   At the moment we store secrets in the config.lc file on the server
   and don't use specific files or database keys.
   
   But on the desktop we usually use a separate array file per project.
   This is something that eventualy the server should probably use as well.
   */
   
   put _ConstructShortArrayFile (pArrayKey) into shortFileFile
   put user_GetValue (secretName, shortFileFile) into someSecret
   return someSecret
end secret_Get

command secret_Set secretName, secretValue, pArrayKey
   put _ConstructShortArrayFile (pArrayKey) into shortFileFile
   user_SetValue secretName, shortFileFile, secretValue
   put the result into modelDataFile
   return modelDataFile
end secret_Set


--> Private
-
private function _ConstructShortArrayFile pArrayKey
   -- "pinterest_Authentication.array" or "secret_Authentication.array" (default)
   if pArrayKey is empty then put "secret" into pArrayKey
   put tolower(pArrayKey) & "_Authentication.array" into shortFileFile
   return shortFileFile
end _ConstructShortArrayFile


--> Fedwiki | Overrides
-
-- command fedwiki_SetRawJSON @rawJSON
   /*
   -- mock up $_POST_RAW from selected display of stack "Transporter Drop Urls"
   put the mock_DropJson of stack "Transporter Drop Urls" into rawJSON
   put rawJSON into $_POST_RAW
   return false
   */
   
   put the test_RawJSON of mController into rawJSON
   put rawJSON into $_POST_RAW
   return false
end fedwiki_SetRawJSON

command fedwiki_DeconstructDropped @droppedText, @droppedHtml, @droppedURL
   put _TestGetDroppedUrl() into droppedURL
   put "Test dropped text" into droppedText
   put "<b>Test dropped html</b>" into droppedHtml
   --
   put droppedURL into dropArray ["url"]
   put droppedText into dropArray ["text"]
   put droppedHtml into dropArray ["html"]
   return dropArray
end fedwiki_DeconstructDropped

function fedwikipedia_GetPageSlug
   put _TestGetDroppedUrl () into droppedURL
   put mediwiki_ExtractPageSlugFromUrl (droppedURL) into pageSlug
   fedwiki_ReturnError pageSlug, "Not a Wikipedia page!"
   return pageSlug
end fedwikipedia_GetPageSlug

command fedwiki_ReturnPageArray pageArray
   -- pageArray_StripJournal pageArray
   put json_FromArray (pageArray) into someJSON
   
   display_Array pageArray, "fedwiki_ReturnPageArray()"
   -- put someJSON -- can cause long term spinning
end fedwiki_ReturnPageArray

command fedwiki_ReturnJSON pageJSON
   -- here we override the returning of pageJSON back to the Fedwiki client for local testing
   if the shiftkey is "Down" then put pageJSON
   put json_ToArray (pageJSON) into pageArray
   display_Array pageArray, "fedwiki_ReturnJSON()"
   -- let's test also decoding
   put json_FromArray (pageArray) into testJSON
   -- put testJSON -- can cause long term spinning
end fedwiki_ReturnJSON

command fedwiki_ReturnError someValue, errorText
   if someValue is empty then
      put pageArray_Construct ("Error", errorText) into pageArray
      fedwiki_ReturnPageArray pageArray
      exit to top
   end if
end fedwiki_ReturnError
