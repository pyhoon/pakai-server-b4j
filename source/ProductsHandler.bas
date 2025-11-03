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
	Else If path = "/api/products/search" Then
		HandleSearch
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
	'searchBtn.hxSwapOob("true")
	
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("float-end mt-2").up(col2)
	
	Dim anchor1 As Tag = div2.add(Anchor.href("$SERVER_URL$/categories").cls("btn btn-primary me-2"))
	'anchor1.add(Icon.cls("ti ti-menu me-2"))
	anchor1.add(Icon.cls("bi bi-list me-2"))
	anchor1.text("Show Category")
	
	Dim anchor2 As Tag = div2.add(Anchor.cls("btn btn-success"))
	anchor2.hxGet("/api/products/modal/add")
	anchor2.hxTarget("#modal-container")
	'anchor2.add(Icon.cls("ti ti-plus me-2"))
	anchor2.add(Icon.cls("bi bi-plus-lg me-2"))
	anchor2.text("Add Product")
	
	Dim container1 As Tag = Div.id("products-container").cls("table").up(col12)
	container1.hxGet("/api/products/table").hxTrigger("load").text("Loading...")
	Return content1
End Sub

Private Sub GitHubLink As Tag
	Dim div1 As Tag = Div.cls("text-center mb-3")
	Dim anchor1 As Tag = Anchor.href("https://github.com/pyhoon/pakai-server-b4j").cls("text-primary mr-1").up(div1)
	anchor1.attr("aria-label", "github").attr("title", "GitHub").targetOf("_blank")
	Dim svg1 As Tag = Svg.aria("hidden", "true").width("24").height("24").up(anchor1)
	svg1.attr("version", "1.1").attr("viewBox", "0 0 16 16")
	Dim path1 As Tag = Html.create("path").up(svg1)
	path1.attr("fill-rule", "evenodd")
	path1.attr("d", "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z")
	Dim anchor2 As Tag = Anchor.href("https://github.com/pyhoon/pakai-server-b4j").sty("text-decoration: none").targetOf("_blank").up(div1)
	anchor2.add(Span.sty("vertical-align: middle").text("Visit my GitHub repository"))
	Return div1
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
		Dim price As Double = row.Get("price")
		'Dim catid As Int = row.Get("catid")
		Dim category As String = row.Get("category")
		
		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(code))
		tr1.add(Td.cls("align-middle").text(name))
		tr1.add(Td.cls("align-middle").text(category))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(NumberFormat2(price, 1, 2, 2, True)))
		Dim td1 As Tag = tr1.add(Td.cls("text-center"))
		
		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/api/products/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		'anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		anchor1.add(Icon.cls("bi bi-pencil").sty("font-size: 1.2em"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/api/products/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		'anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		anchor2.add(Icon.cls("bi bi-trash3").sty("font-size: 1.2em"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	'WebApiUtils.ReturnHtml(table1.Build, Response)
	Response.Write(table1.Build)
End Sub

' Search product using keyword
Private Sub HandleSearch
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
		Dim price As Double = row.Get("price")
		'Dim catid As Int = row.Get("catid")
		Dim category As String = row.Get("category")

		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(code))
		tr1.add(Td.cls("align-middle").text(name))
		tr1.add(Td.cls("align-middle").text(category))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(NumberFormat2(price, 1, 2, 2, True)))
		Dim td1 As Tag = tr1.add(Td.cls("text-center"))
		
		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/api/products/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		'anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		anchor1.add(Icon.cls("bi bi-pencil"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/api/products/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		'anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		anchor2.add(Icon.cls("bi bi-trash3").sty("font-size: 1.2em"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	'WebApiUtils.ReturnHtml(table1.Build, Response)
	Response.Write(table1.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim modal1 As Tag = Div.cls("modal fade")
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	
	Dim form1 As Tag = Form.up(modalContent)
	form1.hxPost("/api/products")
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")

	Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
	modalHeader.add(H5.cls("modal-title").text("Add Product"))
	modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
	
	Dim modalBody As Tag = Div.cls("modal-body").up(form1)
	Div.id("modal-messages").up(modalBody)
	
	Dim group1 As Tag = modalBody.add(Div.cls("form-group"))
	group1.add(Label.text("Category ")).add(Span.cls("text-danger").text("*"))
	Dim category1 As Tag = group1.add(Dropdown.id("category").name("category").cls("form-select").attr3("required"))'.aria("label", "Default select example"))
	category1.add(Option.attr3("disabled").text("Select Category"))
	
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim name As String = row.Get("name")
		Option.valueOf(id).text(name).up(category1)
	Next
	DB.Close

	Dim group2 As Tag = modalBody.add(Div.cls("form-group"))
	group2.add(Label.text("Code ")).add(Span.cls("text-danger").text("*"))
	group2.add(Input.typeOf("text").name("code").cls("form-control").attr3("required"))

	Dim group3 As Tag = modalBody.add(Div.cls("form-group"))
	group3.add(Label.text("Name ")).add(Span.cls("text-danger").text("*"))
	group3.add(Input.typeOf("text").name("name").cls("form-control").attr3("required"))

	Dim group4 As Tag = modalBody.add(Div.cls("form-group"))
	group4.add(Label.text("Price "))
	group4.add(Input.typeOf("text").name("price").cls("form-control"))

	Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
	modalFooter.add(Button.typeOf("submit").cls("btn btn-success px-3").text("Create"))
	modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").attr("value", "Cancel"))
	
	'WebApiUtils.ReturnHtml(modal1.Build, Response)
	Response.Write(modal1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/api/products/modal/edit/".Length)
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
		Dim category As Int = row.Get("category")
		
		Dim modal1 As Tag = Div.cls("modal fade")
		Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
		
		Dim form1 As Tag = Form.up(modalContent)
		form1.hxPut($"/api/products"$)
		form1.hxTarget("#modal-messages")
		form1.hxSwap("innerHTML")
		form1.add(Input.typeOf("hidden").name("id").valueOf(id))
		
		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		modalHeader.add(H5.cls("modal-title").text("Edit Product"))
		modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		
		Dim group1 As Tag = Div.cls("form-group").up(modalBody)
		group1.add(Label.text("Category ")).add(Span.cls("text-danger").text("*"))
		Dim category2 As Tag = group1.add(Dropdown.id("category").cls("form-select").name("category").attr3("required").aria("label", "Default select example"))
		category2.add(Option.attr3("disabled").text("Select Category"))
		DB.SQL = Main.DBOpen
		DB.Table = "tbl_categories"
		DB.Columns = Array("id", "category_name AS name")
		DB.Query
		For Each row As Map In DB.Results
			Dim catid As Int = row.Get("id")
			Dim catname As String = row.Get("name")
			If catid = category Then
				Option.valueOf(catid).attr3("selected").text(catname).up(category2)
			Else
				Option.valueOf(catid).text(catname).up(category2)
			End If
		Next
		DB.Close
		
		Dim group2 As Tag = Div.cls("form-group").up(modalBody)
		group2.add(Label.text("Code ")).add(Span.cls("text-danger").text("*"))
		'group2.add(Input.typeOf("text").name("code").cls("form-control").attr3("required").valueOf(code))
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
		'WebApiUtils.ReturnHtml(modal1.Build, Response)
		Response.Write(modal1.Build)
	End If
	DB.Close
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/api/products/modal/delete/".Length)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_products"
	DB.Columns = Array("id", "product_code AS code", "product_name AS name")
	DB.WhereParam("id = ?", id)
	DB.Query
	
	If DB.Found Then
		Dim row As Map = DB.First
		Dim code As String = row.Get("code")
		Dim name As String = row.Get("name")
		Dim modal1 As Tag = Div.cls("modal fade")
		Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").up(modal1)
		Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)

		Dim form1 As Tag = Form.up(modalContent)
		form1.hxDelete($"/api/products"$)
		form1.hxTarget("#modal-messages")
		form1.hxSwap("innerHTML")
		form1.add(Input.typeOf("hidden").name("id").valueOf(id))
		
		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		modalHeader.add(H5.cls("modal-title").text("Delete Product"))
		modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		modalBody.add(Paragraph.text($"Delete (${code}) ${name}?"$))
		
		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		modalFooter.add(Button.cls("btn btn-danger px-3").text("Delete"))
		modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel"))
		'WebApiUtils.ReturnHtml(modal1.Build, Response)
		Response.Write(modal1.Build)
	End If
	DB.Close
End Sub

' Handle CRUD operations
Private Sub HandleProducts
	Select Method
		Case "POST"
			' Create
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim price As Double = Request.GetParameter("price")
			Dim category As Int = Request.GetParameter("category")
			If code = "" Or code.Trim.Length < 2 Then
				'Response.Status = 422
				ShowAlert("warning", "Product Code must be at least 2 characters long.")
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
					DB.Close
					'Response.Status = 409
					ShowAlert("warning", "Product Code already exists!")
					Return
				End If
			Catch
				Log(LastException)
				'Response.Status = 500
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
			' Insert new row
			Try
				DB.Reset
				DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "created_date")
				DB.Parameters = Array(category, code, name, price, Main.CurrentDateTime)
				DB.Save
				DB.Close
				ShowToast("success", "Product created successfully!")
			Catch
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim price As Double = Request.GetParameter("price")
			Dim category As Int = Request.GetParameter("category")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_products"
			
			If code = "" Or code.Trim.Length < 2 Then
				'Response.Status = 422
				ShowAlert("warning", "Product Code must be at least 2 characters long.")
				Return
			End If
			
			DB.Find(id)
			If DB.Found = False Then
				'Response.Status = 404
				ShowAlert("warning", "Product not found!")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("product_code = ?", "id <> ?")
			DB.Parameters = Array(code, id)
			DB.Query
			If DB.Found Then
				'Response.Status = 409
				ShowAlert("warning", "Product Code already exists!")
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
				DB.Close
				ShowToast("success", "Product updated successfully!")
			Catch
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_products"
			
			DB.Find(id)
			If DB.Found = False Then
				'Response.Status = 404
				ShowAlert("warning", "Product not found!")
				DB.Close
				Return
			End If

			' Delete row
			Try
				DB.Table = "tbl_products"
				DB.Id = id
				DB.Delete
				DB.Close
				ShowToast("success", "Product deleted successfully!")
			Catch
				ShowAlert("danger", $"Database error: ${LastException.Message}"$)
			End Try
	End Select
End Sub

Private Sub GenerateProductsTable As Tag
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
		Dim price As Double = row.Get("price")
		'Dim catid As Int = row.Get("catid")
		Dim category As String = row.Get("category")
		
		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(code))
		tr1.add(Td.cls("align-middle").text(name))
		tr1.add(Td.cls("align-middle").text(category))
		'tr1.add(Td.cls("align-middle").sty("text-align: right").text(price))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(NumberFormat2(price, 1, 2, 2, False)))
		
		Dim td1 As Tag = tr1.add(Td.cls("text-center"))
		
		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/api/products/modal/edit/${id}"$)
		anchor1.hxTarget("#modal-container")
		'anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		anchor1.add(Icon.cls("bi bi-pencil").sty("font-size: 1.2em"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/api/products/modal/delete/${id}"$)
		anchor2.hxTarget("#modal-container")
		'anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		anchor2.add(Icon.cls("bi bi-trash3").sty("font-size: 1.2em"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	Return table1
End Sub

Private Sub ShowAlert (class As String, message As String)
	Dim div1 As Tag = Div.cls("alert alert-" & class).text(message)
	Response.Write(div1.Build)
End Sub

Private Sub ShowToast (class As String, message As String)
	Dim div1 As Tag = Div.id("products-container").hxSwapOob("true")
	div1.add(GenerateProductsTable)
	'Response.Write(div1.Build)
			
	Dim script1 As MiniJS
	script1.Initialize
	'script1.AddComment("Close the modal")
	script1.DeclareVariable("modalElement", "document.querySelector('.modal')", True)
	'script1.AddConditionalCall("modalInstance", "modalInstance.hide();")
	script1.StartIf("modalElement")
	script1.DeclareVariable("modal", "bootstrap.Modal.getInstance(modalElement)", True)
	script1.AddConditionalCall("modal", "modal.hide();")
	script1.EndIf
	script1.AddLine("")
	'script1.AddComment("Show success toast")
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