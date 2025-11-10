B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Index Handler class
' Version 6.00
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
	Else If path = "/api/products/search" Then
		HandleSearch
	Else If path = "/api/products/add" Then
		HandleAddModal
	Else If path.StartsWith("/api/products/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/api/products/delete/") Then
		HandleDeleteModal
	Else
		HandleProducts
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContentContainer)
	main1.LoadSubContent(GitHubLink)
	main1.LoadModal(ModalContainer)
	main1.LoadToast(ToastContainer)

	Dim page1 As Tag = main1.Render
	Dim body1 As Tag = page1.Child(1)
	Dim nav1 As Tag = body1.Child(1)
	Dim container1 As Tag = nav1.Child(0)
	Dim navbar1 As Tag = container1.Child(3)
	Dim ulist1 As Tag = navbar1.Child(0)
	Dim list1 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor1 As Tag = Anchor.href("/categories").up(list1)
	anchor1.cls("nav-link")
	anchor1.text("Categories")

	' Sample for adding additional menu link
	'Dim list2 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
	'Dim anchor2 As Tag = Anchor.href("/users").up(list1)
	'anchor2.cls("nav-link")
	'anchor2.text("Users")

	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)
	App.WriteHtml2(Response, doc.ToString, App.ctx)
End Sub

Private Sub ContentContainer As Tag
	Dim content1 As Tag = Div.cls("row mt-3")
	Dim col12 As Tag = Div.cls("col-md-12").up(content1)
	Dim form1 As Tag = Form.cls("form mb-3").up(col12)
	Dim row1 As Tag = Div.cls("row").up(form1)
	Dim col1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)

	Dim input_group1 As Tag = col1.add(Div.cls("input-group mb-3"))
	input_group1.add(Label.forId("keyword").cls("input-group-text mt-2").text("Search"))
	input_group1.add(Input.typeOf("text").cls("form-control col-md-6 mt-2").id("keyword").name("keyword"))

	Dim searchBtn As Tag = input_group1.add(Button.cls("btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2").text("Submit"))
	searchBtn.hxPost("/api/products/search")
	searchBtn.hxTarget("#products-container")
	searchBtn.hxSwap("innerHTML")

	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("float-end mt-2").up(col2)

	'Dim anchor1 As Tag = Anchor.up(div2)
	'anchor1.hrefOf("$SERVER_URL$/categories")
	'anchor1.cls("btn btn-primary me-2")
	'anchor1.add(Icon.cls("bi bi-list me-2"))
	'anchor1.text("Show Category")

	Dim button2 As Tag = Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.hxGet("/api/products/add")
	button2.hxTarget("#modal-content")
	button2.hxTrigger("click")
	button2.data("bs-toggle", "modal")
	button2.data("bs-target", "#modal-container")
	button2.add(Icon.cls("bi bi-plus-lg me-2"))
	button2.text("Add Product")

	Dim container1 As Tag = Div.up(col12)
	container1.id("products-container")
	container1.hxGet("/api/products/table")
	container1.hxTrigger("load")
	container1.text("Loading...")
	
	Return content1
End Sub

Private Sub GitHubLink As Tag
	Dim div1 As Tag = Div.cls("text-center mb-3")
	Dim anchor1 As Tag = Anchor.up(div1)
	anchor1.hrefOf("https://github.com/pyhoon/pakai-server-b4j")
	anchor1.cls("text-primary mr-1")
	anchor1.aria("label", "github").attr("title", "GitHub").targetOf("_blank")
	Dim svg1 As Tag = Svg.up(anchor1)
	svg1.aria("hidden", "true")
	svg1.width("24").height("24")
	svg1.attr("version", "1.1")
	svg1.attr("viewBox", "0 0 16 16")
	Dim path1 As Tag = Html.create("path").up(svg1)
	path1.attr("fill-rule", "evenodd")
	path1.attr("d", "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z")
	Dim anchor2 As Tag = Anchor.up(div1)
	anchor2.hrefOf("https://github.com/pyhoon/pakai-server-b4j")
	anchor2.sty("text-decoration: none")
	anchor2.targetOf("_blank")
	Span.sty("vertical-align: middle").text("Visit Pakai GitHub repository").up(anchor2)
	Return div1
