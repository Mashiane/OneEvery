B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.01
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Private frm As Form
	Private txtArguements As TextField
	Private txtMacroCommands As CodeArea
	Private txtMacroName As TextField
	Private txtValues As TextField
	Private btnExecute As Button
	Private btnPreview As Button
	Private btnDeleteMacro As Button
	Private btnSaveMacro As Button
	Private Dlg As DialogsX
	Private txtDescription As TextField
End Sub


Sub Close
	frm.close
End Sub


Public Sub Show(ParentForm As Form)
	frm.Initialize("frm",800, 800)
	frm.Resizable = False
	frm.RootPane.LoadLayout("vMacro")
	frm.Title = "Macros"
	ReadMacro
	frm.SetOwner(ParentForm)
	Dlg.Initialize
	Dlg.SetParentWindow(ParentForm)
	frm.ShowAndWait
End Sub

Sub ReadMacro
	Dim macro As Map
	macro = jMash.GetObject("macro")
	If macro.IsInitialized Then
		Dim smacro As String = macro.GetDefault("macro","")
		Dim sargue As String = macro.GetDefault("arguements","")
		Dim scommand As String = macro.GetDefault("macrocode","")
		Dim sdescription As String = macro.GetDefault("description","")
		scommand = scommand.Replace("|",CRLF)
		txtArguements.Text = sargue
		txtMacroName.Text = smacro
		txtDescription.Text = sdescription
		jMash.CodeAreaSetText(txtMacroCommands,scommand,"1",False)
	End If
End Sub

Sub btnPreview_Click
	
End Sub

Sub btnExecute_Click
	
End Sub

Sub btnSaveMacro_Click
	Dim sCode As String = txtMacroCommands.GetText
	If jMash.IsBlank(Dlg,txtMacroName.Text,"Macro Name") = True Then Return
	If jMash.IsBlank(Dlg,sCode,"Macro Code") = True Then Return
	
	sCode = sCode.Replace(CRLF,"|")
	Dim skey As String = $"${CLI.Framework}.${txtMacroName.text}"$
	Dim macro As Map = CreateMap("macro":txtMacroName.Text, _
	"arguements":txtArguements.Text, _
	"description":txtDescription.Text, _
	"framework":CLI.framework, _ 
	"key":skey, _
	"macrocode":sCode)
	DBUtils.AddEditRecord(Main.InternalSQL,"Macros","key",skey,macro)	
	If DBUtils.RecordExists(Main.InternalSQL,"Macros","key",skey) = True Then
		jMash.MsgBoxInform(frm,"Macro: " & txtMacroName.text,"The macro was created successfully!")
	Else
		jMash.MsgBoxInform(frm,"Macro: " & txtMacroName.text,"The macro was NOT created successfully!")
	End If
End Sub

Sub btnDeleteMacro_Click
	If jMash.IsBlank(Dlg,txtMacroName.Text,"Macro Name") = True Then Return
	Dim sKey As String = $"${CLI.framework}.${txtMacroName.text}"$
	DBUtils.RecordDelete(Main.InternalSQL,"Macros","key",sKey)
	If DBUtils.RecordExists(Main.InternalSQL,"Macros","key",sKey) = True Then
		jMash.MsgBoxInform(frm,"Macro: " & txtMacroName.text,"The macro was NOT deleted successfully!")
	Else
		jMash.MsgBoxInform(frm,"Macro: " & txtMacroName.text,"The macro was deleted successfully!")
	End If
End Sub