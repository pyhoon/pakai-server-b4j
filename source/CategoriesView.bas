B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Categories View
' Version 6.93
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show As String
	Dim CacheName As String = "Categories Page"
	If App.ExistInCache(CacheName) = False Then
		App.WriteToCache(CacheName, CategoriesPage)		
	End If
	Dim page1 As MiniHtml = App.ReadFromCache(CacheName)
	Dim doc As MiniHtml
	doc.Initialize("")
	doc.Initialize("doctype")
	doc.Write(page1.build)
	Return doc.ToString
End Sub

Public Sub Modal (Action As String) As String
	Select Action
		Case "Add"
			Dim CacheName As String = "Categories Add Modal"
			If App.ExistInCache(CacheName) = False Then
				App.WriteToCache(CacheName, ModalAdd)
			End If
		Case "Edit"
			Dim CacheName As String = "Categories Edit Modal"
			If App.ExistInCache(CacheName) = False Then
				App.WriteToCache(CacheName, ModalEdit)
			End If
		Case "Delete"
			Dim CacheName As String = "Categories Delete Modal"
			If App.ExistInCache(CacheName) = False Then
				App.WriteToCache(CacheName, ModalDelete)
			End If
	End Select
	Dim modal1 As MiniHtml = App.ReadFromCache(CacheName)
	Return modal1.build
End Sub

Public Sub RenderedTable (data As List) As String
	Return CategoriesTableFilled(data).build
End Sub

Private Sub CategoriesPage As MiniHtml
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContainerContent)
	main1.LoadModal(ContainerModal)
	main1.LoadToast(ContainerToast)
	Dim page1 As MiniHtml = main1.Render
	Dim navitem1 As MiniHtml = page1.ChildById("nav-item")
	If App.api.EnableHelp Then
		MH.NavLinkItem("API", "/help", "bi bi-gear me-2", "API").up(navitem1)
	End If
	MH.NavLinkItem("Home", "/", "bi bi-house me-2", "Home").up(navitem1)
	Return page1
End Sub

Private Sub ContainerContent As MiniHtml
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
	
	MH.ButtonAdd("Add Category", "btn btn-success ml-2", "/hx/categories/add", "#modal-content", "click", "#modal-container", "modal").up(div2)
	
	Dim container1 As MiniHtml = MH.Div.up(col1)
	container1.attr("id", "categories-container")
	container1.attr("hx-get", "/hx/categories/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")
	Return row1
End Sub

Public Sub CategoriesTableFilled (data As List) As MiniHtml
	Dim CacheName As String = "Categories Table"
	If App.ExistInCache(CacheName) = False Then
		App.WriteToCache(CacheName, CategoriesTable)
	End If
	
	Dim CacheName As String = "Categories Table Row"
	If App.ExistInCache(CacheName) = False Then
		App.WriteToCache(CacheName, CategoriesTableRow.ConvertToBytes) ' bytes()
	End If
	
	Dim table1 As MiniHtml = App.ReadFromCache("Categories Table")
	Dim tbody1 As MiniHtml = table1.ChildByName("tbody")
	tbody1.Children.Clear
	For Each row As Map In data
		Dim tr1 As MiniHtml = App.ReadFromCache("Categories Table Row") ' bytes()
		tr1.ChildByIndex(0).text2(row.Get("id"))
		tr1.ChildByIndex(1).text2(row.Get("category_name"))
		tr1.ChildByIndex(2).ChildByIndex(0).attr("hx-get", "/hx/categories/edit/" & row.Get("id"))
		tr1.ChildByIndex(2).ChildByIndex(1).attr("hx-get", "/hx/categories/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	Return table1
End Sub

Public Sub CategoriesTable As MiniHtml
	Dim table1 As MiniHtml = MH.Table
	table1.cls("table table-bordered table-hover rounded small")
	Dim thead1 As MiniHtml = MH.Thead.up(table1).cls("table-light")
	MH.Th.up(thead1).text("#").sty("text-align: right; width: 50px")
	MH.Th.up(thead1).text("Name")
	MH.Th.up(thead1).text("Actions").sty("text-align: center; width: 120px")
	MH.Tbody.up(table1)
	Return table1
End Sub

Public Sub CategoriesTableRow As MiniHtml
	Dim tr1 As MiniHtml = MH.Tr
	Dim td1 As MiniHtml = MH.Td.up(tr1)
	td1.cls("align-middle").sty("text-align: right")
	Dim td2 As MiniHtml = MH.Td.up(tr1)
	td2.cls("align-middle")
	Dim td3 As MiniHtml = MH.Td.up(tr1)
	td3.cls("align-middle text-center px-1 py-1")
	MH.AnchorIcon("edit text-primary mx-2", "/hx/categories/edit/{id}", "Edit", "bi bi-pencil").up(td3)
	MH.AnchorIcon("delete text-danger mx-2", "/hx/categories/delete/{id}", "Delete", "bi bi-trash3").up(td3)
	Return tr1
End Sub

Private Sub ModalAdd As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-post", "/hx/categories")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	MH.H5.up(modalHeader).cls("modal-title").text("Add Category")
	MH.ButtonClose.up(modalHeader)
	
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	
	Dim group1 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Name ", "name").up(group1)
	MH.RequiredTextInput("name", "name", "").up(group1)
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	MH.ButtonSubmit("Create", "btn btn-success px-3").up(modalFooter)
	MH.ButtonCancel("Cancel", "btn btn-secondary px-3").up(modalFooter)
	Return form1
End Sub

Private Sub ModalEdit As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-put", "/hx/categories")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	MH.H5.up(modalHeader).cls("modal-title").text("Edit Category")
	MH.ButtonClose.up(modalHeader)
	
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	MH.HiddenInput("id", "$id$").up(modalBody)
	
	Dim group1 As MiniHtml = MH.FormGroup.up(modalBody)
	MH.RequiredLabel("Name ", "name").up(group1)
	MH.RequiredTextInput("name", "name", "$category_name$").up(group1)
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	MH.ButtonSubmit("Update", "btn btn-primary px-3").up(modalFooter)
	MH.ButtonCancel("Cancel", "btn btn-secondary px-3").up(modalFooter)
	Return form1
End Sub

Private Sub ModalDelete As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-delete", "/hx/categories")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	MH.H5.up(modalHeader).cls("modal-title").text("Delete Category")
	MH.ButtonClose.up(modalHeader)
	
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	MH.HiddenInput("id", "$id$").up(modalBody)
	
	MH.P.up(modalBody).text($"Delete $category_name$?"$)
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	MH.ButtonSubmit("Delete", "btn btn-danger px-3").up(modalFooter)
	MH.ButtonCancel("Cancel", "btn btn-secondary px-3").up(modalFooter)
	Return form1
End Sub

Private Sub ContainerModal As MiniHtml
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

Private Sub ContainerToast As MiniHtml
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