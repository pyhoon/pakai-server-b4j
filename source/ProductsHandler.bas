B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Products Handler class
' Version 6.51
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
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
	Method = req.Method
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim path As String = req.RequestURI
	If path = "/" Then
		RenderPage
	Else If path = "/hx/products/table" Then
		HandleTable
	Else If path = "/hx/products/search" Then
		HandleSearch
	Else If path = "/hx/products/add" Then
		HandleAddModal
	Else If path.StartsWith("/hx/products/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/hx/products/delete/") Then
		HandleDeleteModal
	Else
		HandleProducts
	End If
End Sub

Sub CreateTag (Name As String) As MiniHtml
	Dim tag1 As MiniHtml
	tag1.Initialize(Name)
	Return tag1
End Sub

Sub Anchor As MiniHtml
	Return CreateTag("a")
End Sub

Sub Button As MiniHtml
	Return CreateTag("button")
End Sub

Sub Div As MiniHtml
	Return CreateTag("div")
End Sub

Sub Form As MiniHtml
	Return CreateTag("form")
End Sub

Sub H5 As MiniHtml
	Return CreateTag("h5")
End Sub

Sub Icon As MiniHtml
	Return CreateTag("icon")
End Sub

Sub Input As MiniHtml
	Return CreateTag("input")
End Sub

Sub Label As MiniHtml
	Return CreateTag("label")
End Sub

Sub Li As MiniHtml
	Return CreateTag("li")
End Sub

Sub Option As MiniHtml
	Return CreateTag("option")
End Sub

Sub Span As MiniHtml
	Return CreateTag("span")
End Sub

Sub Table As MiniHtml
	Return CreateTag("table")
End Sub

Sub Tbody As MiniHtml
	Return CreateTag("tbody")
End Sub

Sub Td As MiniHtml
	Return CreateTag("td")
End Sub

Sub Th As MiniHtml
	Return CreateTag("th")
End Sub

Sub Thead As MiniHtml
	Return CreateTag("thead")
End Sub

Sub Tr As MiniHtml
	Return CreateTag("tr")
End Sub

Private Sub RenderPage
	If App.ctx.ContainsKey("/") = False Then
		Dim main1 As MainView
		main1.Initialize
		main1.LoadContent(ContentContainer)
		main1.LoadSubContent(GitHubLink)
		main1.LoadModal(ModalContainer)
		main1.LoadToast(ToastContainer)

		Dim page1 As MiniHtml = main1.Render
		Dim ulist1 As MiniHtml = FindUListTag(page1)
		
		Dim list1 As MiniHtml = Li.up(ulist1)
		list1.cls("nav-item d-block d-lg-block")
		Dim a1 As MiniHtml = Anchor.up(list1)
		a1.attr("href", "/categories")
		a1.cls("nav-link float-end")
		a1.text("Categories")
		Dim i1 As MiniHtml = Icon.up(a1)
		i1.cls("bi bi-tag me-2")
		i1.attr("title", "Categories")
		'a1.text("Categories")

		If App.api.EnableHelp Then
			Dim list2 As MiniHtml = Li.up(ulist1)
			list2.cls("nav-item d-block d-lg-block")
			Dim a2 As MiniHtml = Anchor.up(list2)
			a2.attr("href", "/help")
			a2.cls("nav-link float-end")
			a2.text("API")
			Dim i2 As MiniHtml = Icon.up(a2)
			i2.cls("bi bi-gear me-2")
			i2.attr("title", "API")
		End If

		' Sample for adding additional menu link
		'Dim list2 As MiniHtml = Li.cls("nav-item d-block d-lg-block").up(ulist1)
		'Dim a2 As MiniHtml = Anchor.href("/users").up(list1)
		'a2.cls("nav-link")
		'a2.text("Users")

		Dim doc As MiniHtml
		doc.Initialize("")
		doc.Write("<!DOCTYPE html>")
		doc.Write(page1.build)
		App.ctx.Put("/", doc.ToString)
	End If
	App.WriteHtml2(Response, App.ctx.Get("/"), App.ctx)
End Sub

' Retrieve ulist tag from DOM
Private Sub FindUListTag (dom As MiniHtml) As MiniHtml
	Dim body1 As MiniHtml = dom.Child(1)
	Dim nav1 As MiniHtml = body1.Child(1)
	Dim container1 As MiniHtml = nav1.Child(0)
	Dim navbar1 As MiniHtml = container1.Child(3)
	Dim ulist1 As MiniHtml = navbar1.Child(0)
	Return ulist1
