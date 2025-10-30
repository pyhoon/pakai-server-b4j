B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Index Handler class
' Version 6.00alpha
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = req.Method
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim path As String = req.RequestURI
	If path = "/" Then
		RenderPage
	Else If path = "/api/products/table" Then
		HandleTable
	Else If path = "/api/products/modal/add" Then
		HandleAddModal
	Else If path.StartsWith("/api/products/modal/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/api/products/modal/delete/") Then
		HandleDeleteModal
	Else
		HandleProducts
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadView2(Contents)
	Dim page1 As Tag = main1.Render
	'Dim body1 As Tag = page1.ChildByTagName("body")
	'body1.script("$SERVER_URL$/assets/js/htmx.min.js")
	
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)

	Dim strMain As String = WebApiUtils.BuildHtml(doc.ToString, App.ctx)
	WebApiUtils.ReturnHtml(strMain, Response)
End Sub

' Use list for multiple tags with no parent tag
Public Sub Contents As List
	Dim Tags As List
	Tags.Initialize
	Tags.Add(ContentContainer)
	Tags.Add(GitHubLink)
	Tags.Add(ModalContainer)
	Tags.Add(ToastContainer)
	Return Tags
End Sub

Private Sub ContentContainer As Tag
	Dim content1 As Tag = Div.cls("row mt-3") ' text-center align-items-center justify-content-center
	Dim col12 As Tag = Div.cls("col-md-12").up(content1)
	Dim form1 As Tag = Form.cls("form mb-3").id("search_form").action("").up(col12)
	Dim row1 As Tag = Div.cls("row").up(form1)
	
	Dim col1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim input_group1 As Tag = col1.add(Div.cls("input-group mb-3"))
	input_group1.add(Label.forId("keyword").cls("input-group-text mt-2").text("Search"))
	input_group1.add(Input.typeOf("text").cls("form-control col-md-6 mt-2").id("keyword").name("keyword"))
	input_group1.add(Button.cls("btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2").id("btnsearch").text("Submit"))
	
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("float-end mt-2").up(col2)
	
	Dim anchor1 As Tag = div2.add(Anchor.href("$SERVER_URL$/products").cls("btn btn-primary me-2"))
	anchor1.add(Icon.cls("ti ti-menu me-2"))
	anchor1.text("Show Category")
	
	Dim anchor2 As Tag = div2.add(Anchor.cls("btn btn-success mb-2 ml-2"))
	anchor2.hxGet("/api/products/modal/add")
	anchor2.hxTarget("#modal-container")
	anchor2.add(Icon.cls("ti ti-plus me-2"))
	anchor2.text("Add Product")
	
	Dim container1 As Tag = Div.id("products-container").cls("table").up(col12)
	container1.hxGet("/api/products/table").hxTrigger("load").text("Loading...")
	Return content1
End Sub

Private Sub GitHubLink As Tag
	Dim div1 As Tag = Div.cls("text-center mb-3")
	div1.add(Anchor.href("https://github.com/pyhoon/pakai-server-b4j").cls("text-primary mr-1"))
	div1.attr("aria-label", "github").title("GitHub").targetOf("_blank")
	Dim svg1 As Tag = div1.add(Svg.aria("hidden", "true").width("24").height("24"))
	svg1.attr("version", "1.1").attr("viewBox", "0 0 16 16")
	Dim path1 As Tag = div1.add(Html.create("path"))
	path1.attr("fill-rule", "evenodd")
	path1.attr("d", "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z")
	Dim anchor1 As Tag = div1.add(Anchor.href("https://github.com/pyhoon/pakai-server-b4j").sty("text-decoration: none").targetOf("_blank"))
	anchor1.add(Span.sty("vertical-align: middle").text("Visit my GitHub repository"))
	Return div1
End Sub

Private Sub ModalContainer As Tag
	Dim modal1 As Tag = Div.id("modal-container")
	Return modal1
End Sub

Private Sub ToastContainer As Tag
	Dim toast1 As Tag = Div.id("toast-container").cls("toast-container position-fixed top-0 end-0 p-3")
	Return toast1
End Sub

