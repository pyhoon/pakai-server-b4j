B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Products View
' Version 6.99
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show As String
	Dim CacheName As String = "Products Page"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, ProductsPage)
	End If
	Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	Return doc.ToString
End Sub

Public Sub Modal (Action As String, CategoryList As List, Data As Map) As String
	Select Action
		Case "Add"
			Dim CacheName As String = "Products Add Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalAdd)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim select1 As MiniHtml = modal1.ChildById("category1")
			select1.Children.Clear
			Dim option1 As MiniHtml = MH.Option.up(select1)
			option1.attr("value", "")
			option1.text("Select Category")
			option1.selected.disabled
			For Each row As Map In CategoryList
				Dim option2 As MiniHtml = MH.Option.up(select1)
				option2.attr("value", row.Get("id"))
				option2.text(row.Get("category_name"))
			Next
			Return modal1.build
		Case "Edit"
			Dim CacheName As String = "Products Edit Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalEdit)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim id1 As MiniHtml = modal1.ChildById("id")
			id1.attr("value", Data.Get("id"))
			Dim select1 As MiniHtml = modal1.ChildById("category2")
			select1.Children.Clear
			Dim option1 As MiniHtml = MH.Option.up(select1)
			option1.attr("value", "")
			option1.text("Select Category")
			option1.disabled
			For Each row As Map In CategoryList
				Dim id As Int = row.Get("id")
				Dim category_name As String = row.Get("category_name")
				Dim option2 As MiniHtml = MH.Option.up(select1)
				option2.attr("value", id)
				option2.text(category_name)
				If id = Data.Get("category_id") Then option2.selected
			Next
			Dim input2 As MiniHtml = modal1.ChildById("code")
			input2.attr("value", Data.Get("product_code"))
			Dim input3 As MiniHtml = modal1.ChildById("name")
			input3.attr("value", Data.Get("product_name"))
			Dim input4 As MiniHtml = modal1.ChildById("price")
			Dim price As String = NumberFormat2(Data.Get("product_price"), 1, 2, 2, False)
			input4.attr("value", price)
			Return modal1.build
		Case "Delete"
			Dim CacheName As String = "Products Delete Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalDelete)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim id1 As MiniHtml = modal1.ChildById("id")
			id1.attr("value", Data.Get("id"))
			Dim p1 As MiniHtml = modal1.ChildById("p1")
			p1.text2($"Delete ${Data.Get("product_name")} (${Data.Get("product_code")})?"$)
			Return modal1.build
		Case Else
			Return ""
	End Select
End Sub

Public Sub Alert (info As AlertInfo) As String
	Return MH.Alert(info)
End Sub

Public Sub Toast (data As List, info As ToastInfo) As String
	Return MH.Toast("products-container", ProductsTableFilled(data), info)
End Sub

Public Sub RenderedTable (data As List) As String
	Return ProductsTableFilled(data).build
End Sub

Private Sub ProductsPage As MiniHtml
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContainerContent)
	main1.LoadSubContent(MH.GitHubLink)
	main1.LoadModal(MH.ContainerModal)
	main1.LoadToast(MH.ContainerToast)
	Dim page1 As MiniHtml = main1.Render
	Dim navitem1 As MiniHtml = page1.ChildById("nav-item")
	If App.api.EnableHelp Then
		MH.NavLinkItem("API", "/help", "bi bi-gear me-2", "API").up(navitem1)
	End If
	MH.NavLinkItem("Categories", "/categories", "bi bi-tag me-2", "Categories").up(navitem1)
	Return page1
End Sub

Private Sub ContainerContent As MiniHtml
	Dim content1 As MiniHtml = MH.Div.cls("row mt-3")
	Dim col12 As MiniHtml = MH.Div.up(content1).cls("col-md-12")
	Dim form1 As MiniHtml = MH.Form.up(col12).cls("form mb-3")
	Dim row1 As MiniHtml = MH.Div.up(form1).cls("row")
	Dim col1 As MiniHtml = MH.Div.up(row1).cls("col-md-6 col-lg-6")
	
	Dim group1 As MiniHtml = MH.InputGroup.up(col1)
	MH.TextLabel("Search", "input-group-text mt-2", "keyword").up(group1)
	MH.InputSearch("form-control col-md-6 mt-2", "keyword", "keyword").up(group1)
	MH.ButtonSearch("Submit", "btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2", "/hx/products/table", "#products-container").up(group1)
	
	Dim col2 As MiniHtml = MH.Div.up(row1).cls("col-md-6 col-lg-6")
	Dim div2 As MiniHtml = MH.Div.up(col2).cls("float-end mt-2")
	MH.ButtonAdd("Add Product", "btn btn-success ml-2", "/hx/products/add", "#modal-content", "click", "#modal-container", "modal").up(div2)
	
	Dim container1 As MiniHtml = MH.Div.up(col12)
	container1.attr("id", "products-container")
	container1.attr("hx-get", "/hx/products/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")
	Return content1
End Sub

