B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
' Version 6.60
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	DB = Main.DB
	App = Main.App
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	Log($"${Method}: ${Path}"$)
	If Path = "/categories" Then
		RenderPage
	Else If Path = "/hx/categories/table" Then
		HandleTable
	Else If Path = "/hx/categories/add" Then
		HandleAddModal
	Else If Path.StartsWith("/hx/categories/edit/") Then
		HandleEditModal
	Else If Path.StartsWith("/hx/categories/delete/") Then
		HandleDeleteModal
	Else
		HandleCategories
	End If
End Sub

Private Sub RenderPage
	If App.ctx.ContainsKey("/categories") = False Then
		Dim main1 As MainView
		main1.Initialize
		main1.LoadContent(ContentContainer)
		main1.LoadModal(ModalContainer)
		main1.LoadToast(ToastContainer)

		Dim page1 As MiniHtml = main1.Render
		Dim ulist1 As MiniHtml = GetUList(page1)
		Dim list1 As MiniHtml = MH.Li.up(ulist1)
		list1.cls("nav-item d-block d-lg-block")
		Dim a1 As MiniHtml = MH.Anchor.up(list1)
		a1.attr("href", "/")
		a1.cls("nav-link float-end")
		a1.text("Home")
		Dim i1 As MiniHtml = MH.Icon.up(a1)
		i1.cls("bi bi-house me-2")
		i1.attr("title", "Home")

		'' Sample for adding additional menu link
		'Dim list2 As MiniHtml = MH.Li.up(ulist1)
		'list2.cls("nav-item d-block d-lg-block")
		'Dim a2 As MiniHtml = MH.Anchor.up(list2)
		'a2.attr("href", "/users")
		'a2.cls("nav-link float-end")
		'a2.text("Users")
		'Dim i2 As MiniHtml = MH.Icon.up(a2)
		'i2.cls("bi bi-tag me-2")
		'i2.attr("title", "Users")

		If App.api.EnableHelp Then
			Dim list3 As MiniHtml = MH.Li.up(ulist1)
			list3.cls("nav-item d-block d-lg-block")
			Dim a3 As MiniHtml = MH.Anchor.up(list3)
			a3.attr("href", "/help")
			a3.cls("nav-link float-end")
			a3.text("API")
			Dim i3 As MiniHtml = MH.Icon.up(a3)
			i3.cls("bi bi-gear me-2")
			i3.attr("title", "API")
		End If
	
		Dim doc As MiniHtml
		doc.Initialize("")
		doc.Write("<!DOCTYPE html>")
		doc.Write(page1.build)
		App.ctx.Put("/categories", doc.ToString)
	End If
	App.WriteHtml2(Response, App.ctx.Get("/categories"), App.ctx)
End Sub

' Retrieve ulist tag from DOM
Private Sub GetUList (dom As MiniHtml) As MiniHtml
	Dim body1 As MiniHtml = dom.Child(1)
	Dim nav1 As MiniHtml = body1.Child(1)
	Dim container1 As MiniHtml = nav1.Child(0)
	Dim navbar1 As MiniHtml = container1.Child(3)
	Dim ulist1 As MiniHtml = navbar1.Child(0)
	Return ulist1
End Sub

Private Sub ContentContainer As MiniHtml
	Dim row1 As MiniHtml = MH.Div
	row1.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As MiniHtml = MH.Div.up(row1)
	col1.cls("col-md-12 col-lg-6")
	Dim form1 As MiniHtml = MH.Form.up(col1)
	form1.cls("form mb-3")
	form1.attr("action", "")
	Dim row2 As MiniHtml = MH.Div.up(form1)
	row2.cls("row")
	Dim col2 As MiniHtml = MH.Div.up(row2)
	col2.cls("col-md-6 col-lg-6 text-start")
	Dim h31 As MiniHtml = MH.H3.up(col2)
	h31.text("CATEGORY LIST")
	Dim div1 As MiniHtml = MH.Div.up(row2)
	div1.cls("col-md-6 col-lg-6")
	Dim div2 As MiniHtml = MH.Div.up(div1)
	div2.cls("text-end mt-2")

	Dim button2 As MiniHtml = MH.Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.attr("hx-get", "/hx/categories/add")
	button2.attr("hx-target", "#modal-content")
	button2.attr("hx-trigger", "click")
	button2.attr("data-bs-toggle", "modal")
	button2.attr("data-bs-target", "#modal-container")
	MH.Icon.up(button2).cls("bi bi-plus-lg me-2")
	button2.text("Add Category")

	Dim container1 As MiniHtml = MH.Div.up(col1)
	container1.attr("id", "categories-container")
	container1.attr("hx-get", "/hx/categories/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")

	Return row1
