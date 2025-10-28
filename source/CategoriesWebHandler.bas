B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Web Handler class
'Version 6.00alpha
Sub Class_Globals
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private main1 As MainView
	Private view1 As CategoryView
End Sub

Public Sub Initialize
	App = Main.App
	main1.Initialize
	view1.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Select Request.RequestURI
		Case "/categories"
			RenderPage
		Case "/categories/table"
			view1.RenderTable(Response)
		Case "/categories/list"
			view1.RenderDropdown(Response)
	End Select
End Sub

Private Sub RenderPage
	main1.LoadView2(view1.Render)
	Dim page1 As Tag = main1.Render
	Dim body1 As Tag = page1.ChildByTagName("body")
	body1.script("$SERVER_URL$/assets/js/htmx.min.js")
	
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)

	Dim strMain As String = WebApiUtils.BuildHtml(doc.ToString, App.ctx)
	WebApiUtils.ReturnHtml(strMain, Response)
End Sub