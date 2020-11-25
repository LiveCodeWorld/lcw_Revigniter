script "behavior_RigLocalOveride"
--> MetaData
-
license: GPLv3
name: behavior_RigLocalOveride
type: behavior
version: 0.3

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
*/


--> Working on
-


--> Fedwiki
-
command fedwiki_ReturnError someValue, errorText
   if someValue is empty then
      put pageArray_Construct ("Error", errorText) into pageArray
   else
      
   end if
   --
   fedwiki_ReturnPageArray pageArray
end fedwiki_ReturnError

command fedwiki_ReturnPageArray pageArray
   display_TransportReturnPageArray pageArray
end fedwiki_ReturnPageArray

command fedwiki_ReturnJSON pageJSON
   -- here we override the returning of pageJSON back to the Fedwiki client for local testing
   put json_ToArray (pageJSON) into pageArray
   --
   display_TransportReturnPageArray pageArray, "fedwiki_ReturnJSON()"
end fedwiki_ReturnJSON


--> Override | Fedwiki | Get
-
function fedwiki_GetDroppedArray
   -- also good to get a post from a form POST
   fedwiki_SetRawJSON pRawJSON
   put json_ToArray (pRawJSON) into dropArray
   return dropArray
end fedwiki_GetDroppedArray

command fedwiki_SetRawJSON @rawJSON
   /*
   -- mock up $_POST_RAW 
   put rawJSON into $_POST_RAW
   return false
   */
   
   -- if called from a local transporter the target should be the controller
   put the long id of the target into controller
   -- we could double check here it is in the downloadded tranporter folded
   
   -- here we can override by placing a "getprop transporter_RawJSON" handler in the tranporter code
   put the transporter_RawJSON of controller into rawJSON
   
   if rawJSON is empty then
      put transport_GetMockRawJson() into rawJSON
   end if
   --
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
