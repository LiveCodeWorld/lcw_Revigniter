script "lib_Splash"
--> MetaData
-
license: GPLv3
name: lib_Splash
type: library
version: 0.1


--> Splash
-
function splash_ProcessRefArray tld, referenceSlug
   -- helper to construct slideArray for a reference link
   local slideArrayBit
   
   put "http://" & tld & slash & referenceSlug & ".json" into refPageURL
   put url refPageURL into refPageJson
   put json_ToArray (refPageJson) into refPageArray
   
   put refPageArray ["title"] into pageTitle
   put pageTitle into slideArrayBit ["title"]
   
   put refPageArray ["story"] into refStoryArray
   
   put item 2 of the extents of refStoryArray into maxItemNum
   repeat with itemNum = 1 to maxItemNum
      put refStoryArray [itemNum] into itemArray
      
      put itemArray ["text"] into itemText
      put itemArray ["type"] into itemType
      
      switch itemType
         case "reference"
            -- let's not recurse fetching reference items
            next repeat
         case "markdown"
            -- only extract paragraphs before first markdown title
            if char 1 of itemText = "#" then return slideArrayBit
            
            -- it's markdown and not a title
            -- so treat as default
         case "html"
            /*
            <img width=100% src="http://feast.fm/assets/images/refugee_feast_close.jpg">
            */
            put itemArray ["text"] into htmlBit
            
            -- let's see if it is a simple image
            -- is it the htmlBit item
            if word 1 of htmlBit = "<img" and itemNum = 1 then
               put html_ExtractImageSource (htmlBit) into srcURL
               put srcURL into slideArrayBit [itemNum]["text"]
               put "background image" into slideArrayBit [itemNum]["type"]
               next repeat
            end if
            
            -- so treat as default
         case "video"
         case "audio"
         case "image"
         default
            put itemText into slideArrayBit [itemNum]["text"]
            put itemType into slideArrayBit [itemNum]["type"]
      end switch
   end repeat
   
   -- there were no markdown titles
   return slideArrayBit
end splash_ProcessRefArray

function splash_GetSlideArray someHTML
   -- this removes indents from array
   local slideArray
   repeat with slideNUm = 1 to 5
      put splash_GetSlideTitle (someHTML, slideNum) into slideArray [slideNum]["title"]
      put splash_GetSlideText (someHTML, slideNum) into slideArray [slideNum]["text"]
   end repeat
   return slideArray
end splash_GetSlideArray

function splash_GetSlideTitle someHTML, slideNum
   put "Slide" && slideNum && "Title" into commentKey
   put html_GetCommentBlock (someHTML, commentKey) into slideTitle
   return word 1 to -1 of slideTitle
end splash_GetSlideTitle

function splash_GetSlideText someHTML, slideNum
   put "Slide" && slideNum && "Text" into commentKey
   put html_GetCommentBlock (someHTML, commentKey) into slideText
   return word 1 to -1 of slideText
end splash_GetSlideText

command splash_SetSlide @someHTML, slideNum, newTitle, newText
   put "Slide" && slideNum && "Title" into commentKey
   html_SetCommentBlock someHTML, commentKey, newTitle
   
   put "Slide" && slideNum && "Text" into commentKey
   html_SetCommentBlock someHTML, commentKey, newText
end splash_SetSlide


--> HTML | CommentBlock
-
function html_GetCommentBlock someHTML, commentKey
   local someText, startLineNum, endLineNum
   
   html_SetCommentBlockOffsets someHTML, commentKey, someText, startLineNum, endLineNum
   return someText
end html_GetCommentBlock

command html_SetCommentBlock @someHTML, commentKey, newText
   local someText, startLineNum, endLineNum
   
   html_SetCommentBlockOffsets someHTML, commentKey, someText, startLineNum, endLineNum
   if the result is false then
      return false
   end if
   
   put line startLineNum to endLineNum of someHTML into commentText
   put word 1 of commentText into firstWord
   put offset (firstWord, commentText) - 1 into charNum
   put char 1 to charNum of commentText into leadingWhiteSpace
   
   put leadingWhiteSpace before newText
   put newText into line startLineNum to endLineNum of someHTML
   return true
end html_SetCommentBlock

command html_SetCommentBlockOffsets someHTML, commentKey, @someText, @startLineNum, @endLineNum
   set the wholematches to false
   put "<!--" && commentKey && "-->" into startComment
   put lineoffset (startComment, someHTML) into startCommentLineNum
   if startCommentLineNum = 0 then
      put empty into someText
      put 0 into startLineNum
      put 0 into endLineNum
      return false
   end if
   
   put "<!--" && "/" & commentKey && "-->" into endComment
   put lineoffset (endComment, someHTML, startCommentLineNum) into extraBit
   
   put startCommentLineNum + extraBit  -1 into endLineNum
   put startCommentLineNum+1 into startLineNum
   put line startLineNum to endLineNum of someHTML into someText
   
   return true
end html_SetCommentBlockOffsets
