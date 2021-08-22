script "Global | Federation | Model | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Federation | Model | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Events
-
on mDoubleUp_FederationModel displayView, shortModelFile
   put transport_FetchModelFromShortFile (shortModelFile) into modelData
   --
   display_Data modelData, shortModelFile, "Transport Model"
end mDoubleUp_FederationModel


--> Menu | Props
-
getprop menu_IsSimple
   return gLCW ["menu_IsSimple"] is not false
end menu_IsSimple

getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   put the displayed_Data of displayView into LocalArray ["dataArray"]
   --
   return displayView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

getprop editLibrary_Params
   -- put "lcw_Revigniter" into projectName -- this controllers project (must exist)
   put the project_Name of me into projectName
   put the project_UsedStackNames of stack projectName into stackNames
   filter stackNames with "*Transport*"
   return stackNames
end editLibrary_Params


--> Global | Federation | Model | Menu
-
on menu_ServerModel arrayView
   display_FederationServers
end menu_ServerModel

on menu_FederationModel arrayView
   put fedray_FetchModel() into someArray
   set the displayed_Array ["Federation Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Line | Menu"
end menu_FederationModel

on menu_FederationAuthorModel arrayView
   put author_FetchModelArray() into someArray
   set the displayed_Array ["Federation Author Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Author | Line | Menu"
end menu_FederationAuthorModel

on menu_DeadModel arrayView
   put federation_FetchModel ("Dead Model") into someArray
   set the displayed_Array ["Dead Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Line | Menu"
end menu_DeadModel

on _
end _

on menu_EditLibrary displayView, stackName
   edit the script of stack stackName
end menu_EditLibrary

on menu_DisplayTransporters
   display_Transporters
end menu_DisplayTransporters

on menu_Help
   launch_MenuHelp
end menu_Help

on menu_Refresh
   display_FederationModels
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _DisplayLocalFedray arrayView
   display_LocalFedray
end _DisplayLocalFedray

on _DisplayLastUpdate displayView
   put atopia_GetLastUpDate() into lastUpdateSeconds
   convert lastUpdateSeconds to internet date
   --
   put lastUpdateSeconds into someQuestion
   lcw_Answer someQuestion, displayView, lastUpdateSeconds
end _DisplayLastUpdate

on _DisplayAtopiaCatModel
   display_AtopiaCatModel
end _DisplayAtopiaCatModel

on _StoreAtopiaCatArray
   -- put atopia_GetLastUpDate() into laterThanSeconds
   put federation_GetLastUpDate() into laterThanSeconds
   put atopia_ConstructCatModel (laterThanSeconds) into atopiaCatModel
   --
   transport_PostAtopiaCatModel atopiaCatModel
   put the result into rPageArray
   --
   put transport_FetchAtopiaCatModel() into atopiaCatModel
   display_Data atopiaCatModel, "Categorised Date Array", "Atopia Server"
   display_PageArray rPageArray
end _StoreAtopiaCatArray

on _PostFederationUpdate
   put "http://rest.livecode.world/scrape" into postURL
   --
   put the seconds into postArray ["date"]
   --
   put 58105 into postArray ["scan"]["pages"]
   put 1229 into postArray ["scan"]["sites"]
   --
   put 7619 into postArray ["index"]["counts"]
   put 2321 into postArray ["index"]["sites"]
   put 42532 into postArray ["index"]["slugs"]
   --
   put json_FromArray (postArray) into someJSON
   put jsonrpc_Post (someJSON, postURL)
end _PostFederationUpdate

on _
end _

on _CreateTransportModel
   put atopia_FetchDomainArray() into modelData
   -- put pageArray_FetchByTitle ("roster.fedwiki.org", "Register Sites Template") into modelData
   --
   transport_PostProtectedModel modelData, "bosmeg"
   put the result into rPageArray
   --
   display_PageArray rPageArray
end _CreateTransportModel

on _CreateTransportPage
   breakpoint
   -- put transport_FetchRosterPageArray ("Register Sites Template", "oneworld.wiki") into pageArray
   put pageArray_FetchByTitle ("roster.fedwiki.org", "Register Sites Template") into pageArray
   pageArray_Rename pageArray, "One World Sites", "roster.fedwiki.org,fedwiki.org"
   --
   put json_FromArray (pageArray) into pageJSON
   put jsonrpc_Post (pageJSON, "https://rest.livecode.world/register/writePageJson") into rPageJson
   --
   display_JSON rPageJson
end _CreateTransportPage

on _NodeModulesPath
   -- npm list -g --depth=0
   put "ssh -t root@fedwiki.org" into shellScript
   put atopia_ModulesFolder() into mFolder
   put space & kwote ("ls" && mFolder, "'") after shellScript
   put space & ";" after shellScript
   put space & "bash --login" after shellScript
   --
   terminal_PasteInNewTab shellScript
end _NodeModulesPath

on _
end _

on _RemoteServerArray arrayView
   put _ServerName() into serverName
   --
   lcw_Answer "Remove server array from wiki model. Testing and not stored for now..."
   
   put federation_FetchModel ("Server Model") into federationServerModel
   put federationServerModel [serverName] into serverArray
   --
   display_Array serverArray, "federation_FetchServerModel"
end _RemoteServerArray

on _UpdateSeverModel arrayView
   put _ServerName() into serverName
   --
   lcw_Answer "Update server array using fedray and teh displayed data. Not quite sure what it does, but testing and not stored for now..."
   
   set the cursor to watch
   --
   put true into pUpdateFedray
   put ward_FetchSiteModel() into fedray
   --
   put the displayed_Data of arrayView into serverModel
   --
   serverData_UpdateServer serverModel, serverName, fedray, pUpdateFedray
   --
   set the displayed_Data of arrayView to serverModel
end _UpdateSeverModel

on _CreateFedrayModels displayView
   menu_DoGlobal "menu_CreateFedrayModels", "Global | Federation | Build | Menu"
end _CreateFedrayModels
