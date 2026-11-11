B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.47
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Dim sInput As String

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(sText As String)
	sInput = sText
End Sub

private Sub Transpile2(strLine As String) As String
	Dim el As HTMLElement
	el.Initialize("","")
	Dim sb As StringBuilder
	sb.Initialize 
	If strLine.EqualsIgnoreCase("JSElse") Then
		sb.Append(el.JSElse)
	else if strLine.EqualsIgnoreCase("JSEndElse") Then
		sb.Append(el.JSEndElse)
	else if strLine.EqualsIgnoreCase("JSReturn") Then
		sb.Append(el.JSReturn)
	else if strLine.EqualsIgnoreCase("JSEndSub") Then
		sb.Append(el.JSEndSub)		
	Else
		sb.Append(strLine)
	End If
	Return sb.tostring
End Sub

Public Sub Transpile() As String
	If sInput = "" Then Return ""
	'split each line
	Dim el As HTMLElement
	el.Initialize("","")
	  
	Dim spLines() As String = jMash.StrParse(CRLF,sInput)
	Dim sb As StringBuilder
	sb.Initialize
	For Each strLine As String In spLines
		strLine = strLine.trim
		If strLine.EqualsIgnoreCase("JSEqualTo") Then
			sb.Append(el.JSEqualTo)
		else if strLine.EqualsIgnoreCase("JSNotEqualTo") Then
			sb.Append(el.JSNotEqualTo)
		else if strLine.EqualsIgnoreCase("JSGreaterThan") Then
			sb.Append(el.JSGreaterThan)
		else if strLine.EqualsIgnoreCase("JSLessThan") Then
			sb.Append(el.JSLessThan)
		else if strLine.EqualsIgnoreCase("JSMultiply") Then
			sb.Append(el.JSMultiply)
		else if strLine.EqualsIgnoreCase("JSAdd") Then
			sb.Append(el.JSAdd)
		else if strLine.EqualsIgnoreCase("JSGreaterOrEqualTo") Then
			sb.Append(el.JSGreaterOrEqualTo)
		else if strLine.EqualsIgnoreCase("JSLessOrEqualTo") Then
			sb.Append(el.JSLessOrEqualTo)
		else if strLine.EqualsIgnoreCase("JSIsEqualTo") Then
			sb.Append(el.JSIsEqualTo)
		else if strLine.EqualsIgnoreCase("JSBreak") Then
			sb.Append(el.JSBreak)
		else if strLine.EqualsIgnoreCase("JSContinue") Then
			sb.Append(el.JSContinue)
		else if strLine.EqualsIgnoreCase("JSSub") Then
			sb.Append(el.JSSub)
		else if strLine.EqualsIgnoreCase("JSIf") Then
			sb.Append(el.JSIf)
		else if strLine.EqualsIgnoreCase("JSThen") Then
			sb.Append(el.JSThen)
		else if strLine.EqualsIgnoreCase("JSEndIf") Then
			sb.Append(el.JSEndIf)
		else if strLine.EqualsIgnoreCase("JSDo") Then
			sb.Append(el.JSDo)
		else if strLine.EqualsIgnoreCase("JSWhile") Then
			sb.Append(el.JSWhile)
		else if strLine.EqualsIgnoreCase("JSNL") Then
			sb.Append(el.JSNL)
		Else
			strLine = Transpile2(strLine)
			sb.Append(strLine)
		End If		
	Next
	Return sb.tostring
End Sub