End Sub

Private Sub ModalContainer As MiniHtml
	Dim container1 As MiniHtml = MH.Div
	container1.attr("id", "modal-container")
	container1.cls("modal fade")
	container1.attr("tabindex", "-1")
	container1.attr("aria-hidden", "true")
	Dim dialog1 As MiniHtml = MH.Div.up(container1)
	dialog1.cls("modal-dialog modal-dialog-centered")
	Dim content1 As MiniHtml = MH.Div.up(dialog1)
	content1.cls("modal-content")
	content1.attr("id", "modal-content")
	Return container1
End Sub

Private Sub ToastContainer As MiniHtml
	Dim div1 As MiniHtml = MH.Div.cls("position-fixed end-0 p-3")
	div1.sty("z-index: 2000")
	div1.sty("bottom: 0%")
	Dim toast1 As MiniHtml = MH.Div.up(div1)
	toast1.attr("id", "toast-container")
	toast1.cls("toast align-items-center text-bg-success border-0")
	toast1.attr("role", "alert")
	Dim div2 As MiniHtml = MH.Div.up(toast1)
	div2.cls("d-flex")
	Dim div3 As MiniHtml = MH.Div.up(div2)
	div3.cls("toast-body")
	div3.attr("id", "toast-body")
	div3.text("Operation successful!")
	Dim button1 As MiniHtml = MH.Button.up(div2)
	button1.attr("type", "button")
	button1.cls("btn-close btn-close-white me-2 m-auto")
	button1.attr("data-bs-dismiss", "toast")
	Return div1
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CreateCategoriesTable.build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-post", "/hx/categories")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Add Category")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader) 
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")

	Dim modalBody As MiniHtml = MH.Div.up(form1)
	modalBody.cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	
	Dim group1 As MiniHtml = MH.Div.up(modalBody).cls("form-group")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "name").text("Name ")
	Dim span1 As MiniHtml = MH.Span.up(label1)
	span1.cls("text-danger").text("*")
	MH.Input.attr("type", "text").up(group1).attr("id", "name").attr("name", "name").cls("form-control").required

	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	Dim button1 As MiniHtml = MH.Button.up(modalFooter)
	button1.attr("type", "submit")
	button1.cls("btn btn-success px-3")
	button1.text("Create")
	Dim button2 As MiniHtml = MH.Button.up(modalFooter)
	button2.attr("type", "button")
	button2.cls("btn btn-secondary px-3")
	button2.attr("data-bs-dismiss", "modal")
	button2.text("Cancel")
	
	App.WriteHtml(Response, form1.build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Try
		Dim id As Int = Path.SubString("/hx/categories/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try

	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		DB.Close
		Return
	End If
	If DB.Found Then
		Dim name As String = DB.First.Get("category_name")
	End If
	DB.Close
	
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-put", "/hx/categories")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")

	Dim modalHeader As MiniHtml = MH.Div.up(form1)
	modalHeader.cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Edit Category")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader)
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")
		
	Dim modalBody As MiniHtml = MH.Div.up(form1)
	modalBody.cls("modal-body")
	Dim div1 As MiniHtml = MH.Div.up(modalBody)
	div1.attr("id", "modal-messages")
	Dim id1 As MiniHtml = MH.Input.up(modalBody)
	id1.attr("type", "hidden")
	id1.attr("name", "id")
	id1.attr("value", id)
	
	Dim group1 As MiniHtml = MH.Div.up(modalBody)
	group1.cls("form-group")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "name")
	label1.text("Name ")
	Dim span1 As MiniHtml = MH.Span.up(label1)
	span1.cls("text-danger").text("*")
	Dim input1 As MiniHtml = MH.Input.up(group1)
	input1.attr("type", "text")
	input1.cls("form-control")
	input1.attr("id", "name")
	input1.attr("name", "name")
	input1.attr("value", name)
	input1.required

	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	Dim button1 As MiniHtml = MH.Button.up(modalFooter)
	button1.attr("type", "submit")
	button1.cls("btn btn-primary px-3")
	button1.text("Update")
	Dim button2 As MiniHtml = MH.Button.up(modalFooter)
	button2.attr("type", "button")
	button2.cls("btn btn-secondary px-3")
	button2.attr("data-bs-dismiss", "modal")
	button2.text("Cancel")

	App.WriteHtml(Response, form1.build)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Try
		Dim id As Int = Path.SubString("/hx/categories/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		DB.Close
		Return
	End If
	If DB.Found Then
		Dim name As String = DB.First.Get("category_name")
	End If
	DB.Close
	
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-delete", "/hx/categories")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Delete Category")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader)
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")
		
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	Dim div1 As MiniHtml = MH.Div.up(modalBody)
	div1.attr("id", "modal-messages")
	Dim input1 As MiniHtml = MH.Input.attr("type", "hidden")
	input1.attr("name", "id")
	input1.attr("value", id)
	input1.up(modalBody)
	MH.P.up(modalBody).text($"Delete ${name}?"$)

	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	Dim button1 As MiniHtml = MH.Button.up(modalFooter)
	button1.attr("type", "submit")
	button1.cls("btn btn-danger px-3")
	button1.text("Delete")
	Dim button2 As MiniHtml = MH.Button.up(modalFooter)
	button2.attr("type", "button")
	button2.cls("btn btn-secondary px-3")
	button2.attr("data-bs-dismiss", "modal")
	button2.text("Cancel")

	App.WriteHtml(Response, form1.build)
