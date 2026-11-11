B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Public AppSQL As SQL
	Public AppPath As String
	Public AppDB As String
	Public AppJSON As String
	Public AppMap As Map
	Public AppID As String
	Public AppTitle As String
	Public AppName As String
	Public App As HTMLApp
	Public Commands As List
	Public jFiles As List
	Public cssFiles As List
	Public Version As String
	Public Author As String
	Public WebSite As String
	Public Email As String
	Public Copyrights As String
	Public wwwPath As String
	Public jsPath As String
	Public cssPath As String
	Public ImagesPath As String
	Public fontsPath As String
	Public SiteTitle As String
	Public Framework As String
	Public UseFontAwesome As String
	Public PageName As String
	Public PageTitle As String
	Public CodePath As String
End Sub

Sub Initialize
	'define js files for bootstrap
	jFiles.Initialize
	jFiles.Add("jquery-3.2.1.min.js")
	jFiles.Add("popper.min.js")
	jFiles.Add("tether.min.js")
	jFiles.Add("bootstrap.min.js")
	'define css files for bootstrap
	cssFiles.Initialize 
	cssFiles.Add("bootstrap.min.css")
End Sub


'get the app details from a map
Sub App_GetDetails
	AppName = AppMap.getdefault("appname","")
	Copyrights = AppMap.getdefault("copyrights","")
	Author = AppMap.getdefault("author","")
	AppID = AppMap.getdefault("appid","")
	Version = AppMap.getdefault("version","")
	Email = AppMap.getdefault("email","")
	WebSite = AppMap.getdefault("website","")
	SiteTitle = AppMap.GetDefault("sitetitle","")
	Framework = AppMap.GetDefault("framework","")
	UseFontAwesome = AppMap.GetDefault("usefontawesome","0")
	Framework = jMash.ProperCase(Framework)
End Sub

private Sub Delete_Page(pgName As String)
	If pgName.ToLowerCase = "index" Then
		AddCommand($"ERROR: Page '${pgName}' CANNOT be deleted, you can delete its elements instead"$)
		Return		
	End If
	DBUtils.RecordDelete(AppSQL,"Pages","PageName",pgName)
	'delete other things linked to the page
	DBUtils.RecordDeleteWhere(AppSQL,"Components",CreateMap("pageName":pgName))
	'check existence
	If DBUtils.RecordExists(AppSQL,"Pages","PageName",pgName) = True Then
		AddCommand($"ERROR: Page '${pgName}' COULD NOT be deleted"$)
	Else
		AddCommand($"SUCESS: Page '${pgName}' deleted successfully"$)
	End If
End Sub

private Sub Delete_Element(elID As String)
	PageName = jMash.GetSimple("active_page")
	Dim sKey As String = $"${PageName}.${elID}"$
	'does the element exist
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey) = False Then
		AddCommand($"ERROR: Element '${sKey}' COULD NOT be found"$)
		Return
	End If
	Dim ids As String = DBUtils.ReadField(AppSQL,"Components","key",sKey,"id")
	Component_Delete(ids)
	'check existence
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey) = True Then
		AddCommand($"ERROR: Element '${sKey}' COULD NOT be deleted"$)
	Else
		AddCommand($"SUCCESS: Element '${sKey}' deleted successfully"$)
		Main.Page_Preview(PageName)
	End If
End Sub

private Sub Copy_Element(source As String, target As String)
	PageName = jMash.GetSimple("active_page")
	Dim sKey As String = $"${PageName}.${source}"$
	Dim sKey1 As String = $"${PageName}.${target}"$
	'does the element exist
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey) = False Then
		AddCommand($"ERROR: Source element '${sKey}' COULD NOT be found"$)
		Return
	End If
	'does the target exist
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey1) = True Then
		AddCommand($"ERROR: Target element '${sKey}' ALREADY exists"$)
		Return
	End If
	'copy the old element to the new element
	Dim sourceMap As Map = DBUtils.ReadRecord(AppSQL,"Components","key",sKey)
	Dim sourceid As String = sourceMap.GetDefault("id","")
	'add the new component
	sourceMap.Put("key",sKey1)
	sourceMap.Put("element",target)
	sourceMap.Remove("id")
	Dim m As Map = DBUtils.AddReadRecord(AppSQL,"Components",sourceMap)
	'get its id
	Dim targetid As String = m.getdefault("id","")
	'now copy the attributes and classes
	Dim cls As List = DBUtils.ExecuteMaps(AppSQL,$"select * from Classes where ElementID = ${sourceid}"$,Null)
	Dim atr As List = DBUtils.ExecuteMaps(AppSQL,$"select * from Attributes where ElementID = ${sourceid}"$,Null)
	'process classes
	For Each clsm As Map In cls
		Dim sClass As String = clsm.GetDefault("class","")
		Dim sKeyx As String = $"${targetid}.${sClass}"$
		clsm.Put("elementid",targetid)
		clsm.Put("key",sKeyx)
		clsm.Remove("id")
		DBUtils.AddRecord(AppSQL,"Classes",clsm)
	Next
	'process attributes
	For Each atrm As Map In atr
		Dim sAttribute As String = clsm.GetDefault("attribute","")
		Dim sKeyx As String = $"${targetid}.${sAttribute}"$
		atrm.Put("elementid",targetid)
		atrm.put("element",target)
		atrm.Put("key",sKeyx)
		atrm.Remove("id")
		DBUtils.AddRecord(AppSQL,"Attributes",atrm)
	Next
	'check existence
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey1) = False Then
		AddCommand($"ERROR: Element '${sKey1}' COULD NOT be copied"$)
	Else
		AddCommand($"SUCCESS: Element '${sKey1}' copied successfully"$)
		Main.Page_Preview(PageName)
	End If
End Sub

Sub Component_Delete(ids As String)
	'get the children of these elements
	Dim lstChilds As List = DBUtils.ExecuteField1(AppSQL,$"select id from Components where parentid in (${ids})"$,"id",False,True)
	Dim kids As String = jMash.join(",",lstChilds)
	DBUtils.ExecuteQuery(AppSQL,$"delete from Components where parentid in (${ids})"$)
	DBUtils.ExecuteQuery(AppSQL,$"delete from Attributes where ElementID in (${ids})"$)
	DBUtils.ExecuteQuery(AppSQL,$"delete from Classes where ElementID in (${ids})"$)
	'DBUtils.ExecuteQuery(appsql,$"delete from CSS where ElementID in (${ids})"$)
	'delete the kids
	DBUtils.ExecuteQuery(AppSQL,$"delete from Attributes where ElementID in (${kids})"$)
	DBUtils.ExecuteQuery(AppSQL,$"delete from Classes where ElementID in (${kids})"$)
	'DBUtils.ExecuteQuery(appsql,$"delete from CSS where ElementID in (${kids})"$)
	DBUtils.ExecuteQuery(AppSQL,$"delete from Components where id in (${ids})"$)
End Sub

private Sub Select_Element(elID As String)
	PageName = jMash.GetSimple("active_page")
	Dim sKey As String = $"${PageName}.${elID}"$
	'does the element exist
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey) = False Then
		AddCommand($"ERROR: Element '${sKey}' COULD NOT be found"$)
		Return
	End If
	'check existence
	jMash.putsimple("active_element",elID)
	Dim elMap As Map = DBUtils.ReadRecord(AppSQL,"Components","key",sKey)
	Dim elJSON As String = jMash.Map2JsonPretty(elMap)
	AddCommand($"SUCCESS: Element '${sKey}' set successfully"$)
	AddCommand(elJSON)
End Sub


private Sub Set_Parent(elID As String, parentID As String)
	PageName = jMash.GetSimple("active_page")
	Dim sKey1 As String = $"${PageName}.${elID}"$
	Dim sKey2 As String = $"${PageName}.${parentID}"$
	'does the element exist
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey1) = False Then
		AddCommand($"ERROR: Element '${sKey1}' COULD NOT be found"$)
		Return
	End If
	If DBUtils.RecordExists(AppSQL,"Components","Key",sKey2) = False Then
		AddCommand($"ERROR: Element '${sKey2}' COULD NOT be found"$)
		Return
	End If
	'read the id for the parent
	Dim pid As String = DBUtils.ReadField(AppSQL,"Components","key",sKey2,"id")
	'update the parent for the child
	Dim elMap As Map = DBUtils.EditRecordRead(AppSQL,"Components","key",sKey1,CreateMap("parentid":pid))
	Dim elJSON As String = jMash.Map2JsonPretty(elMap)
	AddCommand($"SUCCESS: Element '${sKey1}' parent set successfully"$)
	AddCommand(elJSON)
	Main.Page_Preview(PageName)
