B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
' Version 6.00beta
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
	Dim form1 As Tag = Form.cls("form mb-3").action("").up(col1)
	Dim row1 As Tag = Div.cls("row").up(form1)
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6 text-start").up(row1)
	H3.text("CATEGORY LIST").up(col2)
	Dim div1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("text-end mt-2").up(div1)
	
	Dim anchor1 As Tag = div2.add(Anchor.href("$SERVER_URL$").cls("btn btn-primary mb-2 me-2"))
	anchor1.add(Icon.cls("bi bi-house me-2"))
	anchor1.text("Home")
	
	Dim anchor2 As Tag = div2.add(Anchor.cls("btn btn-success mb-2 ml-2"))
	anchor2.hxGet("/api/categories/modal/add")
	anchor2.hxTarget("#modal-container")
	anchor2.add(Icon.cls("bi bi-plus-lg me-2"))
	anchor2.text("Add Category")

	Dim container1 As Tag = Div.id("categories-container").cls("table").up(col1)
	container1.hxGet("/api/categories/table").hxTrigger("load").text("Loading...")
	
	Return content1
End Sub

Private Sub ModalContainer As Tag
	Return Div.id("modal-container")
End Sub

Private Sub ToastContainer As Tag
	Dim toast1 As Tag = Div.id("toast-container")
	toast1.cls("toast-container position-fixed end-0 p-3")
	toast1.sty("top: 10%")
	Return toast1
End Sub

' Return table HTML
Private Sub HandleTable
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query

	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	
	Dim thead1 As Tag = Thead.cls("table-light").up(table1)
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	
	Dim tbody1 As Tag = Tbody.init.up(table1)
	
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim name As String = row.Get("name")
		
		Dim tr1 As Tag = Tr.init.up(tbody1)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(name))
		
		Dim td1 As Tag = tr1.add(Td.cls("align-middle text-center px-1 py-1"))

		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/api/categories/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		anchor1.add(Icon.cls("bi bi-pencil"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/api/categories/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		anchor2.add(Icon.cls("bi bi-trash3"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	Response.Write(table1.Build)
End Sub

' Return select option HTML
Private Sub HandleList
	Dim select1 As Tag = Dropdown.cls("form-select")
	select1.attr3("required")
	select1.hxGet("/api/categories/list")
	Option.text("Select Category").attr3("disabled").up(select1)
	
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim name As String = row.Get("name")
		Option.valueOf(id).text(name).up(select1)
	Next
	DB.Close
	Response.Write(select1.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim modal1 As Tag = Div.cls("modal fade")
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)

	Dim form1 As Tag = Form.up(modalContent)
	form1.hxPost("/api/categories")
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")

	Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
	modalHeader.add(H5.cls("modal-title").text("Add Category"))
	modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))

	Dim modalBody As Tag = Div.cls("modal-body").up(form1)
	Div.id("modal-messages").up(modalBody)
	
	Dim group1 As Tag = modalBody.add(Div.cls("form-group"))
	Label.forId("name").text("Name ").up(group1).add(Span.cls("text-danger").text("*"))
	Input.typeOf("text").up(group1).id("name").name("name").cls("form-control").attr3("required")

	Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
	modalFooter.add(Button.typeOf("submit").cls("btn btn-success px-3").text("Create"))
	modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").attr("value", "Cancel"))	
	
	Response.Write(modal1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/api/categories/modal/edit/".Length)
	
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim name As String = DB.First.Get("name")
		Dim modal1 As Tag = Div.cls("modal fade")
		Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)

		Dim form1 As Tag = Form.up(modalContent)
		form1.hxPut($"/api/categories"$)
		'form1.hxTarget("#modal-container")
		form1.hxTarget("#modal-messages")
		form1.hxSwap("innerHTML")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Edit Category").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").name("id").valueOf(id).up(modalBody)
		
		Dim group1 As Tag = Div.cls("form-group").up(modalBody)
		Label.forId("name").text("Name ").up(group1).add(Span.cls("text-danger").text("*"))
		Input.typeOf("text").cls("form-control").id("name").name("name").valueOf(name).attr3("required").up(group1)

		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.cls("btn btn-primary px-3").text("Update").up(modalFooter)
		Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel").up(modalFooter)

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
	DB.WhereParam("id = ?", id)
	DB.Query
	
	If DB.Found Then
		Dim name As String = DB.First.Get("name")
		Dim modal1 As Tag = Div.cls("modal fade")
		Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)

		Dim form1 As Tag = Form.up(modalContent)
		form1.hxDelete($"/api/categories"$)
		'form1.hxTarget("#modal-container")
		form1.hxTarget("#modal-messages")
		form1.hxSwap("innerHTML")
		
		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Delete Category").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").name("id").valueOf(id).up(modalBody)
		Paragraph.text($"Delete ${name}?"$).up(modalBody)

		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.cls("btn btn-danger px-3").text("Delete").up(modalFooter)
		Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel").up(modalFooter)
		
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
				ShowAlert("warning", "Category name must be at least 2 characters long.")
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
					ShowAlert("warning", "Category already exists!")
					Return
				End If
			Catch
				Log(LastException)
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try

			' Insert new row
			Try
				DB.Reset
				DB.Columns = Array("category_name", "created_date")
				DB.Parameters = Array(name, Main.CurrentDateTime)
				DB.Save
				DB.Close
				ShowToast("success", "Category created successfully!")
			Catch
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_categories"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("warning", "Category not found!")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("category_name = ?", "id <> ?")
			DB.Parameters = Array(name, id)
			DB.Query
			If DB.Found Then
				ShowAlert("warning", "Category already exists!")
				DB.Close
				Return
			End If
			
			' Update row
			Try
				DB.Reset
				DB.Columns = Array("category_name", "modified_date")
				DB.Parameters = Array(name, Main.CurrentDateTime)
				DB.Id = id
				DB.Save
				DB.Close
				ShowToast("success", "Category updated successfully!")
			Catch
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_categories"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("warning", "Category not found!")
				DB.Close
				Return
			End If
			
			DB.Table = "tbl_products"
			DB.WhereParam("category_id = ?", id)
			DB.Query
			If DB.Found Then
				ShowAlert("warning", "Cannot delete category with associated products!")
				DB.Close
				Return
			End If

			' Delete row
			Try
				DB.Table = "tbl_categories"
				DB.Id = id
				DB.Delete
				DB.Close
				ShowToast("success", "Category deleted successfully!")
			Catch
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
	End Select
