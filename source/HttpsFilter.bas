B4J=true
Group=Filters
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Https Filter class
'Version 6.00
Sub Class_Globals

End Sub

Public Sub Initialize

End Sub

'Return True to allow the request to proceed.
Public Sub Filter (req As ServletRequest, resp As ServletResponse) As Boolean
	If req.Secure Then
		Return True
	Else
		resp.SendRedirect(req.FullRequestURI.Replace("http:", "https:") _
       .Replace(Main.app.Port, Main.app.ssl.Port))
		Return False
	End If
End Sub