End Sub

Private Sub ContentContainer As MiniHtml
	Dim content1 As MiniHtml = Div.cls("row mt-3")
	Dim col12 As MiniHtml = Div.up(content1).cls("col-md-12")
	Dim form1 As MiniHtml = Form.up(col12).cls("form mb-3")
	Dim row1 As MiniHtml = Div.up(form1).cls("row")
	Dim col1 As MiniHtml = Div.up(row1).cls("col-md-6 col-lg-6")
	Dim group1 As MiniHtml = Div.up(col1).cls("input-group mb-3")
	Dim label1 As MiniHtml = Label.up(group1)
	label1.attr("for", "keyword")
	label1.cls("input-group-text mt-2")
	label1.text("Search")
	Dim input1 As MiniHtml = Input.up(group1)
	input1.attr("type", "text")
	input1.cls("form-control col-md-6 mt-2")
	input1.attr("id", "keyword")
	input1.attr("name", "keyword")
	Dim searchBtn As MiniHtml = Button.up(group1)
	searchBtn.cls("btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2")
	searchBtn.text("Submit")
	searchBtn.attr("hx-post", "/hx/products/search")
	searchBtn.attr("hx-target", "#products-container")
	searchBtn.attr("hx-swap", "innerHTML")
	Dim col2 As MiniHtml = Div.up(row1).cls("col-md-6 col-lg-6")
	Dim div2 As MiniHtml = Div.up(col2).cls("float-end mt-2")
	'Dim a1 As MiniHtml = Anchor.up(div2)
	'a1.attr("href", "$SERVER_URL$/categories")
	'a1.cls("btn btn-primary me-2")
	'Icon.up(a1).cls("bi bi-list me-2")
	'a1.text("Show Category")

	Dim button2 As MiniHtml = Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.attr("hx-get", "/hx/products/add")
	button2.attr("hx-target", "#modal-content")
	button2.attr("hx-trigger", "click")
	button2.attr("data-bs-toggle", "modal")
	button2.attr("data-bs-target", "#modal-container")
	Icon.up(button2).cls("bi bi-plus-lg me-2")
	button2.text("Add Product")

	Dim container1 As MiniHtml = Div.up(col12)
	container1.attr("id", "products-container")
	container1.attr("hx-get", "/hx/products/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")
	
	Return content1
End Sub

Private Sub GitHubLink As MiniHtml
	Dim div1 As MiniHtml = Div.cls("text-center mb-3")
	Dim a1 As MiniHtml = Anchor.up(div1)
	a1.attr("href", "https://github.com/pyhoon/pakai-server-b4j")
	a1.cls("text-primary mr-1")
	a1.attr("aria-label", "github")
	a1.attr("title", "GitHub")
	a1.attr("target", "_blank")
	Dim svg1 As MiniHtml = CreateTag("svg").up(a1)
	svg1.attr("aria-hidden", "true")
	svg1.attr("width", "24")
	svg1.attr("height", "24")
	svg1.attr("version", "1.1")
	svg1.attr("viewBox", "0 0 16 16")
	Dim path1 As MiniHtml = CreateTag("path").up(svg1)
	path1.attr("fill-rule", "evenodd")
	path1.attr("d", "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z")
	Dim a2 As MiniHtml = Anchor.up(div1)
	a2.attr("href", "https://github.com/pyhoon/pakai-server-b4j")
	a2.sty("text-decoration: none")
	a2.attr("target","_blank")
	Dim span1 As MiniHtml = Span.up(a2)
	span1.sty("vertical-align: middle")
	span1.text("GitHub")
	Return div1
End Sub

Private Sub ModalContainer As MiniHtml
	Dim modal1 As MiniHtml = Div
	modal1.attr("id", "modal-container")
	modal1.cls("modal fade")
	modal1.attr("tabindex", "-1")
	modal1.attr("aria-hidden", "true")
	Dim modalDialog As MiniHtml = Div.up(modal1)
	modalDialog.cls("modal-dialog modal-dialog-centered")
	Dim div1 As MiniHtml = Div.up(modalDialog)
	div1.cls("modal-content")
	div1.attr("id", "modal-content")
	Return modal1
End Sub