End Sub



private Sub Add_Page(pgName As String, pgTitle As String)
	pgName = pgName.tolowercase
	Dim nc As Int = DBUtils.RecordCount(AppSQL,"Pages","id")
	nc = nc + 1
	Dim pgMap As Map
	pgMap.Initialize
	pgMap.Put("PageName",pgName)
	pgMap.Put("Title", pgTitle)
	pgMap.Put("Description","")
	pgMap.Put("TabIndex",nc)
	pgMap.Put("Active","1")
	pgMap.Put("HtmlName",$"${pgName}.html"$)
	pgMap.Put("keywords","")
	DBUtils.AddEditRecord(AppSQL,"Pages","pagename",pgName,pgMap)
	'process other things for the page
End Sub

private Sub AddCommand(sCommand As String)
	Commands.Add($"${jMash.LongDateTimeToday}: ${sCommand}."$)
End Sub

private Sub AppSQLNotInitialized
	Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}': database is not initialized. You need to open / create a project."$)
End Sub

private Sub PageNotFound(sPage As String)
	Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}.${sPage}': page COULD NOT BE FOUND."$)
End Sub


private Sub List_Pages
	Dim lstPages As List = DBUtils.ExecuteField(AppSQL,"Pages","pagename",False,True)
	If lstPages.Size = 0 Then
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}': There are no Pages yet in this application. You can add some pages"$)
	Else
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}': We have found the following pages in this website."$)
		lstPages.Sort(True)
		Dim strPages As String = jMash.MvFromList(lstPages,CRLF)
		Commands.Add(strPages)
	End If
End Sub

