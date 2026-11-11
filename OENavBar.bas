B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Public Title As String
	Public HasSearch As Boolean
	Private el As HTMLElement
	Private Page As HTMLPage
	Public ID As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(pg As HTMLPage, sid As String)
	Page = pg
	ID = sid.ToLowerCase
	el.Initialize(ID,"nav").AddClass("navbar navbar-expand-md navbar-light bg-faded fixed-top")
End Sub

Sub HTML As String
Dim nav As String = $"<a class="navbar-brand" href="#">${Title}</a>
<ul class="nav navbar-nav">
<li class="nav-item active">
<a class="nav-link" href="index.html">Home</a>
</li>
<li class="nav-item">
<a class="nav-link" href="about.html">About</a>
</li>
<li class="nav-item">
<a class="nav-link" href="contact.html">Contact</a>
</li>
</ul>"$
el.addcontent(nav)
If HasSearch = True Then el.AddContent(Search)
Return el.html
End Sub

private Sub Search As String
Dim str As String = $"<form class="form-inline pull-xs-right">
<input class="form-control" type="text" placeholder="Search">
<button class="btn btn-primary" type="submit">Search</button>
</form>"$
Return str
End Sub