End Sub

' Handle CRUD operations
Private Sub HandleCategories
	Select Method
		Case "POST"
			' Create
			Dim name As String = Request.GetParameter("name")
			If name = "" Or name.Trim.Length < 2 Then
				ShowAlert("Category name must be at least 2 characters long.", "warning")
				Return
			End If
			DB.Open
			DB.Table = "tbl_categories"
			DB.Conditions = Array("category_name = ?")
			DB.Parameters = Array(name)
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			If DB.Found Then
				ShowAlert("Category already exists!", "warning")
				DB.Close
				Return
			End If
			' Insert new row
			DB.Table = "tbl_categories"
			DB.Columns = Array("category_name", "created_date")
			DB.Parameters = Array(name, Main.CurrentDateTime)
			DB.Save
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			ShowToast("Category", "created", "Category created successfully!", "success")
			DB.Close
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			DB.Open
			DB.Table = "tbl_categories"
			DB.Find(id)
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			If DB.Found = False Then
				ShowAlert("Category not found!", "warning")
				DB.Close
				Return
			End If
			DB.Table = "tbl_categories"
			DB.Conditions = Array("category_name = ?", "id <> ?")
			DB.Parameters = Array(name, id)
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			If DB.Found Then
				ShowAlert("Category already exists!", "warning")
				DB.Close
				Return
			End If
			' Update row
			DB.Table = "tbl_categories"
			DB.Columns = Array("category_name", "modified_date")
			DB.Parameters = Array(name, Main.CurrentDateTime)
			DB.Id = id
			DB.Save
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			ShowToast("Category", "updated", "Category updated successfully!", "info")
			DB.Close
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.Open
			DB.Table = "tbl_categories"
			DB.Find(id)
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			If DB.Found = False Then
				ShowAlert("Category not found!", "warning")
				DB.Close
				Return
			End If
			DB.Table = "tbl_products"
			DB.Condition = "category_id = ?"
			DB.Parameter = id
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			If DB.Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				DB.Close
				Return
			End If
			' Delete row
			DB.Table = "tbl_categories"
			DB.Id = id
			DB.Delete
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				DB.Close
				Return
			End If
			ShowToast("Category", "deleted", "Category deleted successfully!", "danger")
			DB.Close
	End Select