Sub List_Classes(elid As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.ToLowerCase
	elid = elid.ToLowerCase
	'define the key
	Dim elKey As String = $"${PageName}.${elid}"$
	'check the instance being created from tags
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: There is no element named '${elKey}' in this page."$)
		Return
	End If
	Dim rows As List = DBUtils.ExecuteMaps(AppSQL,$"select * from Classes where pagename = '${PageName}' and element = '${elid}'"$,Null)
	Dim sb As StringBuilder
	sb.Initialize
	Dim rCnt As Int = 0
	For Each row As Map In rows
		rCnt = rCnt + 1
		Dim rowJSON As String = jMash.Map2JsonPretty(row)
		Dim snum As String = jMash.Pad(rCnt,2,"0",False)
		sb.Append(snum).append(". ").Append(rowJSON).Append(CRLF)
	Next
	If rows.Size = 0 Then
		AddCommand("No classes found")
	End If
	Commands.Add(sb.ToString)
End Sub

Sub List_Attributes(elid As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.ToLowerCase
	elid = elid.ToLowerCase
	'define the key
	Dim elKey As String = $"${PageName}.${elid}"$
	'check the instance being created from tags
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: There is no element named '${elKey}' in this page."$)
		Return
	End If
	Dim rows As List = DBUtils.ExecuteMaps(AppSQL,$"select * from Attributes where pagename = '${PageName}' and element = '${elid}'"$,Null)
	Dim sb As StringBuilder
	sb.Initialize
	Dim rCnt As Int = 0
	For Each row As Map In rows
		rCnt = rCnt + 1
		Dim rowJSON As String = jMash.Map2JsonPretty(row)
		Dim snum As String = jMash.Pad(rCnt,2,"0",False)
		sb.Append(snum).append(". ").Append(rowJSON).Append(CRLF)
	Next
	If rows.Size = 0 Then
		AddCommand("No attributes found")
	End If
	Commands.Add(sb.ToString)
End Sub

Sub Add_StyleClass(className As String, classCategory As String)
	Dim sDisplayName As String = className.replace("-"," ")
	sDisplayName = jMash.ProperCase(sDisplayName)
	Dim sKey As String = $"${Framework}.${className}"$
	Dim sclass As Map = CreateMap("class": className, _
	"classname": sDisplayName, _
	"active":"1", _
	"framework": Framework, _
	"key": sKey, _
	"category":classCategory, _
	"list":"")
	Dim m As Map = DBUtils.addeditrecord(Main.internalsql,"FrameworkClasses","key",sKey,sclass)
	If m.IsInitialized Then
		Dim elJSON As String = jMash.Map2JsonPretty(m)
		AddCommand($"SUCCESS: Style Class '${sKey}' updated successfully"$)
		AddCommand(elJSON)
	Else
		AddCommand($"ERROR: Style Class '${sKey}' not updated successfully."$)
	End If
End Sub

'add a class
Sub Add_Class(elid As String, elclass As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.ToLowerCase
	elid = elid.ToLowerCase
	'define the key
	Dim elKey As String = $"${PageName}.${elid}"$
	'check the instance being created from tags
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: There is no element named '${elKey}' in this page."$)
		Return
	End If
	'does this class exist
	If DBUtils.RecordExists(Main.internalsql,"FrameworkClasses","Class",elclass) = False Then
		AddCommand($"ERROR: There is no class named '${elclass}' in the Framework Classes table."$)
		Return
	End If
	'get the element id
	Dim elid1 As String = DBUtils.ReadField(AppSQL,"Components","Key",elKey,"id")
	'define the class key
	Dim classKey As String = $"${elid1}.${elclass}"$
	'does this class exist
	If DBUtils.RecordExists(AppSQL,"Classes","Key",classKey) = True Then
		AddCommand($"ERROR: This class '${classKey}' already exists for this element"$)
		Return
	End If
	'add the class
	Dim classMap As Map = CreateMap("elementid":elid1, _
	"class":elclass, _
	"key":classKey, _
	"pagename":PageName, _
	"element":elid, _
	"active":"1")
	DBUtils.AddRecord(AppSQL,"Classes",classMap)
	'get json element
	Dim classMap As Map = DBUtils.RecordRead(AppSQL,"Classes","key",classKey)
	If classMap.IsInitialized Then
		Dim elJSON As String = jMash.Map2JsonPretty(classMap)
		AddCommand("SUCCES: HTML Element Class created successfully")
		AddCommand(elJSON)
		Main.Page_Preview(PageName)
	Else
		AddCommand($"ERROR: HTML Element Class '${classKey}' COULD NOT be added, please try again."$)
	End If
End Sub

'add a property, the property name can be anything
Sub Add_Attribute(elid As String, propName As String, propValue As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.ToLowerCase
	elid = elid.ToLowerCase
	propName = propName.tolowercase
	'define the key
	Dim elKey As String = $"${PageName}.${elid}"$
	'check the instance being created from tags
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: There is no element named '${elKey}' in this page."$)
		Return
	End If
	'get the element id
	Dim elid1 As String = DBUtils.ReadField(AppSQL,"Components","Key",elKey,"id")
	'define the property key
	Dim classKey As String = $"${elid1}.${propName}"$
	Dim attrMap As Map = DBUtils.ReadRecord(AppSQL,"Attributes","key",classKey)
	If attrMap.IsInitialized Then
		attrMap.Put("defaultvalue",propValue)
		attrMap.Put("active","1")
		DBUtils.AddEditRecord(AppSQL,"Attributes","key",classKey,attrMap)
	Else	
		'add the property
		Dim attrMap As Map = CreateMap("elementid":elid1, _
		"attribute":propName, _
		"key":classKey, _
		"defaultvalue":propValue, _
		"pagename":PageName, _
		"isfile":"0", _
		"element":elid, _
		"active":"1")
		'update the record
		DBUtils.AddEditRecord(AppSQL,"Attributes","key",classKey,attrMap)
	End If
	'get json element
	Dim classMap As Map = DBUtils.RecordRead(AppSQL,"Attributes","key",classKey)
	If classMap.IsInitialized Then
		Dim elJSON As String = jMash.Map2JsonPretty(classMap)
		AddCommand("SUCCES: HTML Element Attribute created successfully")
		AddCommand(elJSON)
		Main.Page_Preview(PageName)
	Else
		AddCommand($"ERROR: HTML Element Attribute '${classKey}' COULD NOT be added, please try again."$)
	End If
End Sub

Sub Delete_Attribute(elid As String, elclass As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.ToLowerCase
	elid = elid.ToLowerCase
	elclass = elclass.tolowercase
	'define the key
	Dim elKey As String = $"${PageName}.${elid}"$
	'check the instance being created from tags
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: There is no element named '${elKey}' in this page."$)
		Return
	End If
	'get the element id
	Dim elid1 As String = DBUtils.ReadField(AppSQL,"Components","Key",elKey,"id")
	'define the class key
	Dim classKey As String = $"${elid1}.${elclass}"$
	'does this class exist
	If DBUtils.RecordExists(AppSQL,"Attributes","Key",classKey) = False Then
		AddCommand($"ERROR: The attribute '${classKey}' DOES NOT exist"$)
		Return
	End If
	'delete this attribute
	DBUtils.DeleteRecord(AppSQL,"Attributes","key",classKey)
	'does this class exist
	If DBUtils.RecordExists(AppSQL,"Attributes","Key",classKey) = True Then
		AddCommand($"ERROR: The attribute '${classKey}' COULD NOT be deleted"$)
	Else
		AddCommand($"SUCCESS: The attribute '${classKey}' was deleted successfully"$)
		Main.Page_Preview(PageName)
	End If
End Sub


Sub Delete_Class(elid As String, elclass As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.ToLowerCase
	elid = elid.ToLowerCase
	'define the key
	Dim elKey As String = $"${PageName}.${elid}"$
	'check the instance being created from tags
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: There is no element named '${elKey}' in this page."$)
		Return
	End If
	'get the element id
	Dim elid1 As String = DBUtils.ReadField(AppSQL,"Components","Key",elKey,"id")
	'define the class key
	Dim classKey As String = $"${elid1}.${elclass}"$
	'does this class exist
	If DBUtils.RecordExists(AppSQL,"Classes","Key",classKey) = False Then
		AddCommand($"ERROR: The class '${classKey}' DOES NOT exist"$)
		Return
	End If
	'delete this class
	DBUtils.DeleteRecord(AppSQL,"Classes","key",classKey)
	'does this class exist
	If DBUtils.RecordExists(AppSQL,"Classes","Key",classKey) = True Then
		AddCommand($"ERROR: The class '${classKey}' COULD NOT be deleted"$)
	Else
		AddCommand($"SUCCESS: The class '${classKey}' was deleted successfully"$)
		Main.Page_Preview(PageName)
	End If
End Sub

private Sub Rename_Page(oldpage As String, newpage As String)
	oldpage = oldpage.ToLowerCase
	newpage = newpage.tolowercase
	If DBUtils.RecordExists(AppSQL,"Pages","PageName",oldpage) = False Then
		AddCommand($"ERROR: Page '${oldpage}' COULD NOT be found!"$)
		Return
	End If
	If DBUtils.RecordExists(AppSQL,"Pages","PageName",newpage) = True Then
		AddCommand($"ERROR: Page '${newpage}' already exists!"$)
		Return
	End If
	newpage = newpage.ToLowerCase
	If newpage = "index" Then
		AddCommand($"ERROR: '${newpage}' CANNOT be renamed"$)
		Return
	End If
	'get details of the page to be renamed
	Dim oldpM As Map = DBUtils.ReadRecord(AppSQL,"Pages","pagename",oldpage)
	'get the id of the page
	Dim oldid As String = oldpM.GetDefault("id","")
	'rename the page
	oldpM.Put("pagename",newpage)
	'update the database
	DBUtils.AddEditRecord(AppSQL,"Pages","id",oldid,oldpM)
	'process other linked things
	If DBUtils.RecordExists(AppSQL,"Pages","PageName",newpage) = True Then
		AddCommand($"SUCCESS: Page '${newpage}' renamed successfully!"$)
		'update the classes for this page
		Dim updateClasses As String = $"update Classes set pagename = '${newpage}' where pagename = '${oldpage}'"$
		DBUtils.RunQuery(AppSQL,updateClasses,True)
		Main.Page_Preview(newpage)
	End If
End Sub

Sub List_Templates
	Dim sb As StringBuilder
	sb.Initialize
	Dim rows As List = DBUtils.ExecuteMaps(Main.internalsql,"select * from templates order by DisplayName",Null)
	Dim sPart1 As String = "Display Name"
	sPart1 = jMash.Pad(sPart1,34," ",True)
	sb.Append(sPart1).Append("Instance").Append(CRLF)
	Dim rCnt As Int = 0
	For Each row As Map In rows
		rCnt = rCnt + 1
		Dim sDisplayName As String = row.GetDefault("displayname","")
		Dim sInstance As String = row.GetDefault("instance","")
		sDisplayName = jMash.Pad(sDisplayName,30," ",True)
		Dim snum As String = jMash.Pad(rCnt,2,"0",False)
		sb.Append(snum).append(". ").Append(sDisplayName).Append(sInstance).Append(CRLF)
	Next
	Commands.Add(sb.ToString)
End Sub

Sub List_Elements
	'get the page name
	PageName = jMash.GetSimple("active_page")
	Dim sb As StringBuilder
	sb.Initialize
	Dim rows As List = DBUtils.ExecuteMaps(AppSQL,"select * from Components order by TabIndex",Null)
	Dim rCnt As Int = 0
	For Each row As Map In rows
		rCnt = rCnt + 1
		Dim rowJSON As String = jMash.Map2JsonPretty(row)
		Dim snum As String = jMash.Pad(rCnt,4,"0",False)
		sb.Append(snum).append(". ").Append(rowJSON).Append(CRLF)
	Next
	If rows.Size = 0 Then
		AddCommand("No elements found")
	End If
	Commands.Add(sb.ToString)
End Sub

Sub Update_Element(scommand As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	PageName = PageName.tolowercase
	'split the command
	Dim spParts() As String = jMash.StrParse(" ",scommand)
	Dim elid As String = spParts(1)
	Dim elpr As String = spParts(2)
	Dim elvl As String = jMash.MvRest(" ",scommand,4)
	Dim props As List = jMash.CreateList(",","element,typeof,text,value,name,textafter,active,tabindex")
	'does the element exist on page, define it
	Dim elKey As String = $"${PageName}.${elid}"$
	'define the key
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = False Then
		AddCommand($"ERROR: HTML Element '${elKey}' DOES NOT exists on this page."$)
		Return
	End If
	'element found, check property to update
	If jMash.OnList(props,elpr) = False Then
		AddCommand($"ERROR: HTML Element property error [element,typeof,text,name,value,textafter,active,tabindex]"$)
		Return
	End If
	elpr = elpr.tolowercase
	Select Case elpr
	Case "element"
		'change the id, check existence
		elvl = elvl.tolowercase
		Dim newKey As String = $"${PageName}.${elvl}"$
		If DBUtils.RecordExists(AppSQL,"Components","Key",newKey) = True Then
			AddCommand($"ERROR: HTML Element '${newKey}' already exists, use another element id."$)
			Return
		End If
		'get id of component
		Dim tblid As String = DBUtils.ReadField(AppSQL,"Components","key",elKey,"id")
		'update the fields
		Dim elMap As Map = CreateMap("element":elvl, "key":newKey)
		Dim elMapU As Map = DBUtils.EditRecordRead(AppSQL,"Components","id",tblid,elMap)
		If elMapU.IsInitialized Then
			Dim elJSON As String = jMash.Map2JsonPretty(elMapU)
			AddCommand($"SUCCESS: HTML Element '${newKey}' updated succesfully."$)
			AddCommand(elJSON)
			Dim updateClasses As String = $"update Classes set element = '${elvl}' where element = '${elid}'"$
			DBUtils.RunQuery(AppSQL,updateClasses,True)
			Main.Page_Preview(PageName)
		Else			
			AddCommand($"ERROR: HTML Element '${newKey}' COULD NOT be updated, use another element id."$)
		End If
	Case "typeof"
		'does this tag exist
		If DBUtils.RecordExists(Main.internalsql,"Tags","tag",elvl) = False Then
			AddCommand($"ERROR: There is no tag named '${elvl}', use another tag name."$)
			Return
		End If
		Dim elMap As Map = CreateMap("typeof":elvl)
		Dim elMapU As Map = DBUtils.EditRecordRead(AppSQL,"Components","key",elKey,elMap)
		If elMapU.IsInitialized Then
			Dim elJSON As String = jMash.Map2JsonPretty(elMapU)
			AddCommand($"SUCCESS: HTML Element '${elKey}' updated succesfully."$)
			AddCommand(elJSON)
			Main.Page_Preview(PageName)
		Else		
			AddCommand($"ERROR: HTML Element '${elKey}' COULD NOT be updated"$)
			Return
		End If
	Case "text","value","textafter","active","tabindex","name"
		'existing fields
		Dim elMap As Map = CreateMap(elpr:elvl)
		Dim elMapU As Map = DBUtils.EditRecordRead(AppSQL,"Components","key",elKey,elMap)
		If elMapU.IsInitialized Then
			Dim elJSON As String = jMash.Map2JsonPretty(elMapU)
			AddCommand($"SUCCESS: HTML Element '${elKey}.${elpr}' updated succesfully."$)
			AddCommand(elJSON)
			Main.Page_Preview(PageName)
		Else
			AddCommand($"ERROR: HTML Element '${elKey}.${elpr}' COULD NOT be updated"$)
			Return
		End If
	End Select
End Sub

Sub Add_Element(instanceof As String, idname As String)
	'get the active page
	PageName = jMash.GetSimple("active_page")
	'check the instance being created from tags
	If DBUtils.RecordExists(Main.internalsql,"Tags","Tag",instanceof) = False Then
		AddCommand($"ERROR: There is no instance of element '${instanceof}' in the Tags table."$)
		Return 
	End If
	'define the key
	idname = idname.tolowercase
	instanceof = instanceof.tolowercase
	PageName = PageName.tolowercase
	Dim elKey As String = $"${PageName}.${idname}"$
	'define the key
	If DBUtils.RecordExists(AppSQL,"Components","Key",elKey) = True Then
		AddCommand($"ERROR: HTML Element '${elKey}' already exists on this page."$)
		Return
	End If
	'now create the element
	Dim nc As Int = DBUtils.LastRecordID(AppSQL,"Components","id")
	nc = nc + 1
	Dim elMap As Map = CreateMap("active":"1", _
	"pagename":PageName, _
	"key":elKey, _
	"element":idname, _
	"tabindex": nc, _
	"typeof":instanceof, _
	"text":idname.ToUpperCase, _
	"value":"", _
	"textafter":"0", _
	"parentid":"0")
	DBUtils.AddRecord(AppSQL,"Components",elMap)
	'get json element
	Dim elMap As Map = DBUtils.RecordRead(AppSQL,"Components","key",elKey)
	If elMap.IsInitialized Then
		Dim elJSON As String = jMash.Map2JsonPretty(elMap)
		AddCommand("SUCCESS: HTML Element created successfully")
		AddCommand(elJSON)
		Main.Page_Preview(PageName)
	Else
		AddCommand($"ERROR: HTML Element '${elKey}' COULD NOT be added, please try again."$)
	End If
End Sub

Sub LogCommand(sCommand As String)
	Dim logM As Map = CreateMap("doneon":jMash.LongDateTimeToday, _
	"command":sCommand)
	DBUtils.AddRecord(Main.internalsql,"Logs",logM)
End Sub

Sub ExecuteCommand(frm As Form, sCommand As String) As ResumableSub
	sCommand = sCommand.Trim
	If sCommand = "" Then
		jMash.MsgBoxWarn(frm,"CLI Command","There is no command that has been added, please type a command!")
		Return False
	End If
	LogCommand(sCommand)
	'clear any existing commands
	Commands.Initialize 
	Dim spParts() As String = jMash.StrParse(" ",sCommand)
	'accepted command
	Dim acceptedCommand As String = spParts(0)
	Select Case acceptedCommand.tolowercase
	Case "help"
		Commands.Add("cd [appname] - change directory to the 'appname' and make the 'appname' default.")
		Commands.Add("create [appName com.xxx.apptitle sitetitle] - create an app called appname with appID com.xxx.apptitle and site title.")
		Commands.Add("serve [appName] - build and serve the website to the browser.")
		Commands.Add("add_page [pageName pageTitle] - add a new page to the website named pageName with pageTitle.")
		Commands.Add("delete_page [pageName] - delete a page from the website.")
		Commands.Add("list_pages - list all pages for the website.")
		Commands.Add("serve_page [pageName] - serve a single page to the browser.")
		Commands.Add("active_page [pageName] - activate a page to make it default. Use ? as pageName to find which page is active")
		Commands.Add("rename_page [oldPageName newPageName] - renames a page from one name to another.")
		Commands.Add("list_templates - list all templates for the active framework.")
		Commands.Add("add_element [tag elID] - add an html element to the page e.g 'add_element div row1', row1 = unique elementid, div=tag instance.")
		Commands.Add("list_elements - list all elements in the page in JSON format.")
		Commands.Add("update_element [elID element/typeof/text/value/textafter/active/tabindex value] - update an element set a particular value.")
		Commands.Add("rename_element [oelID nelID] - change the element id.")
		Commands.Add("delete_element [elID] - delete the element.")
		Commands.Add("select_element [elID] - select an and make it default.")
		Commands.Add("add_class [elID className] - add a class to an element using the element id")
		Commands.Add("delete_class [elID className] - delete a class linked to an element using the element id")
		Commands.Add("list_classes [elID] - list all classes for the element")
		Commands.Add("set_text [elID value] - update a text attribute of a component.")
		Commands.Add("set_placeholder [elID value] - update a placeholder attribute of a component.")
		Commands.Add("set_form [elID value] - update a form attribute of a component.")
		Commands.Add("set_autofocus [elID] - update a autofocus attribute of a component.")
		Commands.Add("set_required [elID] - update a required attribute of a component.")
		Commands.Add("set_tabindex [elID value] - update a tabindex attribute of a component.")
		Commands.Add("set_active [elID value] - update an active attribute of a component.")
		Commands.Add("set_value [elID value] - update a value attribute of a component.")
		Commands.Add("set_element [elID value] - update/rename the element id.")
		Commands.Add("set_name [elID value] - update the element name.")
		Commands.Add("set_list [elID value] - update the element list attribute.")
		Commands.Add("refresh_page [pageName] - refresh the page preview.")
		Commands.Add("clear_text [elID] - clear the text attribute to be blank.")
		Commands.Add("clear_name [elID] - clear the name attribute to be blank.")
		Commands.Add("clear_value [elID] - clear the value attribute to be blank.")
		Commands.Add("set_parent [elID parentlID] - set the parent element of elID to parentID")
		Commands.Add("add_div [elID] - add a div component")
		Commands.Add("add_div2 [elID parentID] - add a new div component as a child to another")
		Commands.Add("add_child [elID parentID] - add a new div component as a child to another")
		Commands.Add("set_tag [elID value] - set the tag type for this element")
		Commands.add("add_children [parentID child1 child2] - add child div chil1,child2 to parentid")
		Commands.add("add_attribute [elID attribute value] - add attribute to an element")
		Commands.add("delete_attribute [elID attribute] - delete an attribute from an element")
		Commands.Add("set_typeof [elID value] - update the tag type for the element")
		Commands.Add("set_type [elID value] - update the type attribute for the input element")
		Commands.Add("list_attributes [elID] - list all attributes for the element")
		Commands.add("add_anchor [elID href] - add an anchor to the page")
		Commands.add("set_href [elID href] - set the href to an element")
		Commands.add("set_autocomplete [elID on/off] - set the autocomplete to on/off")
		Commands.add("set_attribute [elID attrName attrValue] - set the element attribute to attrValue")
		Commands.add("add_ul [elID] - add a UL element")
		Commands.add("add_li [elID] - add a LI element")
		Commands.add("add_span [elID] - add a SPAN element")
		Commands.add("add_article [elID] - add an ARTICLE element")
		Commands.add("add_aside [elID] - add an ASIDE element")
		Commands.add("add_figcaption [elID] - add a FIGCAPTION element")
		Commands.add("add_figure [elID] - add a FIGURE element")
		Commands.add("add_footer [elID] - add a FOOTER element")
		Commands.add("add_header [elID] - add a HEADER element")
		Commands.add("add_hgroup [elID] - add a HGROUP element")
		Commands.add("add_mark [elID] - add a MARK element")
		Commands.add("add_nav [elID] - add a NAV element")
		Commands.add("add_section [elID] - add a SECTION element")
		Commands.add("add_time [elID] - add a TIME element")
		Commands.add("add_keygen [elID] - add a KEYGEN element")
		Commands.add("add_meter [elID] - add a METER element")
		Commands.add("add_summary [elID] - add a SUMMARY element")
		Commands.add("add_form [elID] - add a FORM element")
		Commands.add("add_date [elID] - add a DATE element")
		Commands.add("add_tel [elID] - add a TEL element")
		Commands.add("add_submit [elID] - add a SUBMIT input element")
		Commands.add("add_datalist [elID] - add a DATALIST input element")
		Commands.add("add_option [elID] - add an OPTION element")
		Commands.add("add_email [elID] - add an email INPUT element")
		Commands.add("add_text [elID] - add a text INPUT element")
		Commands.add("add_number [elID] - add a number INPUT element")
		Commands.add("set_min [elID value] - set the min attribute to an element")
		Commands.add("set_max [elID value] - set the max attribute to an element")
		Commands.add("set_step [elID value] - set the step attribute to an element")
		Commands.add("set_pattern [elID value] - set the pattern attribute to an element")
		Commands.add("add_datetime [elID] - add a DATETIME input element")
		Commands.add("add_week [elID] - add a WEEK input element")
		Commands.add("add_month [elID] - add a MONTH input element")
		Commands.add("add_time [elID] - add a TIME input element")
		Commands.add("add_datetimelocal [elID] - add a DATETIME-LOCAL input element")
		Commands.add("set_low [elID value] - set the low attribute to an element")
		Commands.add("set_high [elID value] - set the high attribute to an element")
		Commands.add("set_optimum [elID value] - set the optimum attribute to an element")
		Commands.add("add_progress [elID] - add a PROGRESS element")
		Commands.add("set_datetime [elID value] - set the datetime attribute to an element")
		Commands.add("add_video [elID] - add a VIDEO element")
		Commands.add("add_audio [elID] - add a AUDIO element")
		Commands.add("set_width [elID value] - set the width attribute to an element")
		Commands.add("set_height [elID value] - set the height attribute to an element")
		Commands.add("set_autoplay [elID value] - set the autoplay attribute to an element")
		Commands.add("set_poster [elID value] - set the poster attribute to an element")
		Commands.add("set_source [elID value] - set the source attribute to an element")
		Commands.add("set_src [elID value] - set the src attribute to an element")
		Commands.add("add_button [elID] - add a BUTTON element")
		Commands.add("add_canvas [elID] - add a CANVAS element")
		Commands.add("add_file [elID] - add a FILE element")
		Commands.add("add_password [elID] - add a PASSWORD input element")
		Commands.add("add_url [elID] - add a URL input element")
		Commands.add("add_color [elID] - add a COLOR input element")
		Commands.add("add_search [elID] - add a SEARCH input element")
		Commands.add("add_textarea [elID] - add a TEXTAREA element")
		Commands.add("add_checkbox [elID] - add a CHECKBOX input element")
		Commands.add("add_radio [elID] - add a RADIO input element")
		Commands.add("add_label [elID] - add a LABEL element")
		Commands.add("add_select [elID] - add a SELECT element")
		Commands.add("add_styleclass [classname category] - add a class to the framework classes")
		Commands.add("copy_element [source target] - copy an element from one to another")
				
		'Commands.Add("98. You can use 'create' in the place of 'add'")
		'Commands.Add("97. You can use 'component' in the place of 'element'")
		'Commands.Add("96. You can use 'select' in the place of 'list'")
		'Commands.Add("95. You can use 'select' in the place of 'active'")
		Commands.Sort(True)
		AddCommand("help")
		Return True
	Case "copy_element","copyelement","copy_component","copycomponent"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Copy Element Error","The expected command to copy an element is " & CRLF & CRLF & "'copy_element [source target]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim elid1 As String = spParts(2)
			Copy_Element(elid,elid1)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "add_styleclass","addstyleclass"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Add Style Error","The expected command to add a style is " & CRLF & CRLF & "'add_styleclass [classname category]'")
				Return False
			End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim elid As String = spParts(1)
				Dim elclass As String = jMash.MvRest(" ",sCommand,3)
				Add_StyleClass(elid,elclass)
			Else
				AppSQLNotInitialized
			End If
			Return True
	
	Case "delete_attribute","deleteattribute","delete_property","deleteproperty","remove_attribute","remove_property","removeattribute","removeproperty"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Delete Attribute Error","The expected command to delete an attribute to an element is " & CRLF & CRLF & "'delete_attribute [row1 attribute]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim elclass As String = spParts(2)
			Delete_Attribute(elid,elclass)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "add_attribute","addattribute","setattribute","setproperty","addproperty","add_property","set_attribute","set_property"
		If spParts.Length < 4 Then
			jMash.MsgBoxWarn(frm,"Add Attribute Error","The expected command to add an attribute to an element is " & CRLF & CRLF & "'add_attribute [elID attribute value]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim propname As String = spParts(2)
			Dim propvalue As String = jMash.MvRest(" ",sCommand,4)
			Add_Attribute(elid,propname,propvalue)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "list_classes","select_classes","listclasses","selectclasses"
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"List Classes Error","The expected command to list classes for an element is " & CRLF & CRLF & "'list_classes [row1]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			List_Classes(elid)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "list_attributes","listattributes","select_attributes","selectattributes","listproperties","list_properties"
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"List Attributes Error","The expected command to list attributes for an element is " & CRLF & CRLF & "'list_attributes [row1]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			List_Attributes(elid)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "set_parent","setparent"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Set Parent Error","The expected command to set an element parent is " & CRLF & CRLF & "'set_parent [elID parentID]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim elclass As String = spParts(2)
			Set_Parent(elid,elclass)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "delete_class","deleteclass","removeclass","remove_class"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Delete Class Error","The expected command to delete a class to an element is " & CRLF & CRLF & "'delete_class [row1 className]'")
			Return False
		End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim elid As String = spParts(1)
				Dim elclass As String = jMash.MvRest(" ",sCommand,3)
				elclass = elclass.trim
				Dim spClasses() As String = jMash.StrParse(" ",elclass)
				For Each strClass As String In spClasses
					Delete_Class(elid,strClass)
				Next
			Else
				AppSQLNotInitialized
			End If
			Return True
	Case "add_class","create_class","addclass","createclass"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Add Class Error","The expected command to add a class to an element is " & CRLF & CRLF & "'add_class [row1 className]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim elclass As String = jMash.MvRest(" ",sCommand,3)
			elclass = elclass.trim
			Dim spClasses() As String = jMash.StrParse(" ",elclass)
			For Each strClass As String In spClasses
				Log(strClass)
				Add_Class(elid,strClass)
			Next
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "select_element","select_component","selectelement","selectcomponent"
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Select Element Error","The expected command to select an element is " & CRLF & CRLF & "'select_element row1'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Select_Element(elid)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "delete_element","delete_component","deleteelement","deletecomponent","remove_element","remove_component","removeelement","removecomponent"
		If spParts.Length < 2 Then
			jMash.MsgBoxWarn(frm,"Delete Element Error","The expected command to delete an element is " & CRLF & CRLF & "'delete_element [row1]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = jMash.MvRest(" ",sCommand,1)
			Dim spElements() As String = jMash.StrParse(" ",elid)
			For Each strEL As String In spElements
				Delete_Element(strEL)
			Next
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "clear_text","clear_name","clear_value","cleartext","clearname","clearvalue"
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Clear Element Property Error","The expected command is " & CRLF & CRLF & "'clear_??? row1'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim sExec As String = spParts(0)
			sExec = sExec.Replace("clear_","")
			sExec = sExec.Replace("clear","")
			Dim elid As String = spParts(1)
			sCommand = $"update_element ${elid} ${sExec}"$
			Log(sCommand)
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "set_tag","settag"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Set Tag Element Error","The expected command to set the element tag is " & CRLF & CRLF & "'set_tag row1 div'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim tagtype As String = spParts(2)
			sCommand = $"update_element ${elid} typeof ${tagtype}"$
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
			End If
			Return True
	Case "settabindex"
			If spParts.Length < 3 Then
				jMash.MsgBoxWarn(frm,"Set TabIndex Error","The expected command to set tabindex an element is " & CRLF & CRLF & "'set_tabindex row1 value'")
				Return False
			End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim sExec As String = spParts(0)
				sExec = sExec.Replace("set_","")
				Dim elid As String = spParts(1)
				Dim elprop As String = jMash.MvRest(" ",sCommand,3)
				sCommand = $"update_element ${elid} tabindex ${elprop}"$
				Update_Element(sCommand)
			Else
				AppSQLNotInitialized
			End If
			Return True
	
	Case "setvalue"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Set Vallue Element Error","The expected command to set value an element is " & CRLF & CRLF & "'set_value row1 value'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim sExec As String = spParts(0)
			sExec = sExec.Replace("set_","")
			Dim elid As String = spParts(1)
			Dim elprop As String = jMash.MvRest(" ",sCommand,3)
			sCommand = $"update_element ${elid} value ${elprop}"$
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "settext"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Set Text Error","The expected command to set text an element is " & CRLF & CRLF & "'set_text row1 value'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim sExec As String = spParts(0)
			sExec = sExec.Replace("set_","")
			Dim elid As String = spParts(1)
			Dim elprop As String = jMash.MvRest(" ",sCommand,3)
			sCommand = $"update_element ${elid} text ${elprop}"$
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
			End If
			Return True
		Case "setname"
			If spParts.Length < 3 Then
				jMash.MsgBoxWarn(frm,"Set Name Error","The expected command to set name an element is " & CRLF & CRLF & "'set_name row1 value'")
				Return False
			End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim sExec As String = spParts(0)
				sExec = sExec.Replace("set_","")
				Dim elid As String = spParts(1)
				Dim elprop As String = jMash.MvRest(" ",sCommand,3)
				sCommand = $"update_element ${elid} name ${elprop}"$
				Update_Element(sCommand)
			Else
				AppSQLNotInitialized
			End If
			Return True

	Case "set_text","set_tabindex","set_active","set_value","set_typeof","set_element","set_name"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Update Element Error","The expected command to update an element is " & CRLF & CRLF & "'set_??? row1 ??? ???'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim sExec As String = spParts(0)
			sExec = sExec.Replace("set_","")
			Dim elid As String = spParts(1)
			Dim elprop As String = jMash.MvRest(" ",sCommand,3)
			sCommand = $"update_element ${elid} ${sExec} ${elprop}"$
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "rename_element","rename_component","renameelement","renamecomponent"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Rename Element Error","The expected command to rename an element is " & CRLF & CRLF & "'rename_element row1 row2'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim oldid As String = spParts(1)
			Dim newid As String = spParts(2)
			sCommand = $"update_element ${oldid} element ${newid}"$
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "update_element","update_component","updateelement","updatecomponent"
		If spParts.Length <> 4 Then
				jMash.MsgBoxWarn(frm,"Update Element Error","The expected command to update an element for a page is " & CRLF & CRLF & "'update_element [row1 element/typeof/text/value/textafter/active/tabindex value]'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Update_Element(sCommand)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "list_elements","list_components","select_elements","select_components","listelements","listcomponents","selectelements","selectcomponents"
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			List_Elements
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "addclasses","add_classes"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Add Classes Error","The expected command to add classes for elements is " & CRLF & CRLF & "'add_classes class el1 el2 el3 el4'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim sclass As String = spParts(1)
			Dim children As String = jMash.MvRest(" ",sCommand,3)
			Dim spChildren() As String = jMash.StrParse(" ",children)
			For Each strChild As String In spChildren
				strChild = strChild.Trim
				If strChild <> "" Then
					wait for (ExecuteCommand(frm,$"addclass ${strChild} ${sclass}"$)) complete(Result As Boolean)
				End If
			Next
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "add_children","addchildren"
		If spParts.Length < 3 Then
			jMash.MsgBoxWarn(frm,"Add Children Error","The expected command to add children inside another element is " & CRLF & CRLF & "'add_children parentID child1 child2 child3 child4'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			'addchildren parent child1 child2 child3 child4
			Dim parentid As String = spParts(1)
			Dim children As String = jMash.MvRest(" ",sCommand,3)
			Dim spChildren() As String = jMash.StrParse(" ",children)
			For Each strChild As String In spChildren
				strChild = strChild.Trim
				If strChild <> "" Then
					wait for (ExecuteCommand(frm,$"addchild ${strChild} ${parentid}"$)) complete(Result As Boolean)
				End If
			Next
		Else
			AppSQLNotInitialized
		End If
			Return True
	Case "set_autocomplete","setautocomplete", _
		"set_list","setlist","set_max","setmax","set_min","setmin", _
		"set_step","setstep","set_pattern","setpattern","set_datetime", _
		"setdatetime","set_optimum","setoptimum","set_high","sethigh", _
		"set_low","setlow","set_href","sethref","set_form","setform", _
		"set_placeholder","setplaceholder", "set_poster","setposter", _
		"set_width","setwidth","set_height","setheight","set_source","setsource", _
		"set_controls","setcontrols","set_loop","setloop", "set_autobuffer","setautobuffer", _
		"set_src","setsrc"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Attribute","The expected command to set the attribute is " & CRLF & CRLF & "'set_[attribute] elID value'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			acceptedCommand = acceptedCommand.Replace("set_","")
			acceptedCommand = acceptedCommand.Replace("set","")
			Dim elid As String = spParts(1)
			Dim value As String = jMash.mvrest(" ",sCommand,3)
			Add_Attribute(elid,acceptedCommand,value)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "set_autoplay","setautoplay"
			If spParts.Length < 2 Then
				jMash.MsgBoxWarn(frm,"Set AutoPlay Error","The expected command to set the autoplay is " & CRLF & CRLF & "'set_autoplay elID'")
				Return False
			End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim elid As String = spParts(1)
				Add_Attribute(elid,"autoplay","autoplay")
			Else
				AppSQLNotInitialized
			End If
			Return True
	Case "set_autofocus","setautofocus"
			If spParts.Length < 2 Then
				jMash.MsgBoxWarn(frm,"Set AutoFocus Error","The expected command to set the autofocus is " & CRLF & CRLF & "'set_autofocus elID'")
				Return False
			End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim elid As String = spParts(1)
				Add_Attribute(elid,"autofocus","autofocus")
			Else
				AppSQLNotInitialized
			End If
			Return True
	Case "set_required","setrequired"
			If spParts.Length < 2 Then
				jMash.MsgBoxWarn(frm,"Set Required Error","The expected command to set the required is " & CRLF & CRLF & "'set_required elID'")
				Return False
			End If
			AddCommand(sCommand)
			If AppSQL.IsInitialized Then
				Dim elid As String = spParts(1)
				Add_Attribute(elid,"required","required")
			Else
				AppSQLNotInitialized
			End If
			Return True
	Case "add_option","addoption"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"option")
		Add_Attribute(elid,"value",elid)
		Return True
	Case "add_email","addemail"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","email")
		Return True
	Case "add_color","addcolor"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","color")
		Return True
	Case "add_textarea","addtextarea"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"textarea")
		Return True
	Case "add_select","addselect"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"select")
		Return True
	Case "add_label","addlabel"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"label")
		Add_Attribute(elid,"for",elid)
		Return True
	Case "add_radio","addradio"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","radio")
		Add_Attribute(elid,"name",elid)
		Add_Attribute(elid,"value",elid)
		Return True
	Case "add_checkbox","addcheckbox"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","checkbox")
		Return True
	Case "add_search","addsearch"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","search")
		Return True
	Case "add_url","addurl"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","url")
		Return True
	Case "add_password","addpassword"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","password")
		Return True
	Case "add_file","addfile"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","file")
		Return True
	Case "add_number","addnumber"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","number")
		Return True
	Case "add_text","addtext"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","text")
		Return True
	Case "add_submit","addsubmit"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","submit")
		Return True
	Case "add_tel","addtel"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","tel")
		Return True
	Case "add_date","adddate"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","date")
			Return True
	Case "add_time","addtime"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","time")
		Return True
	Case "add_week","addweek"
			Dim elid As String = spParts(1)
			AddElement(frm,sCommand,"input")
			Add_Attribute(elid,"type","week")
			Return True
	Case "add_month","addmonth"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","month")
		Return True
	Case "add_datetimelocal","adddatetimelocal"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","datetime-local")
		Return True
	Case "add_range","addrange"
		Dim elid As String = spParts(1)
		AddElement(frm,sCommand,"input")
		Add_Attribute(elid,"type","range")
		Return True
	Case "add_datetime","adddatetime"
			Dim elid As String = spParts(1)
			AddElement(frm,sCommand,"input")
			Add_Attribute(elid,"type","datetime")
			Return True
	Case "add_anchor","addanchor","create_anchor","createanchor"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Add Anchor Error","The expected command to add an achor is " & CRLF & CRLF & "'add_anchor elID href'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim elid As String = spParts(1)
			Dim href As String = spParts(2)
			Add_Element("a",elid)
			Add_Attribute(elid,"href",href)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "add_div2","adddiv2","add_child","addchild"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Add Div2 Error","The expected command to add a div inside another element is " & CRLF & CRLF & "'add_div2 elID parentID'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim instance As String = "div"
			Dim elid As String = spParts(1)
			Dim parentid As String = spParts(2)
			Add_Element(instance,elid)
			wait for (ExecuteCommand(frm,$"setparent ${elid} ${parentid}"$)) complete(Result As Boolean)
		Else
			AppSQLNotInitialized
		End If
		Return True
		Case "add_li","addli","add_span","addspan","add_ul","addul","add_article","addarticle", _
			"add_aside","addaside","add_figcaption","addfigcaption","add_figure","addfigure", _
			"add_footer","addfooter","add_header","addheader","add_hgroup","addhgroup", _
			"add_mark","addmark","add_nav","addnav","add_section","addsection","add_time","addtime", _
			"add_keygen","addkeygen","add_meter","addmeter","add_summary","addsummary", "add_form","addform","add_progress","addprogress", _
			"add_video","addvideo","add_button","addbutton","add_audio","addaudio","add_canvas","addcanvas"
		Dim selx As String = acceptedCommand.Replace("add_","")
		selx = selx.Replace("add","")
		AddElement(frm,sCommand,selx)
		Return True
	Case "add_div","adddiv"
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Add Div Error","The expected command to add a div element to a page is " & CRLF & CRLF & "'add_div row1'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim instance As String = "div"
			Dim elid As String = spParts(1)
			Add_Element(instance,elid)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "add_element","create_element","add_component","create_component","addelement","createelement","addcomponent","createcomponent"
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Add Element Error","The expected command to add an element to a page is " & CRLF & CRLF & "'add_element div row1'")
			Return False
		End If
		AddCommand(sCommand)
		If AppSQL.IsInitialized Then
			Dim instance As String = spParts(1)
			Dim elid As String = spParts(2)
			Add_Element(instance,elid)
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "list_templates","select_templates","listtemplates","selecttemplates"
		AddCommand(sCommand)
		List_Templates
		Return True
	Case "rename_page","renamepage"
			'rename the page
			If spParts.Length <> 3 Then
				jMash.MsgBoxWarn(frm,"Rename Page Error","The expected command to rename a page is " & CRLF & CRLF & "'rename_page oldPageName newPageName'")
				Return False
			End If
			AddCommand(sCommand)
			Dim oldPage As String = spParts(1)
			Dim newPage As String = spParts(2)
			'does the page exist
			If AppSQL.IsInitialized Then
				Rename_Page(oldPage,newPage)
			Else
				AppSQLNotInitialized
			End If
			Return True
	Case "active_page","select_page","refresh_page","activepage","selectpage","refreshpage"
		'make a page active so we can add components to it
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Active Page Error","The expected command to activate a page is " & CRLF & CRLF & "'active_page pageName'")
			Return False
		End If
		PageName = spParts(1)
		AddCommand(sCommand)
		Select Case PageName
		Case "?"
			'get the active page
			PageName = jMash.GetSimple("active_page")
			If PageName = "" Then
				AddCommand("There is NO ACTIVE page, run the same command with a pagename to set an active page.")
			Else
				AddCommand("The ACTIVE page name is '" & PageName & "'")
			End If
		Case Else
			'does the page exist
			If AppSQL.IsInitialized Then
				If DBUtils.RecordExists(AppSQL,"Pages","PageName",PageName) = True Then
					Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}.${PageName}': page has been set as default."$)
					jMash.putsimple("active_page",PageName)
					jMash.putsimple("active_element","")
					Main.Page_Preview(PageName)
				Else
					AddCommand($"ERROR: Page '${PageName}' COULD NOT be found"$)
				End If
			Else
				AppSQLNotInitialized
			End If
		End Select
		Return True
	Case "serve_page","servepage"
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Serve Page Error","The expected command to serve a page is " & CRLF & CRLF & "'serve_page pageName'")
			Return False
		End If
		PageName = spParts(1)
		AddCommand(sCommand)
		If AppSQL.IsInitialized = True Then
			If DBUtils.RecordExists(AppSQL,"Pages","PageName",PageName) = True Then
				If AppIsThere = True Then
					Main.App_PreparePublish
					wait for (Main.Page_Build(PageName)) complete(Result As Boolean)
					App.OpenPage(PageName)
					Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}.${PageName}': Preparing to serve the page."$)
					Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}.${PageName}': Preparing the page."$)
					Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}.${PageName}': Serving the page."$)
				End If
			Else
				PageNotFound(PageName)
			End If
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "list_pages","select_pages","listpages","selectpages"
		AddCommand(sCommand)
		If AppSQL.IsInitialized = True Then
			List_Pages
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "delete_page","deletepage"
		'delete a page from the website
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Delete Page Error","The expected command to delete new page is " & CRLF & CRLF & "'delete_page pageName'")
			Return False
		End If
		AddCommand(sCommand)
		PageName = spParts(1)
		If AppSQL.IsInitialized Then
			If DBUtils.RecordExists(AppSQL,"Pages","PageName",PageName) = False Then
				AddCommand($"ERROR: '${PageName}' DOES NOT exist."$)
			Else
				Delete_Page(PageName)
			End If
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "add_page","create_page","addpage","createpage"
		'add a page to the app
		If spParts.Length <> 3 Then
			jMash.MsgBoxWarn(frm,"Add Page Error","The expected command to add a new page is " & CRLF & CRLF & "'add_page pageName pageTitle'")
			Return False
		End If
		PageName = spParts(1)
		PageTitle = spParts(2)
		Commands.Add($"${jMash.LongDateTimeToday}: ${sCommand}."$)
		If AppSQL.IsInitialized = True Then
			If DBUtils.RecordExists(AppSQL,"Pages","PageName",PageName) = True Then
				AddCommand($"ERROR: Page '${PageName}' already exists"$)
			Else
				Add_Page(PageName,PageTitle)
			End If
		Else
			AppSQLNotInitialized
		End If
		Return True
	Case "create"
		'create contacts com.Mashy.Contacts Contacts
		If spParts.Length <> 4 Then
			jMash.MsgBoxWarn(frm,"Create App Error","The expected command to create a new app is " & CRLF & CRLF & "'create appName appID appTitle'")
			Return False	
		End If
		Commands.Add($"${jMash.LongDateTimeToday}: ${sCommand}."$)
		AppName = spParts(1)
		AppID = spParts(2)
		AppTitle = spParts(3)
		CreateNewApp(AppName,AppID,AppTitle)
		Return True
	Case "serve"
		'build and serve the app
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Serve Error","The expected command to serve an app is " & CRLF & CRLF & "'serve appName'")
			Return False
		End If
		Commands.Add($"${jMash.LongDateTimeToday}: ${sCommand}."$)
		AppName = spParts(1)
		If AppIsThere = True Then
			Main.App_PreparePublish
			Main.App_pages
			App.open
			Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}': Preparing to serve the application."$)
			Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}': Preparing pages."$)
			Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}': Serving the website."$)
			jMash.putobject("lastproject",AppMap)
		End If
		Return True
	Case "cd"
		'change directory
		If spParts.Length <> 2 Then
			jMash.MsgBoxWarn(frm,"Change Directory Error","The expected command to change directory is " & CRLF & CRLF & "'cd appName'")
			Return False
		End If
		Commands.Add($"${jMash.LongDateTimeToday}: ${sCommand}."$)
		AppName = spParts(1)
		If	AppIsThere = True Then
			Main.app_read
			Main.CLI_Show
			jMash.putobject("lastproject",AppMap)
		End If
		Return True
	Case Else
		jMash.MsgBoxWarn(frm,"CLI Command","The command you have entered could not be understood.")
		Return False
	End Select