End Sub

Private Sub ModalContainer As Tag
	Dim modal1 As Tag = Div.id("modal-container")
	modal1.cls("modal fade")
	modal1.attr("tabindex", "-1")
	modal1.aria("hidden", "true")
	Dim modalDialog As Tag = Div.up(modal1).cls("modal-dialog modal-dialog-centered")
	Div.cls("modal-content").id("modal-content").up(modalDialog)
	Return modal1
End Sub

Private Sub ToastContainer As Tag
	Dim div1 As Tag = Div.cls("position-fixed end-0 p-3")
	div1.sty("z-index: 2000")
	div1.sty("bottom: 0%")
	Dim toast1 As Tag = Div.id("toast-container").up(div1)
	toast1.cls("toast align-items-center text-bg-success border-0")
	toast1.attr("role", "alert")
	Dim div2 As Tag = Div.cls("d-flex").up(toast1)
	Dim div3 As Tag = Div.cls("toast-body").id("toast-body").up(div2)
	div3.text("Operation successful!")
	Dim button1 As Tag = Button.typeOf("button").up(div2)
	button1.cls("btn-close btn-close-white me-2 m-auto")
	button1.data("bs-dismiss", "toast")
	Return div1
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CreateProductsTable.Build)
End Sub

' Search product using keyword
Private Sub HandleSearch
	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Code"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.text("Category"))
	thead1.add(Th.sty("text-align: right").text("Price"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)

	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name AS name", "p.product_price price")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	Dim keyword As String = Request.GetParameter("keyword")
	If keyword <> "" Then
		DB.Where = Array("p.product_code LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?")
		DB.Parameters = Array("%" & keyword & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim code As String = row.Get("code")
		Dim name As String = row.Get("name")
		Dim price As Double = row.Get("price")
		Dim category As String = row.Get("category")

		Dim tr1 As Tag = Tr.init.up(tbody1)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(code))
		tr1.add(Td.cls("align-middle").text(name))
		tr1.add(Td.cls("align-middle").text(category))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(NumberFormat2(price, 1, 2, 2, True)))
		Dim td1 As Tag = tr1.add(Td.cls("align-middle text-center px-1 py-1"))

		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/api/products/edit/${id}"$)
		anchor1.hxTarget("#modal-content")
		anchor1.hxTrigger("click")
		anchor1.data("bs-toggle", "modal")
		anchor1.data("bs-target", "#modal-container")
		anchor1.add(Icon.cls("bi bi-pencil"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/api/products/delete/${id}"$)
		anchor2.hxTarget("#modal-content")
		anchor2.hxTrigger("click")
		anchor2.data("bs-toggle", "modal")
		anchor2.data("bs-target", "#modal-container")
		anchor2.add(Icon.cls("bi bi-trash3"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	App.WriteHtml(Response, table1.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim form1 As Tag = Form.init
	form1.hxPost("/api/products")
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")

	Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
	modalHeader.add(H5.cls("modal-title").text("Add Product"))
	modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
	
	Dim modalBody As Tag = Div.cls("modal-body").up(form1)
	Div.id("modal-messages").up(modalBody)
	
	Dim group1 As Tag = Div.cls("form-group").up(modalBody)
	Label.forId("category1").text("Category ").up(group1).add(Span.cls("text-danger").text("*"))
	
	Dim select1 As Tag = CreateCategoriesDropdown(-1)
	select1.id("category1")
	select1.name("category")
	select1.up(group1)

	Dim group2 As Tag = Div.cls("form-group").up(modalBody)
	group2.add(Label.text("Code ")).add(Span.cls("text-danger").text("*"))
	group2.add(Input.typeOf("text").name("code").cls("form-control").attr3("required"))

	Dim group3 As Tag = Div.cls("form-group").up(modalBody)
	group3.add(Label.text("Name ")).add(Span.cls("text-danger").text("*"))
	group3.add(Input.typeOf("text").name("name").cls("form-control").attr3("required"))

	Dim group4 As Tag = Div.cls("form-group").up(modalBody)
	group4.add(Label.text("Price "))
	group4.add(Input.typeOf("text").name("price").cls("form-control"))

	Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
	modalFooter.add(Button.typeOf("submit").cls("btn btn-success px-3").text("Create"))
	modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").attr("value", "Cancel"))
	App.WriteHtml(Response, form1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/api/products/edit/".Length)
	Dim form1 As Tag = Form.init
	form1.hxPut($"/api/products"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
		
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products"
	DB.Columns = Array("category_id category", "product_code code", "product_name name", "product_price price")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		Dim code As String = row.Get("code")
		Dim name As String = row.Get("name")
		Dim price As Double = row.Get("price")
		Dim category_id As Int = row.Get("category")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Edit Product").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").up(modalBody).name("id").valueOf(id)
		
		Dim group1 As Tag = Div.cls("form-group").up(modalBody)
		Label.forId("category2").text("Category ").up(group1).add(Span.cls("text-danger")).text("*")
		
		Dim select1 As Tag = CreateCategoriesDropdown(category_id)
		select1.id("category2")
		select1.name("category")
		select1.up(group1)
		
		Dim group2 As Tag = Div.cls("form-group").up(modalBody)
		group2.add(Label.text("Code ")).add(Span.cls("text-danger").text("*"))
		group2.add(Input.typeOf("text").cls("form-control").name("code").valueOf(code))

		Dim group3 As Tag = Div.cls("form-group").up(modalBody)
		group3.add(Label.text("Name ")).add(Span.cls("text-danger").text("*"))
		group3.add(Input.typeOf("text").cls("form-control").name("name").valueOf(name).attr3("required"))

		Dim group4 As Tag = Div.cls("form-group").up(modalBody)
		group4.add(Label.text("Price "))
		group4.add(Input.typeOf("text").cls("form-control").name("price").valueOf(NumberFormat2(price, 1, 2, 2, False)))
		
		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		modalFooter.add(Button.cls("btn btn-primary px-3").text("Update"))
		modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel"))
	End If
	DB.Close
	App.WriteHtml(Response, form1.Build)
End Sub

Private Sub CreateCategoriesDropdown (selected As Int) As Tag
	Dim select1 As Tag = Dropdown.cls("form-select")
	select1.attr3("required")
	select1.hxGet("/api/categories/list")
	Option.valueOf("").text("Select Category").attr3(IIf(selected < 1, "selected", "")).attr3("disabled").up(select1)

	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	For Each row As Map In DB.Results
		Dim catid As Int = row.Get("id")
		Dim catname As String = row.Get("name")
		If catid = selected Then
			Option.valueOf(catid).attr3("selected").text(catname).up(select1)
		Else
			Option.valueOf(catid).text(catname).up(select1)
		End If
	Next
	DB.Close
	Return select1
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/api/products/delete/".Length)
	Dim form1 As Tag = Form.init
	form1.hxDelete($"/api/products"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
		
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products"
	DB.Columns = Array("id", "product_code AS code", "product_name AS name")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		Dim code As String = row.Get("code")
		Dim name As String = row.Get("name")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Delete Product").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").name("id").valueOf(id).up(modalBody)
		Paragraph.text($"Delete (${code}) ${name}?"$).up(modalBody)
		
		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.cls("btn btn-danger px-3").text("Delete").up(modalFooter)
		Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel").up(modalFooter)
	End If
	DB.Close
	App.WriteHtml(Response, form1.Build)
End Sub

' Handle CRUD operations
Private Sub HandleProducts
	Select Method
		Case "POST"
			' Create
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim tempprice As String = Request.GetParameter("price")
			Dim price As Double = IIf(tempprice.Trim = "", 0, tempprice)
			Dim category As Int = Request.GetParameter("category")

			If code = "" Or code.Trim.Length < 2 Then
				ShowAlert("Product Code must be at least 2 characters long.", "warning")
				Return
			End If
			
			' Check conflict
			Try
				DB.SQL = Main.DBOpen
				DB.Table = "tbl_products"
				DB.Where = Array("product_code = ?")
				DB.Parameters = Array(code)
				DB.Query
				If DB.Found Then
					ShowAlert("Product Code already exists!", "warning")
					DB.Close
					Return
				End If
			Catch
				Log(LastException)
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			' Insert new row
			Try
				DB.Reset
				DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "created_date")
				DB.Parameters = Array(category, code, name, price, Main.CurrentDateTime)
				DB.Save
				ShowToast("Product", "created", "Product created successfully!", "success")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			DB.Close
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim price As Double = Request.GetParameter("price")
			Dim category As Int = Request.GetParameter("category")
			
			If code = "" Or code.Trim.Length < 2 Then
				ShowAlert("Product Code must be at least 2 characters long.", "warning")
				Return
			End If
			
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_products"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Product not found!", "warning")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("product_code = ?", "id <> ?")
			DB.Parameters = Array(code, id)
			DB.Query
			If DB.Found Then
				ShowAlert("Product Code already exists!", "warning")
				DB.Close
				Return
			End If
			
			' Update row
			Try
				DB.Reset
				DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "modified_date")
				DB.Parameters = Array(category, code, name, price, Main.CurrentDateTime)
				DB.Id = id
				DB.Save
				ShowToast("Product", "updated", "Product updated successfully!", "info")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			DB.Close
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_products"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Product not found!", "warning")
				DB.Close
				Return
			End If

			' Delete row
			Try
				DB.Table = "tbl_products"
				DB.Id = id
				DB.Delete
				ShowToast("Product", "deleted", "Product deleted successfully!", "danger")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			DB.Close
	End Select
End Sub

Private Sub CreateProductsTable As Tag
	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Code"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.text("Category"))
	thead1.add(Th.sty("text-align: right").text("Price"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)

	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim tr1 As Tag = CreateProductsRow(row)
		tr1.up(tbody1)
	Next
	DB.Close
	Return table1
End Sub

Private Sub CreateProductsRow (data As Map) As Tag
	Dim id As Int = data.Get("id")
	Dim code As String = data.Get("code")
	Dim name As String = data.Get("name")
	Dim price As Double = data.Get("price")
	Dim category As String = data.Get("category")

	Dim tr1 As Tag = Tr.init
	tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
	tr1.add(Td.cls("align-middle").text(code))
	tr1.add(Td.cls("align-middle").text(name))
	tr1.add(Td.cls("align-middle").text(category))
	tr1.add(Td.cls("align-middle").sty("text-align: right").text(NumberFormat2(price, 1, 2, 2, True)))
	Dim td6 As Tag = Td.cls("align-middle text-center px-1 py-1").up(tr1)

	Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td6)
	anchor1.hxGet($"/api/products/edit/${id}"$)
	anchor1.hxTarget("#modal-content")
	anchor1.hxTrigger("click")
	anchor1.data("bs-toggle", "modal")
	anchor1.data("bs-target", "#modal-container")
	anchor1.add(Icon.cls("bi bi-pencil"))
	anchor1.attr("title", "Edit")

	Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td6)
	anchor2.hxGet($"/api/products/delete/${id}"$)
	anchor2.hxTarget("#modal-content")
	anchor2.hxTrigger("click")
	anchor2.data("bs-toggle", "modal")
	anchor2.data("bs-target", "#modal-container")
	anchor2.add(Icon.cls("bi bi-trash3"))
	anchor2.attr("title", "Delete")

	Return tr1
End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As Tag = Div.cls("alert alert-" & status).text(message)
	App.WriteHtml(Response, div1.Build)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As Tag = Div.id("products-container")
	div1.hxSwapOob("true")
	div1.add(CreateProductsTable)

	Dim script1 As MiniJs
	script1.Initialize
	script1.AddCustomEventDispatch("entity:changed", _
	CreateMap( _
	"entity": entity, _
	"action": action, _
	"message": message, _
	"status": status))

	App.WriteHtml(Response, div1.Build & CRLF & script1.Generate)
End Sub