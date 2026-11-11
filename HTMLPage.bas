B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6
@EndOfDesignText@
'Class module
Sub Class_Globals
	Public ID As String
	Public PageTitle As String
	Public Description As String
	Public KeyWords As String
	Private Head As HTMLElement
	Private Body As HTMLElement
	'Private Footer As HTMLElement
	Public Title As HTMLElement
	Private Page As HTMLElement
	'Private HasDocType As Boolean
	Private HtmlName As String
	Private App As HTMLApp
	'Public HasHeader As Boolean
	'Public HasFooter As Boolean
	'Public Header As HTMLElement
	'Private MainDiv As HTMLElement
	Public Style As HTMLElement
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(PageApp As HTMLApp, PageName As String)
	ID = PageName.tolowercase
	Page.Initialize("","html").SetLANG("en")
	HtmlName = ID & ".html"
	App = PageApp
	Body = Page.CreateBODY("")
	'HasDocType = True
	'Header.Initialize("","header").SetParent(Body)
	'Footer.Initialize("","footer").SetParent(Body)
	'MainDiv.Initialize("","main").SetParent(Body)
	Style.Initialize("","style")
End Sub

'build the HTML page
Sub Build
	'define the actual page name
	File.WriteString(App.wwwpath,HtmlName,HTML)
	'File.WriteString(File.DirTemp,HtmlName,Body.HTML)
End Sub

Sub HTML As String
	'fix the html beginning
	Page.SetPrefix("<!doctype html>")
	'create the head
	Head = Page.CreateHEAD("")
	'add the page title
	Title = Head.CreateTITLE("").AddContent(PageTitle).pop
	'add the page meta
	Head.CreateMETA("").SetCHARSET("utf-8").Pop
	'add viewport meta
	Head.CreateMETA("").SetNAME("viewport").setcontent("width=device-width, initial-scale=1, shrink-to-fit=no").pop
	Head.CreateMETA("").SetCONTENT("ie=edge").SetHTTP_EQUIV("x-ua-compatible").pop
	Head.AddMetaNameContent("msapplication-tap-highlight","no").SetParent(Head).pop
	Head.AddMetaNameContent("apple-mobile-web-app-capable","YES").pop
	Head.AddMetaNameContent("mobile-web-app-capable", "yes").pop
	Head.AddMetaNameContent("apple-mobile-web-app-title", App.AppName).pop
	Head.AddMetaNameContent("msapplication-config","none").pop
	Head.AddMetaNameContent("format-detection", "telephone=no").pop
	Head.AddMetaNameContent("playstore", "https://play.google.com/store/apps/details?id=" & App.AppID).pop
	Head.AddMetaNameContent("version", App.Version).pop
	Head.AddMetaNameContent("generator","OneEvery").pop
	Head.AddMetaNameContent("copyright", App.Copyrights).pop
	Head.AddMetaNameContent("author", App.Author).pop
	Head.AddMetaNameContent("email", App.Email).pop
	Head.AddMetaNameContent("website", App.Website).pop
	Head.AddMetaNameContent("description",Description).pop
	Head.AddMetaNameContent("keywords",KeyWords).pop
	Head.AddMetaNameContent("date", jMash.DateTimeNow).pop
	'<meta http-equiv="expires" content="Thu, 27 Jul 2017 22:00:00 GMT">
	
	'add css links to the page
	For Each cssFile As String In App.CSSFiles.keys
		If cssFile.StartsWith("http") Then
		Else
			cssFile = $"file:///${App.wwwPath.Replace("\","//")}//${cssFile.Replace("/","//")}"$
		End If
		Head.CreateLINK("").SetREL("stylesheet").SetHREF(cssFile).pop
	Next
	Style.AddContent(Style.BuildCSSRules)
	Head.AddElement(Style)
	'add the head to the htmlpage
	Head.pop
	
	'add header to body
	'If Header.Size = 0 Then 
	'	HasHeader = False
	'Else
	'	HasHeader = True
	'End If
	'add the header
	'If HasHeader = True Then Header.Pop
	'add main
	'MainDiv.pop
	'add footer
	'If Footer.Size = 0 Then 
	'	HasFooter = False
	'Else
	'	HasFooter = True
	'End If
	'If HasFooter = True Then Footer.pop
	'add javascript files to the end of the body
	For Each jsfile As String In App.JSFiles.Keys
		If jsfile.StartsWith("http") Then
		Else
			jsfile = $"file:///${App.FullJSPath.Replace("\","//")}/${jsfile.Replace("/","//")}"$
		End If
		Body.CreateSCRIPT("").SetSRC(jsfile,True).Pop
	Next
	Body.pop
	Return Page.html
End Sub

Sub AddContent(sHTML As String)
	Body.AddContent(sHTML)
End Sub

Sub AddElement(el As HTMLElement)
	Body.AddElement(el)
End Sub