End Sub

Private Sub ShowAlert (class As String, message As String)
	Dim div1 As Tag = Div.cls("alert alert-" & class).text(message)
	Response.Write(div1.Build)
End Sub

Private Sub GenerateCategoriesTable As Tag
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.OrderBy = CreateMap("id": "")
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
		
		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/api/categories/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		anchor1.add(Icon.cls("bi bi-pencil").sty("font-size: 1.2em"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/api/categories/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		anchor2.add(Icon.cls("bi bi-trash3").sty("font-size: 1.2em"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	Return table1
End Sub

Private Sub ShowToast (class As String, message As String)
	Dim div1 As Tag = Div.id("categories-container").hxSwapOob("true")
	div1.add(GenerateCategoriesTable)
			
	Dim script1 As MiniJs
	script1.Initialize
	script1.DeclareVariable("modalElement", "document.querySelector('.modal')", True)
	script1.StartIf("modalElement")
	script1.DeclareVariable("modal", "bootstrap.Modal.getInstance(modalElement)", True)
	script1.AddConditionalCall("modal", "modal.hide();")
	script1.EndIf
	script1.AddLine("")
	Select class
		Case "success"
			script1.AddFunctionCall("showSuccess", Array As String(message))
		Case "warning"
			script1.AddFunctionCall("showWarning", Array As String(message))
		Case "danger"
			script1.AddFunctionCall("showDanger", Array As String(message))
	End Select
	Response.Write(div1.Build & CRLF & script1.Generate)
End Sub