' Return table HTML
Private Sub HandleTable
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query

	Dim table1 As Tag = HtmlTable.cls("table table-bordered rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Code"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.text("Category"))
	thead1.add(Th.sty("text-align: right").text("Price"))
	thead1.add(Th.sty("text-align: center; width: 90px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)

	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim code As String = row.Get("code")
		Dim name As String = row.Get("name")
		Dim category As String = row.Get("category")
		Dim price As String = row.Get("price")
		
		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(code))
		tr1.add(Td.cls("align-middle").text(name))
		tr1.add(Td.cls("align-middle").text(category))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(price))
		Dim td1 As Tag = tr1.add(Td.init)
		
		Dim anchor1 As Tag = td1.add(Anchor.cls("edit text-primary mx-2"))
		anchor1.hxGet($"/api/products/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = td1.add(Anchor.cls("delete text-danger mx-2"))
		anchor2.hxGet($"/api/products/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	WebApiUtils.ReturnHtml(table1.Build, Response)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim modal1 As Tag = Div.cls("modal fade")
	Dim modalDialog As Tag = Div.cls("modal-dialog").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim modalHeader As Tag = Div.cls("modal-header").up(modalContent)
	Dim modalBody As Tag = Div.cls("modal-body").up(modalContent)
	modalHeader.add(H5.cls("modal-title").text("Add Product"))
	'modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
	Dim form1 As Tag = Form.up(modalBody)
	form1.hxPost("/api/products")
	form1.hxTarget("#modal-container")
	form1.add(Input.typeOf("text").name("name").cls("form-control").attr3("required"))
	form1.add(Button.cls("btn btn-primary mt-2").text("Create"))
	WebApiUtils.ReturnHtml(modal1.Build, Response)	
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/api/categories/modal/edit/".Length)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Where = Array("id = ?")
	DB.Parameters = Array(id)
	DB.Query
	If DB.Found Then
		Dim name As String = DB.First.Get("name")
		Dim modal1 As Tag = Div.cls("modal fade")
		Dim modalDialog As Tag = Div.cls("modal-dialog").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
		Dim modalHeader As Tag = Div.cls("modal-header").up(modalContent)
		modalHeader.add(H5.cls("modal-title").text("Edit Product"))
		Dim modalBody As Tag = Div.cls("modal-body").up(modalContent)
		Dim form1 As Tag = Form.up(modalBody)
		form1.hxPut($"/api/products"$)
		form1.hxTarget("#modal-container")
		form1.add(Input.typeOf("hidden").name("id").valueOf(id))
		form1.add(Input.typeOf("text").name("name").valueOf(name).cls("form-control").attr3("required"))
		form1.add(Input.typeOf("button").cls("btn btn-secondary").data("bs-dismiss", "modal").valueOf("Cancel"))
		form1.add(Button.cls("btn btn-primary mt-2").text("Update"))
		WebApiUtils.ReturnHtml(modal1.Build, Response)
	End If
	DB.Close
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/api/categories/modal/delete/".Length)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Where = Array("id = ?")
	DB.Parameters = Array(id)
	DB.Query
	If DB.Found Then
		Dim name As String = DB.First.Get("name")
		Dim modal1 As Tag = Div.cls("modal fade")
		Dim modalDialog As Tag = Div.cls("modal-dialog").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
		Dim modalHeader As Tag = Div.cls("modal-header").up(modalContent)
		modalHeader.add(H5.cls("modal-title").text("Delete Product"))
		Dim modalBody As Tag = Div.cls("modal-body").up(modalContent)
		modalBody.add(Paragraph.text($"Delete ${name}?"$))
		Dim form1 As Tag = Form.up(modalBody)
		form1.hxDelete($"/api/products"$)
		form1.hxTarget("#modal-container")
		form1.add(Input.typeOf("hidden").name("id").valueOf(id))
		form1.add(Input.typeOf("button").cls("btn btn-secondary").data("bs-dismiss", "modal").valueOf("Cancel"))
		form1.add(Button.cls("btn btn-danger mt-2").text("Delete"))
		WebApiUtils.ReturnHtml(modal1.Build, Response)
	End If
	DB.Close
End Sub

' Handle CRUD operations
Private Sub HandleProducts
	Select Method
		Case "POST"
			' Create
			Dim name As String = Request.GetParameter("name")
			If name = "" Or name.Trim.Length < 2 Then
				'Response.Status = 422
				Response.Write("<script>showError('Category name must be at least 2 characters long!')</script>")
				Return
			End If
			Try
				DB.SQL = Main.DBOpen
				DB.Table = "tbl_categories"
				DB.Where = Array("category_name = ?")
				DB.Parameters = Array(name)
				DB.Query
				If DB.Found Then
					DB.Close
					'Response.Status = 409
					Response.Write("<script>showWarning('Category already exists!')</script>")
					Return
				End If
			Catch
				Log(LastException)
				'Response.Status = 500
				Response.Write("<script>showError('Database error! Please try again.')</script>")
			End Try

			' Insert new row
			DB.Reset
			DB.Columns = Array("category_name", "created_date")
			DB.Parameters = Array(name, WebApiUtils.CurrentDateTime)
			DB.Save
			DB.Close
			Response.Write("<script>closeModalAndRefresh('Category created successfully!')</script>")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_categories"
			
			DB.Find(id)
			If DB.Found = False Then
				'Response.Status = 404
            	Response.Write("<script>showError('Category not found!')</script>")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("category_name = ?", "id <> ?")
			DB.Parameters = Array(name, id)
			DB.Query
			If DB.Found Then
				'Response.Status = 409
				Response.Write("<script>showError('Category already exist')</script>")
				DB.Close
				Return
			End If
			
			' Update row
			DB.Reset
			DB.Columns = Array("category_name", "modified_date")
			DB.Parameters = Array(name, WebApiUtils.CurrentDateTime)
			DB.Id = id
			DB.Save
			DB.Close
			Response.Write("<script>closeModalAndRefresh('Category updated successfully!')</script>")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_categories"
			
			DB.Find(id)
			If DB.Found = False Then
				'Response.Status = 404
            	Response.Write("<script>showError('Category not found!')</script>")
				DB.Close
				Return
			End If
			
			DB.Table = "tbl_products"
			DB.WhereParam("category_id = ?", id)
			DB.Query
			If DB.Found Then
				'Response.Status = 409
				Response.Write("<script>showWarning('Cannot delete category with associated products!')</script>")
				DB.Close
				Return
			End If

			' Delete row
			DB.Table = "tbl_categories"
			DB.Id = id
			DB.Delete
			DB.Close
			Response.Write("<script>closeModalAndRefresh('Category deleted successfully!')</script>")
	End Select
End Sub