Private Sub ToastContainer As MiniHtml
	Dim div1 As MiniHtml = Div
	div1.cls("position-fixed end-0 p-3")
	div1.sty("z-index: 2000")
	div1.sty("bottom: 0%")
	Dim toast1 As MiniHtml = Div.up(div1)
	toast1.attr("id", "toast-container")
	toast1.cls("toast align-items-center text-bg-success border-0")
	toast1.attr("role", "alert")
	Dim div2 As MiniHtml = Div.up(toast1)
	div2.cls("d-flex")
	Dim div3 As MiniHtml = Div.up(div2)
	div3.cls("toast-body")
	div3.attr("id", "toast-body")
	div3.text("Operation successful!")
	Dim button1 As MiniHtml = Button.up(div2)
	button1.attr("type", "button")
	button1.cls("btn-close btn-close-white me-2 m-auto")
	button1.attr("data-bs-dismiss", "toast")
	Return div1
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CreateProductsTable.build)
End Sub

' Search product using keyword
Private Sub HandleSearch
	If App.ctx.ContainsKey("/hx/products/search") = False Then
		Dim table1 As MiniHtml = Table.cls("table table-bordered table-hover rounded small")
		Dim thead1 As MiniHtml = Thead.up(table1).cls("table-light")
		Th.up(thead1).sty("text-align: right; width: 50px").text("#")
		Th.up(thead1).text("Code")
		Th.up(thead1).text("Name")
		Th.up(thead1).text("Category")
		Th.up(thead1).sty("text-align: right").text("Price")
		Th.up(thead1).sty("text-align: center; width: 120px").text("Actions")
		Tbody.up(table1)
		App.ctx.Put("/hx/products/search", table1)
	End If

	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name AS name", "p.product_price price")
	DB.Join = Array("tbl_categories c", "p.category_id = c.id")
	Dim keyword As String = Request.GetParameter("keyword")
	If keyword <> "" Then
		DB.Conditions = Array("p.product_code LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?")
		DB.Parameters = Array("%" & keyword & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "DESC")
	DB.Query
	Dim rows As List = DB.Results
	DB.Close

	Dim table1 As MiniHtml = App.ctx.Get("/hx/products/search")
	Dim tbody1 As MiniHtml = table1.Child(1)
	tbody1.Children.Clear ' remove all children
	For Each row As Map In rows
		row.Put("price", NumberFormat2(row.Get("price"), 1, 2, 2, True))
		Dim tr1 As MiniHtml = CreateProductsRow
		tr1.Child(0).text2(row.Get("id"))
		tr1.Child(1).text2(row.Get("code"))
		tr1.Child(2).text2(row.Get("name"))
		tr1.Child(3).text2(row.Get("category"))
		tr1.Child(4).text2(row.Get("price"))
		tr1.Child(5).Child(0).attr("hx-get", "/hx/products/edit/" & row.Get("id"))
		tr1.Child(5).Child(1).attr("hx-get", "/hx/products/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	App.WriteHtml(Response, table1.build)
End Sub

' Add modal
Private Sub HandleAddModal
	App.WriteHtml(Response, CreateAddModal)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/hx/products/edit/".Length)
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("category_id category", "product_code code", "product_name name", "product_price price")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	Dim row As Map
	Dim category_id As Int
	If DB.Found Then
		row = DB.First
		category_id = row.Get("category")
		row.Put("id", id)
		row.Put("price", NumberFormat2(row.Get("price"), 1, 2, 2, False))
	End If
	DB.Close
	App.WriteHtml2(Response, CreateEditModal(category_id), row)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/hx/products/delete/".Length)
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("id", "product_code AS code", "product_name AS name")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	Dim row As Map
	If DB.Found Then
		row = DB.First
		row.Put("id", id)
	End If
	DB.Close
	App.WriteHtml2(Response, CreateDeleteModal.build, row)
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
				DB.Open
				DB.Table = "tbl_products"
				DB.Conditions = Array("product_code = ?")
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
			If name = "" Or name.Trim.Length < 2 Then
				ShowAlert("Product Name must be at least 2 characters long.", "warning")
				Return
			End If
			
			DB.Open
			DB.Table = "tbl_products"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Product not found!", "warning")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Conditions = Array("product_code = ?", "id <> ?")
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
			DB.Open
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

Private Sub CreateProductsTable As MiniHtml
	If App.ctx.ContainsKey("/products/table") = False Then
		Dim table1 As MiniHtml = Table.cls("table table-bordered table-hover rounded small")
		Dim thead1 As MiniHtml = Thead.cls("table-light").up(table1)
		Th.up(thead1).sty("text-align: right; width: 50px").text("#")
		Th.up(thead1).text("Code")
		Th.up(thead1).text("Name")
		Th.up(thead1).text("Category")
		Th.up(thead1).sty("text-align: right").text("Price")
		Th.up(thead1).sty("text-align: center; width: 120px").text("Actions")
		Tbody.up(table1)
		App.ctx.Put("/products/table", table1)
	End If

	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = Array("tbl_categories c", "p.category_id = c.id")
	DB.OrderBy = CreateMap("p.id": "DESC")
	DB.Query
	Dim rows As List = DB.Results
	DB.Close
	
	Dim table1 As MiniHtml = App.ctx.Get("/products/table")
	Dim tbody1 As MiniHtml = table1.Child(1)
	tbody1.Children.Clear ' remove all children
	For Each row As Map In rows
		row.Put("price", NumberFormat2(row.Get("price"), 1, 2, 2, True))
		Dim tr1 As MiniHtml = CreateProductsRow
		tr1.Child(0).text2(row.Get("id"))
		tr1.Child(1).text2(row.Get("code"))
		tr1.Child(2).text2(row.Get("name"))
		tr1.Child(3).text2(row.Get("category"))
		tr1.Child(4).text2(row.Get("price"))
		tr1.Child(5).Child(0).attr("hx-get", "/hx/products/edit/" & row.Get("id"))
		tr1.Child(5).Child(1).attr("hx-get", "/hx/products/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	Return table1
End Sub

Private Sub CreateProductsRow As MiniHtml
	If App.ctx.ContainsKey("/products/table/row") = False Then
		Dim tr1 As MiniHtml = Tr
		Td.up(tr1).cls("align-middle").sty("text-align: right").text("%id%")
		Td.up(tr1).cls("align-middle").text("%code%")
		Td.up(tr1).cls("align-middle").text("%name%")
		Td.up(tr1).cls("align-middle").text("%category%")
		Td.up(tr1).cls("align-middle").sty("text-align: right").text("%price%")
		Dim td6 As MiniHtml = Td.up(tr1)
		td6.cls("align-middle text-center px-1 py-1")

		Dim a1 As MiniHtml = Anchor.up(td6)
		a1.cls("edit text-primary mx-2")
		a1.attr("hx-get", "/hx/products/edit/$id$")
		a1.attr("hx-target", "#modal-content")
		a1.attr("hx-trigger", "click")
		a1.attr("data-bs-toggle", "modal")
		a1.attr("data-bs-target", "#modal-container")
		Icon.up(a1).cls("bi bi-pencil")
		a1.attr("title", "Edit")

		Dim a2 As MiniHtml = Anchor.up(td6)
		a2.cls("delete text-danger mx-2")
		a2.attr("hx-get", "/hx/products/delete/$id$")
		a2.attr("hx-target", "#modal-content")
		a2.attr("hx-trigger", "click")
		a2.attr("data-bs-toggle", "modal")
		a2.attr("data-bs-target", "#modal-container")
		Icon.up(a2).cls("bi bi-trash3")
		a2.attr("title", "Delete")

		App.ctx.Put("/products/table/row", tr1.ConvertToBytes)
	End If
	Return Tr.ConvertFromBytes(App.ctx.Get("/products/table/row"))
End Sub

Private Sub CreateAddModal As String
	If App.ctx.ContainsKey("/hx/products/add") = False Then
		Dim form1 As MiniHtml = Form
		form1.attr("hx-post", "/hx/products")
		form1.attr("hx-target", "#modal-messages")
		form1.attr("hx-swap", "innerHTML")

		Dim modalHeader As MiniHtml = Div.up(form1)
		modalHeader.cls("modal-header")
		Dim h51 As MiniHtml = H5.up(modalHeader)
		h51.cls("modal-title").text("Add Product")
		Dim close1 As MiniHtml = Button.up(modalHeader)
		close1.attr("type","button")
		close1.cls("btn-close")
		close1.attr("data-bs-dismiss", "modal")
	
		Dim modalBody As MiniHtml = Div.up(form1)
		modalBody.cls("modal-body")
		Div.up(modalBody).attr("id", "modal-messages")
	
		Dim group1 As MiniHtml = Div.up(modalBody)
		group1.cls("form-group")
		Dim label1 As MiniHtml = Label.up(group1)
		label1.attr("for", "category1")
		label1.text("Category ")
		Dim span1 As MiniHtml = Span.up(label1)
		span1.cls("text-danger").text("*")
		Dim select1 As MiniHtml = CreateTag("select").up(group1)
		select1.cls("form-select")
		select1.attr("id", "category1")
		select1.attr("name", "category")
		select1.required

		Dim group2 As MiniHtml = Div.up(modalBody)
		group2.cls("form-group")
		Dim label2 As MiniHtml = Label.up(group2)
		label2.text("Code ")
		Dim span2 As MiniHtml = Span.up(label2)
		span2.cls("text-danger").text("*")
		Dim input2 As MiniHtml = Input.up(group2)
		input2.attr("type", "text")
		input2.attr("name", "code")
		input2.cls("form-control")
		input2.required

		Dim group3 As MiniHtml = Div.up(modalBody)
		group3.cls("form-group")
		Dim label3 As MiniHtml = Label.up(group3)
		label3.text("Name ")
		Dim span3 As MiniHtml = Span.up(label3)
		span3.cls("text-danger").text("*")
		Dim input3 As MiniHtml = Input.up(group3)
		input3.attr("type", "text")
		input3.attr("name", "name")
		input3.cls("form-control")
		input3.required

		Dim group4 As MiniHtml = Div.up(modalBody)
		group4.cls("form-group")
		Dim label4 As MiniHtml = Label.up(group4)
		label4.text("Price ")
		Dim input4 As MiniHtml = Input.up(group4)
		input4.attr("type", "text")
		input4.attr("name", "price")
		input4.cls("form-control")

		Dim modalFooter As MiniHtml = Div.up(form1).cls("modal-footer")
		Dim button2 As MiniHtml = Button.up(modalFooter)
		button2.attr("type", "submit")
		button2.cls("btn btn-success px-3")
		button2.text("Create")
		Dim input5 As MiniHtml = Input.up(modalFooter)
		input5.attr("type", "button")
		input5.cls("btn btn-secondary px-3")
		input5.attr("data-bs-dismiss", "modal")
		input5.attr("value", "Cancel")

		App.ctx.Put("/hx/products/add", form1)
	End If
	
	Dim form1 As MiniHtml = App.ctx.Get("/hx/products/add")
	Dim modalBody As MiniHtml = form1.Child(1)
	Dim group1 As MiniHtml = modalBody.Child(1)
	Dim select1 As MiniHtml = group1.Child(1)
	select1.Children.Clear ' remove all children
	Option.up(select1).attr("value", "").text("Select Category").selected.disabled
	
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	Dim rows As List = DB.Results
	DB.Close
	For Each row As Map In rows
		Dim catid As Int = row.Get("id")
		Dim catname As String = row.Get("name")
		Option.up(select1).attr("value", catid).text(catname)
	Next
	Return form1.build
End Sub

Private Sub CreateEditModal (CategoryId As String) As String
	If App.ctx.ContainsKey("/hx/products/edit") = False Then
		Dim form1 As MiniHtml = Form
		form1.attr("hx-put", "/hx/products")
		form1.attr("hx-target", "#modal-messages")
		form1.attr("hx-swap", "innerHTML")
	
		Dim modalHeader As MiniHtml = Div.up(form1).cls("modal-header")
		Dim h51 As MiniHtml = H5.up(modalHeader)
		h51.cls("modal-title").text("Edit Product")
		Dim close1 As MiniHtml = Button.up(modalHeader)
		close1.attr("type", "button")
		close1.cls("btn-close")
		close1.attr("data-bs-dismiss", "modal")
		
		Dim modalBody As MiniHtml = Div.up(form1).cls("modal-body")
		Dim div1 As MiniHtml = Div.up(modalBody)
		div1.attr("id", "modal-messages")
		Dim id1 As MiniHtml = Input.up(modalBody)
		id1.attr("type", "hidden")
		id1.attr("name", "id")
		id1.attr("value", "$id$")
		
		Dim group1 As MiniHtml = Div.up(modalBody)
		group1.cls("form-group")
		Dim label1 As MiniHtml = Label.up(group1)
		label1.attr("for", "category2")
		label1.text("Category ")
		Dim span1 As MiniHtml = Span.up(label1)
		span1.cls("text-danger").text("*")
		Dim select1 As MiniHtml = CreateTag("select").up(group1)
		select1.cls("form-select")
		select1.attr("id", "category2")
		select1.attr("name", "category")
		select1.required
		
		Dim group2 As MiniHtml = Div.up(modalBody)
		group2.cls("form-group")
		Dim label2 As MiniHtml = Label.up(group2)
		label2.text("Code ")
		Dim span2 As MiniHtml = Span.up(label2)
		span2.cls("text-danger").text("*")
		
		Dim input2 As MiniHtml = Input.up(group2)
		input2.attr("type", "text")
		input2.cls("form-control")
		input2.attr("name", "code")
		input2.attr("value", "$code$")
		input2.required
		
		Dim group3 As MiniHtml = Div.up(modalBody)
		group3.cls("form-group")
		Dim label3 As MiniHtml = Label.up(group3)
		label3.attr("for", "name")
		label3.text("Name ")
		Dim span3 As MiniHtml = Span.up(label3)
		span3.cls("text-danger").text("*")
		Dim input3 As MiniHtml = Input.up(group3)
		input3.attr("type", "text")
		input3.cls("form-control")
		input3.attr("id", "name")
		input3.attr("name", "name")
		input3.attr("value", "$name$")
		input3.required

		Dim group4 As MiniHtml = Div.up(modalBody)
		group4.cls("form-group")
		Dim label4 As MiniHtml = Label.up(group4)
		label4.text("Price ")
		Dim input4 As MiniHtml = Input.up(group4)
		input4.attr("type", "text")
		input4.cls("form-control")
		input4.attr("name", "price")
		input4.attr("value", "$price$")
		
		Dim modalFooter As MiniHtml = Div.up(form1).cls("modal-footer")
		Dim button1 As MiniHtml = Button.up(modalFooter)
		button1.cls("btn btn-primary px-3")
		button1.text("Update")
		Dim button2 As MiniHtml = Input.up(modalFooter)
		button2.attr("type", "button")
		button2.cls("btn btn-secondary px-3")
		button2.attr("data-bs-dismiss", "modal")
		button2.attr("value", "Cancel")

		App.ctx.Put("/hx/products/edit", form1)
	End If
	
	Dim form1 As MiniHtml = App.ctx.Get("/hx/products/edit")
	Dim modalBody As MiniHtml = form1.Child(1)
	Dim group1 As MiniHtml = modalBody.Child(2)
	Dim select1 As MiniHtml = group1.Child(1)
	select1.Children.Clear ' remove all children
	Option.up(select1).attr("value", "").text("Select Category").disabled
	
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	Dim rows As List = DB.Results
	DB.Close
	For Each row As Map In rows
		Dim catid As Int = row.Get("id")
		Dim catname As String = row.Get("name")
		Dim option1 As MiniHtml = Option.up(select1).attr("value", catid).text(catname)
		If catid = CategoryId Then option1.selected
	Next
	Return form1.build
End Sub

Private Sub CreateDeleteModal As MiniHtml ' As String
	If App.ctx.ContainsKey("/hx/products/delete") = False Then
		Dim form1 As MiniHtml = Form
		form1.attr("hx-delete", "/hx/products")
		form1.attr("hx-target", "#modal-messages")
		form1.attr("hx-swap", "innerHTML")

		Dim modalHeader As MiniHtml = Div.cls("modal-header").up(form1)
		Dim h51 As MiniHtml = H5.up(modalHeader)
		h51.cls("modal-title").text("Delete Product")
		Dim close1 As MiniHtml = Button.up(modalHeader) 
		close1.attr("type", "button")
		close1.cls("btn-close")
		close1.attr("data-bs-dismiss", "modal")
		
		Dim modalBody As MiniHtml = Div.cls("modal-body").up(form1)
		Dim div1 As MiniHtml = Div.up(modalBody)
		div1.attr("id", "modal-messages")
		Dim id1 As MiniHtml = Input.up(modalBody)
		id1.attr("type", "hidden")
		id1.attr("name", "id")
		id1.attr("value", "$id$")
		CreateTag("p").up(modalBody).text("Delete ($code$) $name$?")
		
		Dim modalFooter As MiniHtml = Div.up(form1).cls("modal-footer")
		Dim button1 As MiniHtml = Button.up(modalFooter)
		button1.cls("btn btn-danger px-3")
		button1.text("Delete")
		Dim input1 As MiniHtml = Input.up(modalFooter)
		input1.attr("type", "button")
		input1.cls("btn btn-secondary px-3")
		input1.attr("data-bs-dismiss", "modal")
		input1.attr("value", "Cancel")

		App.ctx.Put("/hx/products/delete", form1)
	End If
	Return App.ctx.Get("/hx/products/delete")
End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As MiniHtml = Div.cls("alert alert-" & status).text(message)
	App.WriteHtml(Response, div1.build)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As MiniHtml = Div
	div1.attr("id", "products-container")
	div1.attr("hx-swap-oob", "true")
	CreateProductsTable.up(div1)

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