End Sub

Sub AddElement(frm As Form, sCommand As String, sType As String)
	Dim spParts() As String = jMash.StrParse(" ",sCommand)
	If spParts.Length <> 2 Then
		jMash.MsgBoxWarn(frm,$"Add ${sType.touppercase} Error"$, $"The expected command to add the ${sType.touppercase} element to a page is ${CRLF & CRLF}'add_${sType.tolowercase} [elID]'"$)
		Return
	End If
	AddCommand(sCommand)
	If AppSQL.IsInitialized Then
		Dim instance As String = sType.tolowercase
		Dim elid As String = spParts(1)
		Add_Element(instance,elid)
	Else
		AppSQLNotInitialized
	End If	
End Sub

Sub AppIsThere As Boolean
	If AppName = "" Then Return False
	'check the directory
	AppPath = File.DirApp & "\Projects\" & AppName
	AppDB = AppPath & "\" & AppName & ".db"
	If File.Exists(AppPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}' application found..."$)
	Else
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}' application DOES NOT exist."$)
		Return False
	End If
	If File.Exists(AppPath,AppName & ".db") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}' database found..."$)
	Else
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}' database DOES NOT exist."$)
		Return False
	End If
	'open the database and read the contents
	Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}' application is now active."$)
	AppSQL.InitializeSQLite("",AppDB,True)
	AppMap = DBUtils.ReadRecord(AppSQL,"App","id","1")
	App_GetDetails
	Return True