Public Sub ProductsTableFilled (data As List) As MiniHtml
	Dim CacheName As String = "Products Table"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, ProductsTable)
	End If
	
	Dim CacheName As String = "Products Table Row"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, ProductsTableRow.ConvertToBytes) ' bytes()
	End If

	Dim table1 As MiniHtml = MC.ReadFromCache(App.ctx, "Products Table")
	Dim tbody1 As MiniHtml = table1.ChildByName("tbody")
	tbody1.Children.Clear
	For Each row As Map In data
		Dim tr1 As MiniHtml = MC.ReadFromCache(App.ctx, "Products Table Row") ' bytes()
		tr1.ChildByIndex(0).text2(row.Get("id"))
		tr1.ChildByIndex(1).text2(row.Get("product_code"))
		tr1.ChildByIndex(2).text2(row.Get("product_name"))
		tr1.ChildByIndex(3).text2(row.Get("category_name"))
		tr1.ChildByIndex(4).text2(NumberFormat2(row.Get("product_price"), 1, 2, 2, True))
		tr1.ChildByIndex(5).ChildByIndex(0).attr("hx-get", "/hx/products/edit/" & row.Get("id"))
		tr1.ChildByIndex(5).ChildByIndex(1).attr("hx-get", "/hx/products/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	Return table1
End Sub

Private Sub ProductsTable As MiniHtml
	Dim table1 As MiniHtml = MH.Table
	table1.cls("table table-bordered table-hover rounded small")
	Dim thead1 As MiniHtml = MH.Thead.cls("table-light").up(table1)
	MH.Th.up(thead1).sty("text-align: right; width: 50px").text("#")
	MH.Th.up(thead1).text("Code")
	MH.Th.up(thead1).text("Name")
	MH.Th.up(thead1).text("Category")
	MH.Th.up(thead1).sty("text-align: right").text("Price")
	MH.Th.up(thead1).sty("text-align: center; width: 120px").text("Actions")
	MH.Tbody.up(table1)
	Return table1
End Sub

Private Sub ProductsTableRow As MiniHtml
	Dim tr1 As MiniHtml = MH.Tr
	MH.Td.up(tr1).cls("align-middle").sty("text-align: right")
	MH.Td.up(tr1).cls("align-middle")
	MH.Td.up(tr1).cls("align-middle")
	MH.Td.up(tr1).cls("align-middle")
	MH.Td.up(tr1).cls("align-middle").sty("text-align: right")
	Dim td6 As MiniHtml = MH.Td.up(tr1)
	td6.cls("align-middle text-center px-1 py-1")
	MH.AnchorIcon("edit text-primary mx-2", "/hx/products/edit/{id}", "Edit", "bi bi-pencil").up(td6)
	MH.AnchorIcon("delete text-danger mx-2", "/hx/products/delete/{id}", "Delete", "bi bi-trash3").up(td6)
	Return tr1
End Sub

Private Sub ModalAdd As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-post", "/hx/products")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	MH.H5.up(modalHeader).cls("modal-title").text("Add Product")
	MH.ButtonClose.up(modalHeader)
	
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	
	Dim group1 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Category ", "category1").up(group1)
	MH.RequiredDropdown("category1", "category").up(group1)

	Dim group2 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Code ", "").up(group2)
	MH.RequiredTextInput("", "code", "").up(group2)

	Dim group3 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Name ", "").up(group3)
	MH.RequiredTextInput("", "name", "").up(group3)

	Dim group4 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Price ", "").up(group4)
	MH.RequiredTextInput("", "price", "").up(group4)
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	MH.ButtonSubmit("Create", "btn btn-success px-3").up(modalFooter)
	MH.ButtonCancel("Cancel", "btn btn-secondary px-3").up(modalFooter)
	Return form1
End Sub

Private Sub ModalEdit As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-put", "/hx/products")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	MH.H5.up(modalHeader).cls("modal-title").text("Edit Product")
	MH.ButtonClose.up(modalHeader)
	
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	MH.HiddenInput("id", "id", "").up(modalBody)
	
	Dim group1 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Category ", "category2").up(group1)
	Dim select1 As MiniHtml = MH.RequiredDropdown("category2", "category").up(group1)
	Dim option1 As MiniHtml = MH.Option.up(select1)
	option1.attr("value", "")
	option1.text("Select Category")
	
	Dim group2 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Code ", "").up(group2)
	MH.RequiredTextInput("code", "code", "").up(group2)

	Dim group3 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Name ", "").up(group3)
	MH.RequiredTextInput("name", "name", "").up(group3)

	Dim group4 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Price ", "").up(group4)
	MH.RequiredTextInput("price", "price", "").up(group4)
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	MH.ButtonSubmit("Update", "btn btn-primary px-3").up(modalFooter)
	MH.ButtonCancel("Cancel", "btn btn-secondary px-3").up(modalFooter)
	Return form1
End Sub

Private Sub ModalDelete As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-delete", "/hx/products")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.cls("modal-header").up(form1)
	MH.H5.up(modalHeader).cls("modal-title").text("Delete Product")
	MH.ButtonClose.up(modalHeader)
	
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	MH.HiddenInput("id", "id", "").up(modalBody)
	MH.P.up(modalBody).Id = "p1"
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	MH.ButtonSubmit("Delete", "btn btn-danger px-3").up(modalFooter)
	MH.ButtonCancel("Cancel", "btn btn-secondary px-3").up(modalFooter)
	Return form1
End Sub