B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Public DBTypes As List
End Sub

Sub Initialize
	DBTypes.Initialize
	DBTypes.Add("")
	DBTypes.Add("MySQL")
	DBTypes.Add("SQLite")
End Sub