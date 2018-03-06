script "behavior_RigLocalOveride"
--> MetaData
-
license: GPLv3
name: behavior_RigLocalOveride
type: behavior
version: 0.1

/*
This library is for debuging purposes.

It allows easy exploration of Revigniter controllers.
When the behavior of stack "Temp Revigniter Controllers" is set to this stack these handlers will intercept the relevant calls.

See also older stack "behavior_FedwikiOverides"

put the script_Markdown of scriptObject into scriptDescription
put the dep_ControllerLibs of scriptObject into dependencyLibs
*/


--> Currently working on
-
getprop script_Help
   -- where do we store the script help for a file that is not a Livecode object?
   return "Here is some test help"
end script_Help

getprop script_Markdown
   return "Here is some test help"
end script_Markdown


--> Fedwiki | Props
-
getprop dep_ControllerLibs
   put the dep_StackNames of me into stackNames
   put stack_ConvertNamesToShortPaths (stackNames, badNames) into shortFiles
   return shortFiles
end dep_ControllerLibs


--> Rig | Props | Safety
-
/*
These are here in order to prevent higher level property handlers from messing with the value set.

They should not be required, as removing them will allow the properties to be accessed directly 
as they are named the same as the handler.
*/

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


--> Fedwiki | Overrides
-
/*
These handlers overide similarly named handlers in stack lib_Fedwiki.
*/
getprop fedwiki_DroppedUrl
   return fedwiki_GetTestDroppedUrl()
end fedwiki_DroppedUrl

function fedwiki_GetDroppedUrl postRaw
   -- postRaw would normally contain $_POST_RAW
   return fedwiki_GetTestDroppedUrl()
end fedwiki_GetDroppedUrl

function fedwikipedia_GetPageSlug
   put fedwiki_GetTestDroppedUrl () into droppedURL
   put mediwiki_ExtractPageSlugFromUrl (droppedURL) into pageSlug
   fedwiki_ReturnError pageSlug, "Not a Wikipedia page!"
   return pageSlug
end fedwikipedia_GetPageSlug

command fedwiki_SetDroppedInfo @dropJSON, @droppedURL, @droppedHTML, @droppedText
   -- could test / set droppedHTML and droppedHTML intelligently
   put fedwiki_GetTestDroppedUrl() into droppedURL
   put droppedURL into droppedText
   put empty into droppedHTML
   put $_POST_RAW into dropJSON
end fedwiki_SetDroppedInfo
   
function fedwiki_GetTestDroppedUrl
   put the fedwiki_DroppedURL of stack "Transporter Drop Urls" into droppedURL
   put fedwiki_ConstructDroppedJSON (droppedURL) into $_POST_RAW
   return droppedURL
end fedwiki_GetTestDroppedUrl
   
command fedwiki_ReturnJSON pageJSON
   -- here we override the returning of pageJSON back to the Fedwiki client for local testing
   if the shiftkey is "Down" then put pageJSON
   put json_ToArray (pageJSON) into pageArray
   display_Array pageArray, "fedwiki_ReturnJSON()"
   -- let's test also decoding
   put json_FromArray (pageArray) into testJSON
   put testJSON
end fedwiki_ReturnJSON

command fedwiki_ReturnError someValue, errorText
   if someValue is empty then
      put fedwiki_ConstructErrorJSON (errorText) into errorJSON
      fedwiki_ReturnJSON errorJSON
      exit to top
   end if
end fedwiki_ReturnError


--> Fedwiki | Props
-
local LocalArray

getprop fedwiki_DroppedURL
   return LocalArray ["fedwiki_DroppedURL"]
end fedwiki_DroppedURL

setprop fedwiki_DroppedURL someURL
   put someURL into LocalArray ["fedwiki_DroppedURL"]
end fedwiki_DroppedURL



--> Fedwiki | Helpers
-
function fedwiki_ConstructDroppedJSON droppedURL
   /*
   •	{"text":"https://media.ccc.de/v/32c3-7403-a_new_kid_on_the_block#video","html":""}
   */
   put droppedURL into dropArray ["text"]
   put empty into dropArray ["html"]
   put json_FromArray (dropArray) into someJSON
   return someJSON
end fedwiki_ConstructDroppedJSON

