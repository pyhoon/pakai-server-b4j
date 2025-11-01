B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
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
	If path = "/categories" Then
		RenderPage
	Else If path = "/api/categories/table" Then
		HandleTable
	Else If path = "/api/categories/list" Then
		HandleList
	Else If path = "/api/categories/modal/add" Then
		HandleAddModal
	Else If path.StartsWith("/api/categories/modal/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/api/categories/modal/delete/") Then
		HandleDeleteModal
	Else
		HandleCategories
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContentContainer)
	main1.LoadModal(ModalContainer)
	main1.LoadToast(ToastContainer)
	
	Dim page1 As Tag = main1.Render
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)
	Response.Write(App.ReplaceMap(doc.ToString, App.ctx))
End Sub

Private Sub ContentContainer As Tag
	Dim content1 As Tag = Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As Tag = Div.cls("col-md-12 col-lg-6").up(content1)
	Dim row1 As Tag = Form.cls("form mb-3").action("").up(col1).add(Div.cls("row"))
	Div.cls("col-md-6 col-lg-6 text-start").up(row1).add(H3.text("CATEGORY LIST"))
	Dim div1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("text-end mt-2").up(div1)
	
	Dim anchor1 As Tag = div2.add(Anchor.href("$SERVER_URL$").cls("btn btn-primary mb-2 me-2"))
	'anchor1.add(Icon.cls("ti ti-home me-2"))
	anchor1.add(Icon.cls("bi bi-house me-2"))
	anchor1.text("Home")
	
	Dim anchor2 As Tag = div2.add(Anchor.cls("btn btn-success mb-2 ml-2"))
	anchor2.hxGet("/api/categories/modal/add")
	anchor2.hxTarget("#modal-container")
	'anchor2.add(Icon.cls("ti ti-plus me-2"))
	anchor2.add(Icon.cls("bi bi-plus-lg me-2"))
	anchor2.text("Add Category")

	Dim container1 As Tag = Div.id("categories-container").cls("table").up(col1)
	container1.hxGet("/api/categories/table").hxTrigger("load").text("Loading...")
	Return content1
End Sub

Private Sub ModalContainer As Tag
	Dim modal1 As Tag = Div.id("modal-container")
	Return modal1
End Sub

Private Sub ToastContainer As Tag
	Dim toast1 As Tag = Div.id("toast-container").cls("toast-container position-fixed end-0 p-3")
	toast1.sty("top: 10%")
	Return toast1
End Sub

' Return table HTML
Private Sub HandleTable
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	
	Dim table1 As Tag = HtmlTable.cls("table table-bordered rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.sty("text-align: center; width: 90px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim name As String = row.Get("name")
		
		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(name))
		Dim td1 As Tag = tr1.add(Td.cls("text-center"))

		Dim anchor1 As Tag = td1.add(Anchor.cls("edit text-primary mx-2"))
		anchor1.hxGet($"/api/categories/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		'anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		anchor1.add(Icon.cls("bi bi-pencil").sty("font-size: 1.2em"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = td1.add(Anchor.cls("delete text-danger mx-2"))
		anchor2.hxGet($"/api/categories/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		'anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		anchor2.add(Icon.cls("bi bi-trash3").sty("font-size: 1.2em"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	'WebApiUtils.ReturnHtml(table1.Build, Response)
	Response.Write(table1.Build)
End Sub

' Return select option HTML
Private Sub HandleList
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query

	Dim select1 As Tag = Dropdown.cls("form-select").attr3("required").aria("label", "Default select example")
	select1.hxGet("/api/categories/list")
	'select1.hxTrigger("load")
	Option.text("Select Category").attr3("disabled").up(select1)
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim name As String = row.Get("name")
		Option.valueOf(id).text(name).up(select1)
	Next
	DB.Close
	'WebApiUtils.ReturnHtml(select1.Build, Response)
	Response.Write(select1.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim modal1 As Tag = Div.cls("modal fade")
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim modalHeader As Tag = Div.cls("modal-header").up(modalContent)
	Dim modalBody As Tag = Div.cls("modal-body").up(modalContent)
	modalHeader.add(H5.cls("modal-title").text("Add Category"))
	modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
	Dim form1 As Tag = Form.up(modalBody)
	form1.hxPost("/api/categories")
	form1.hxTarget("#modal-container")
	form1.add(Input.typeOf("text").name("name").cls("form-control").attr3("required"))
	form1.add(Button.cls("btn btn-primary mt-2").text("Create"))
	'WebApiUtils.ReturnHtml(modal1.Build, Response)
	Response.Write(modal1.Build)
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
		Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
		Dim modalHeader As Tag = Div.cls("modal-header").up(modalContent)
		modalHeader.add(H5.cls("modal-title").text("Edit Category"))
		Dim modalBody As Tag = Div.cls("modal-body").up(modalContent)
		Dim form1 As Tag = Form.up(modalBody)
		form1.hxPut($"/api/categories"$)
		form1.hxTarget("#modal-container")
		form1.add(Input.typeOf("hidden").name("id").valueOf(id))
		form1.add(Input.typeOf("text").name("name").valueOf(name).cls("form-control").attr3("required"))
		form1.add(Input.typeOf("button").cls("btn btn-secondary").data("bs-dismiss", "modal").valueOf("Cancel"))
		form1.add(Button.cls("btn btn-primary").text("Update"))
		'WebApiUtils.ReturnHtml(modal1.Build, Response)
		Response.Write(modal1.Build)
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
		Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
		Dim modalHeader As Tag = Div.cls("modal-header").up(modalContent)
		modalHeader.add(H5.cls("modal-title").text("Delete Category"))
		Dim modalBody As Tag = Div.cls("modal-body").up(modalContent)
		modalBody.add(Paragraph.text($"Delete ${name}?"$))
		Dim form1 As Tag = Form.up(modalBody)
		form1.hxDelete($"/api/categories"$)
		form1.hxTarget("#modal-container")
		form1.add(Input.typeOf("hidden").name("id").valueOf(id))
		form1.add(Input.typeOf("button").cls("btn btn-secondary").data("bs-dismiss", "modal").valueOf("Cancel"))
		form1.add(Button.cls("btn btn-danger").text("Delete"))
		'WebApiUtils.ReturnHtml(modal1.Build, Response)
		Response.Write(modal1.Build)
	End If
	DB.Close
End Sub

' Handle CRUD operations
Private Sub HandleCategories
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
			DB.Parameters = Array(name, Main.CurrentDateTime)
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
			DB.Parameters = Array(name, Main.CurrentDateTime)
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