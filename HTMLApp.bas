B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6
@EndOfDesignText@
'Class module
Sub Class_Globals
	Public Copyrights As String
	Public Version As String
	Public Author As String
	Public Website As String
	Public Email As String
	Public AppID As String
	Public AppPath As String
	Public AppName As String
	Public CSSPath As String
	Public JSPath As String
	Public FontsPath As String
	Public ImagesPath As String
	Public CSSFiles As Map
	Public JSFiles As Map
	Public wwwPath As String
	Public SiteTitle As String
	Public FullCSSPath As String
	Public FullJSPath As String
	Public FullImgPath As String
	Public FullFontsPath As String
	Public AppTitle As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(sAppName As String, sAppID As String, sAppVersion As String)
	If sAppName = "" Or sAppID = "" Or sAppVersion = "" Then Return
	AppID = sAppID
	Version = sAppVersion
	AppName = sAppName
	'create the css and js folders to host the files
	AppPath = File.DirApp & "\Projects\" & AppName
	wwwPath = "Projects\" & AppName & "\www"
	JSPath = wwwPath & "\js"
	CSSPath = wwwPath & "\css"
	FontsPath = wwwPath & "\fonts"
	ImagesPath = wwwPath & "\img"
	'create the project folder and respective folders
	File.MakeDir(File.dirapp,"Projects\" & AppName)
	File.MakeDir(File.dirapp,wwwPath)
	File.MakeDir(File.dirapp,JSPath)
	File.MakeDir(File.dirapp,CSSPath)
	File.MakeDir(File.dirapp,FontsPath)
	File.MakeDir(File.dirapp,ImagesPath)
	'set the full paths
	FullCSSPath = File.Combine(File.DirApp,CSSPath)
	FullJSPath = File.Combine(File.DirApp,JSPath)
	FullImgPath = File.Combine(File.DirApp,ImagesPath)
	FullFontsPath = File.Combine(File.DirApp,FontsPath)
	CSSFiles.Initialize
	JSFiles.Initialize
	'we are using the bootstrap framework
	'PrepareBootStrap
	wwwPath = File.DirApp & "\" & wwwPath
End Sub

'add a javascript file applicable to app
Sub AddJavaScriptFile(jsFile As String)
	JSFiles.Put(jsFile,jsFile)
End Sub

'add a css file applicable to app
Sub AddCssFile(cssFile As String)
	CSSFiles.put(cssFile,cssFile)
End Sub

Sub AddFontAwesome
	AddCssFile("fonts/font-awesome-4.7.0/css/font-awesome.min.css")
End Sub

Sub Build
	'Dim pages As List = DBUtils.ExecuteMaps(appsql
	'For Each strPage As HTMLPage In Pages.Values
		
	'Next
End Sub

'open the app in a browser
Sub Open
	Dim robot As AWTRobot
	robot.SystemOpenExternalFile(wwwPath & "\index.html")
End Sub

'open a single page
Sub OpenPage(sPage As String)
	Dim robot As AWTRobot
	robot.SystemOpenExternalFile(wwwPath & $"\${sPage}.html"$)
End Sub