B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Public el As HTMLElement
	Public ID As String
	Public Page As HTMLPage
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(pg As HTMLPage,sid As String)
	Page = pg
	ID = sid.tolowercase
	el.Initialize(ID,"div")
End Sub

Public Sub HTML As String
	
End Sub