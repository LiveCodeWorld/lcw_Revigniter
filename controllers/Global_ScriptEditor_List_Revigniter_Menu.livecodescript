script "Global_ScriptEditor_List_Revigniter_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_List_Revigniter_Menu
type: controller
version: 0.4


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [mTitlePath]
   return LocalArray ["hKey"]
end menu_Target

on menu_Init targetObject, mPath, mTitlePath
   put rev_GetHandlerTreeSelectedInfo() into hInfo
   put word 1 of hInfo into hType
   switch hType
      case "M"
         put "c" into hType
         break
      default
   end switch
   put word 2 of hInfo into hName
   put word 3 of hInfo into startLineNum
   put word 4 of hInfo into endLineNum
   put scriptEditor_Object() into hObject
   put hName,hType,hObject,1 into hKey
   
   put hKey into LocalArray ["hKey"]
   put hObject into LocalArray ["scriptObject"]
   put startLineNum into LocalArray ["startLineNum"]
   put endLineNum into LocalArray ["endLineNum"]
   put line startLineNum to endLineNum of the script of hObject into LocalArray ["someHandler"]
   
   -- put library_HandlerFile (hKey, empty, true) into LocalArray ["hkeyFolder"]
   -- put hArray_ListHkeyObjects (hKey) into otherObjects
   -- line_Delete hObject, otherObjects
   -- put word 1 to -1 of otherObjects into LocalArray ["other objects"]
end menu_Init


--> Global | ScriptEditor | List | Revigniter | Menu
-
on insert_Remote
   return "Global | revIgniter | Remote | Menu"
end insert_Remote

on _
end _

on submenu_Graph
   return "Global | Hkey | Walk | Menu"
end submenu_Graph

on submenu_Handler
   return "Global | Handler | Menu"
end submenu_Handler

on submenu_HandlerInfo
   return "Global | Handler | Library | Menu"
end submenu_HandlerInfo

on submenu_HandlerFiles
   return "Global | Handler | Calls | Menu"
end submenu_HandlerFiles

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | List | Revigniter | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("List")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("List") into shortNames
   return shortNames
end m_Titles


--> Global | ScriptEditor | List | Revigniter | Menu | Disabled
-
getprop disabled_CreateHelp [hKey]
   return false
   if there is a file svgFile then
      return false
   else
      return "delete"
   end if
end disabled_CreateHelp


--> Dev | Menu
-
on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "List", mTitle
end menu_SetMenu


--> Deps
-
--> Deps
-
function rev_GetHandlerTreeSelectedInfo
   put rev_HandlerTreeField() into handlerField
   put the hilitedLine of handlerField into lineNum
   put line lineNum of the cHandlers of handlerField into tHandler
   return tHandler
end rev_GetHandlerTreeSelectedInfo

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return rev_TopScriptEditor()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
   end switch
end rev_ScriptEditorStack

function rev_TopScriptEditor
   put the stack_Name of the target into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else 
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      if stackNames is empty then return empty
      put line 1 of stackNames into stackName
      if exists (stack stackName) is false then
         return empty
      end if
      return the long id of stack stackName
   end if
end rev_TopScriptEditor

function fedwiki_ConstructDroppedJSON droppedURL
   /*
   •	{"text":"https://media.ccc.de/v/32c3-7403-a_new_kid_on_the_block#video","html":""}
   */
   put droppedURL into dropArray ["text"]
   put empty into dropArray ["html"]
   put json_FromArray (dropArray) into someJSON
   return someJSON
end fedwiki_ConstructDroppedJSON
