B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Web Handler class
'Version 6.00alpha
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
	'Private Method As String
	'Private Elements() As String
	'Private start As Long = DateTime.Now
End Sub

Public Sub Initialize
	App = Main.App
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	
	'Log(Request.RequestURI)
	Select Request.RequestURI
		Case "/"
			ReturnPage
			'Response.Write("It took: ").Write(DateTime.Now - start).Write(" ms to create this page.")
		Case "/table"
			ReturnTable
			'Response.Write("It took: ").Write(DateTime.Now - start).Write(" ms to create this page.")
	End Select
	
	
'	Method = Request.Method.ToUpperCase
'	Elements = WebApiUtils.GetUriElements(Request.RequestURI)
'	If App.MethodAvailable2(Method, "", Me) = False Then
'		WebApiUtils.ReturnHtml("<h1>405 Method Not Allowed</h1>", Response)
'		Return
'	End If
'	If Elements.Length = 0 Then
'		ReturnPage
'		Return
'	End If
'	WebApiUtils.ReturnHtmlPageNotFound(Response)

End Sub

Private Sub ReturnPage
	'Dim strScripts As String
	'Dim strMain As String = WebApiUtils.ReadTextFile("main.html")
	'Dim strView As String = WebApiUtils.ReadTextFile("index.html")
	'strMain = WebApiUtils.BuildDocView(strMain, strView)
	''strMain = WebApiUtils.BuildTag(strMain, "HELP", ReturnHelpElement)
	'strMain = WebApiUtils.BuildHtml(strMain, App.ctx)
	'strScripts = $"<script src="${App.ServerUrl}/assets/scripts/search.js"></script>"$
	'strMain = WebApiUtils.BuildScript(strMain, strScripts)
	'WebApiUtils.ReturnHTML(strMain, Response)
	
	Dim main1 As MainView
	main1.Initialize
	Dim view1 As IndexView
	view1.Initialize
	main1.LoadView2(view1.Render)
	
	Dim page1 As Tag = main1.Render
	'Dim body1 As Tag = page1.ChildByTagName("body")
	'body1.script($"${App.ServerUrl}/assets/scripts/search.js"$)
	Dim body1 As Tag = page1.ChildByTagName("body")
	body1.script("$SERVER_URL$/assets/js/htmx.min.js")
	
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)

	Dim strMain As String = doc.ToString
	strMain = WebApiUtils.BuildHtml(strMain, App.ctx)
	WebApiUtils.ReturnHtml(strMain, Response)
	'Response.Write("It took: ").Write(DateTime.Now - start).Write(" ms to create this page.")
End Sub

Private Sub ReturnTable
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim table1 As Tag = HtmlTable.cls("table table-bordered rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Code"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.text("Category"))
	thead1.add(Th.sty("text-align: right").text("Price"))
	thead1.add(Th.sty("text-align: center; width: 90px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)
	
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products p"
	' Construct results with new column name alias
	DB.Select = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	For Each row As Map In DB.Results2
		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(row.Get("id")))
		tr1.add(Td.cls("align-middle").text(row.Get("code")))
		tr1.add(Td.cls("align-middle").text(row.Get("name")))
		tr1.add(Td.cls("align-middle").text(row.Get("category")))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(row.Get("price")))
		Dim td1 As Tag = tr1.add(Td.init)
		Dim anchor1 As Tag = td1.add(Anchor.href("#edit").cls("edit text-primary mx-2").data("bs-toggle", "modal"))
		Dim icon1 As Tag = anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		icon1.data("bs-toggle", "tooltip") _
		.data("bs-id", row.Get("id")) _
		.data("bs-name", row.Get("name")) _
		.attr("title", "Edit")
		
		Dim anchor2 As Tag = td1.add(Anchor.href("#delete").cls("delete text-danger mx-2").data("bs-toggle", "modal"))
		Dim icon2 As Tag = anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		icon2.data("bs-toggle", "tooltip") _
		.data("bs-id", row.Get("id")) _
		.data("bs-name", row.Get("name")) _
		.attr("title", "Delete")
	Next
	DB.Close
	WebApiUtils.ReturnHtml(table1.Build, Response)
End Sub

'Private Sub ReturnHelpElement As String
'	Dim Api As ApiSettings = App.api
'	If Api.EnableHelp = False Then
'		Return ""
'	End If
'	Return $"${CRLF & TAB & TAB}<li class="nav-item mt-1 ml-3">
'${TAB & TAB & TAB}<a class="nav-link font-weight-bold text-dark mr-3" href="${App.ServerUrl}/help"><i class="fas fa-cog mr-2" title="API"></i>API</a>
'${TAB & TAB}</li>"$
'End Sub