End Sub

Sub AppSQL_Prepare
	'create the necessary tables for the internal runnings on OneEvery
	DBUtils.InitializeNewTable("App","id","id")
	DBUtils.AddFieldOfText("properties",False,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	'create the pages table
	DBUtils.InitializeNewTable("Pages","id","id")
	DBUtils.AddFieldOfText("PageName",True,True)
	DBUtils.AddFieldOfText("Title",True,False)
	DBUtils.AddFieldOfText("Description",False,False)
	DBUtils.AddFieldOfInteger("TabIndex",True,False)
	DBUtils.AddFieldOfInteger("Active",True,False)
	DBUtils.AddFieldOfText("HtmlName",False,False)
	DBUtils.AddFieldOfText("Keywords",False,False)
	DBUtils.AddFieldOfText("HasHeader",False,False)
	DBUtils.AddFieldOfText("HasFooter",False,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	'create jsfiles
	DBUtils.InitializeNewTable("JSFiles","id","id")
	DBUtils.AddFieldOfText("Framework",True,False)
	DBUtils.AddFieldOfText("file",True,False)
	DBUtils.AddFieldOfInteger("Active",True,False)
	DBUtils.AddFieldOfInteger("TabIndex",True,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	'create css files
	DBUtils.InitializeNewTable("CSSFiles","id","id")
	DBUtils.AddFieldOfText("Framework",True,False)
	DBUtils.AddFieldOfText("file",True,False)
	DBUtils.AddFieldOfInteger("Active",True,False)
	DBUtils.AddFieldOfInteger("TabIndex",True,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	'create the components table
	DBUtils.InitializeNewTable("Components","id","id")
	DBUtils.AddFieldOfInteger("Active",True,False)
	DBUtils.AddFieldOfInteger("TabIndex",True,False)
	DBUtils.AddFieldOfText("PageName",True,False)
	DBUtils.AddFieldOfText("Key",True,True)
	DBUtils.AddFieldOfText("Element",True,False)
	DBUtils.AddFieldOfText("TypeOf",True,False)
	DBUtils.AddFieldOfText("Text",True,False)
	DBUtils.AddFieldOfText("Name",True,False)
	DBUtils.AddFieldOfText("Value",True,False)
	DBUtils.AddFieldOfInteger("TextAfter",True,False)
	DBUtils.AddFieldOfInteger("ParentID",True,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	
	DBUtils.InitializeNewTable("Attributes","id","id")
	DBUtils.AddFieldOfInteger("ElementID",True,False)
	DBUtils.AddFieldOfText("PageName",True,False)
	DBUtils.AddFieldOfText("Element",True,False)
	DBUtils.AddFieldOfText("Attribute",True,False)
	DBUtils.AddFieldOfText("DefaultValue",False,False)
	DBUtils.AddFieldOfText("IsFile",False,False)
	DBUtils.AddFieldOfText("Key",True,True)
	DBUtils.AddFieldOfInteger("Active",True,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	'create the classes tables, these are linked to elements
	DBUtils.InitializeNewTable("Classes","id","id")
	DBUtils.AddFieldOfText("PageName",True,False)
	DBUtils.AddFieldOfText("Element",True,False)
	DBUtils.AddFieldOfInteger("ElementID",True,False)
	DBUtils.AddFieldOfText("Class",True,False)
	DBUtils.AddFieldOfText("Key",True,True)
	DBUtils.AddFieldOfInteger("Active",True,False)
	DBUtils.CreateTableFromDefinition(AppSQL)
	
End Sub

Sub VerifyDatabase
	If DBUtils.TableExists(AppSQL,"App") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: 'App' table created successfully."$)
	End If
	If DBUtils.TableExists(AppSQL,"Pages") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: 'Pages' table created successfully."$)
	End If
	If DBUtils.TableExists(AppSQL,"JSFiles") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: 'JSFiles' table created successfully."$)
	End If
	If DBUtils.TableExists(AppSQL,"CSSFiles") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: 'CSSFiles' table created successfully."$)
	End If
	If DBUtils.RecordExists(AppSQL,"App","id","1") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: '${AppName}' details added successfully."$)
	End If
	If DBUtils.RecordExists(AppSQL,"Pages","PageName","index") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: 'index.html' page added successfully."$)
	End If
	For Each strFile As String In cssFiles
		If DBUtils.RecordExists(AppSQL,"CSSFiles","file",strFile) = True Then
			Commands.Add($"${jMash.LongDateTimeToday}: '${strFile}' CSS file link added successfully."$)
		End If
	Next
	For Each strFile As String In jFiles
		If DBUtils.RecordExists(AppSQL,"JSFiles","file",strFile) = True Then
			Commands.Add($"${jMash.LongDateTimeToday}: '${strFile}' JS file link added successfully."$)
		End If
	Next
End Sub

Sub CreateNewApp(sappName As String, sAppID As String, sAppTitle As String)
	AppName = sappName
	AppID = sAppID
	AppTitle = sAppTitle
	AppMap.Initialize
	AppMap.Put("appname",AppName)
	AppMap.Put("sitetitle", sAppTitle)
	AppMap.Put("appid", sAppID)
	AppMap.Put("framework","Bootstrap")
	AppMap.Put("version","1.00")
	AppMap.Put("author","")
	AppMap.Put("website","")
	AppMap.Put("email","")
	AppMap.Put("copyrights","")
	AppMap.Put("usefontawesome","1")
	'create the necessary details for the app
	App.Initialize(AppName,AppID,"1.00")
	jMash.putobject("lastproject",AppMap)
	AppPath = App.AppPath
	'create the database for OneEvery project
	AppDB = AppPath & "\" & AppName & ".db"
	'create it if necessary
	AppSQL.InitializeSQLite("",AppDB,True)
	'create the needed tables
	AppSQL_Prepare
	File.MakeDir(AppPath,"Code")
	CodePath = AppPath & "\Code"
	'save the project details
	AppJSON = jMash.Map2Json(AppMap)
	Dim rec As Map = CreateMap("id":1,"properties":AppJSON)
	DBUtils.AddEditRecord(AppSQL,"App","id","1",rec)
	'add the index page
	Dim index As Map = CreateMap("PageName":"index","HtmlName":"index.html","Active":1,"Title":AppTitle,"Description":"Home Page", _
	"TabIndex":1,"Keywords":AppTitle & ";index;home")
	DBUtils.AddEditRecord(AppSQL,"Pages","PageName","index",index)
	'add the bootstrap css files
	'add the bootstrap js files
	
	Dim tbIndex As Int = 0
	For Each csFile As String In cssFiles
		tbIndex = tbIndex + 1
		Dim cssFilesM As Map
		cssFilesM.Initialize
		cssFilesM.Put("Framework","Bootstrap")
		cssFilesM.Put("file",csFile)
		cssFilesM.Put("Active","1")
		cssFilesM.Put("TabIndex",tbIndex)
		DBUtils.AddEditRecord(AppSQL,"CSSFiles","file",csFile,cssFilesM)
	Next
		
	tbIndex = 0
	For Each jsFile As String In jFiles
		tbIndex = tbIndex + 1
		Dim jsMap As Map
		jsMap.Initialize
		jsMap.Put("Framework","Bootstrap")
		jsMap.Put("file",jsFile)
		jsMap.Put("Active","1")
		jsMap.Put("TabIndex",tbIndex)
		DBUtils.AddEditRecord(AppSQL,"JSFiles","file",jsFile,jsMap)
	Next
	'check if everything is proper
	VerifyApp
	VerifyDatabase
End Sub

Sub VerifyApp
	Commands.Initialize
	Dim dir As String = File.GetFileParent(AppDB)
	Dim fil As String = File.GetName(AppDB)
	If File.Exists(App.AppPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${App.apppath} directory created successfully."$)
	End If
	If File.Exists(App.wwwPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${App.wwwPath} directory created successfully."$)
	End If
	If File.Exists(App.FullFontsPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${App.FullFontsPath} directory created successfully."$)
	End If
	If File.Exists(App.FullCSSPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${App.FullCSSPath} directory created successfully."$)
	End If
	If File.Exists(App.FullJSPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${App.FullJSPath} directory created successfully."$)
	End If
	If File.Exists(App.FullImgPath,"") = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${App.FullImgPath} directory created successfully."$)
	End If
	If File.Exists( dir,fil) = True Then
		Commands.Add($"${jMash.LongDateTimeToday}: ${AppDB} SQLite database created successfully."$)
	End If
End Sub