End Sub

Private Sub CreateCategoriesTable As MiniHtml
	If App.ctx.ContainsKey("/hx/categories/table") = False Then
		Dim table1 As MiniHtml = MH.Table
		table1.cls("table table-bordered table-hover rounded small")
		Dim thead1 As MiniHtml = MH.Thead.up(table1).cls("table-light")
		MH.Th.up(thead1).text("#").sty("text-align: right; width: 50px")
		MH.Th.up(thead1).text("Name")
		MH.Th.up(thead1).text("Actions").sty("text-align: center; width: 120px")
		MH.Tbody.up(table1)
		App.ctx.Put("/hx/categories/table", table1)
	End If
	
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name")
	DB.OrderBy = CreateMap("id": "DESC")
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
	End If
	Dim rows As List = DB.Results
	DB.Close
	
	Dim table1 As MiniHtml = App.ctx.Get("/hx/categories/table")
	Dim tbody1 As MiniHtml = table1.Child(1)
	tbody1.Children.Clear ' remove all children
	For Each row As Map In rows
		Dim tr1 As MiniHtml = CreateCategoriesRow		
		tr1.Child(0).text2(row.Get("id"))
		tr1.Child(1).text2(row.Get("category_name"))
		tr1.Child(2).Child(0).attr("hx-get", "/hx/categories/edit/" & row.Get("id"))
		tr1.Child(2).Child(1).attr("hx-get", "/hx/categories/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	Return table1
End Sub

Private Sub CreateCategoriesRow As MiniHtml
	If App.ctx.ContainsKey("/categories/table/row") = False Then
		Dim tr1 As MiniHtml = MH.Tr
		Dim td1 As MiniHtml = MH.Td.up(tr1)
		td1.cls("align-middle").sty("text-align: right").text("$id$")
		Dim td2 As MiniHtml = MH.Td.up(tr1)
		td2.cls("align-middle").text("$name$")
		Dim td3 As MiniHtml = MH.Td.up(tr1)
		td3.cls("align-middle text-center px-1 py-1")
		
		Dim a1 As MiniHtml = MH.Anchor.up(td3)
		a1.cls("edit text-primary mx-2")
		a1.attr("hx-get", "/hx/categories/edit/$id$")
		a1.attr("hx-target", "#modal-content")
		a1.attr("hx-trigger", "click")
		a1.attr("data-bs-toggle", "modal")
		a1.attr("data-bs-target", "#modal-container")
		MH.Icon.up(a1).cls("bi bi-pencil")
		a1.attr("title", "Edit")
		
		Dim a2 As MiniHtml = MH.Anchor.up(td3)
		a2.cls("delete text-danger mx-2")
		a2.attr("hx-get", "/hx/categories/delete/$id$")
		a2.attr("hx-target", "#modal-content")
		a2.attr("hx-trigger", "click")
		a2.attr("data-bs-toggle", "modal")
		a2.attr("data-bs-target", "#modal-container")
		MH.Icon.up(a2).cls("bi bi-trash3")
		a2.attr("title", "Delete")

		App.ctx.Put("/categories/table/row", tr1.ConvertToBytes)
	End If
	Return MH.ConvertFromBytes(App.ctx.Get("/categories/table/row"))
End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As MiniHtml = MH.Div
	div1.cls("alert alert-" & status)
	div1.text(message)
	App.WriteHtml(Response, div1.build)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As MiniHtml = MH.Div
	div1.attr("id", "categories-container")
	div1.attr("hx-swap-oob", "true")
	CreateCategoriesTable.up(div1)

	Dim script1 As MiniJs
	script1.Initialize
	script1.AddCustomEventDispatch("entity:changed", _
	CreateMap( _
	"entity": entity, _
	"action": action, _
	"message": message, _
	"status": status))

	App.WriteHtml(Response, div1.build & CRLF & script1.Generate)
End Sub