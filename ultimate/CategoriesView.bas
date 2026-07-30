B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Categories View
' Version 6.99
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show As String
	Dim page1 As MiniHtml = CreateOrReadFromCache("Categories Page")
	Return page1.build
End Sub

Public Sub Modal (Action As String, Data As Map) As String
	Select Action
		Case "Add"
			Dim modal1 As MiniHtml = CreateOrReadFromCache("Categories Add Modal")
			Return modal1.build
		Case "Edit"
			Dim modal1 As MiniHtml = CreateOrReadFromCache("Categories Edit Modal")
			modal1.ChildById("id").attr("value", Data.Get("id"))
			modal1.ChildById("name").attr("value", Data.Get("category_name"))
			Return modal1.build			
		Case "Delete"
			Dim modal1 As MiniHtml = CreateOrReadFromCache("Categories Delete Modal")
			modal1.ChildById("id").attr("value", Data.Get("id"))
			modal1.ChildById("p1").text2($"Delete ${Data.Get("category_name")}?"$)
			Return modal1.build
		Case Else
			Return ""			
	End Select
End Sub

Public Sub Alert (info As AlertInfo) As String
	Return MH.Alert(info)
End Sub

Public Sub Toast (data As List, info As ToastInfo) As String
	Return MH.Toast("categories-container", CategoriesTableFilled(data), info)
End Sub

Public Sub RenderedTable (data As List) As String
	Return CategoriesTableFilled(data).build
End Sub

Private Sub CreateOrReadFromCache (CacheName As String) As MiniHtml
	Select CacheName
		Case "Categories Page", "Categories Table"
			If MC.ExistInCache(App.ctx, CacheName) Then
				Return MC.ReadFromCache(App.ctx, CacheName)
			End If
	End Select
	Dim Segment As MiniHtml
	Select CacheName
		Case "Categories Page"
			Segment = CategoriesPage
		Case "Categories Table"
			Segment = CategoriesTable
		Case "Categories Table Row"
			Segment = CategoriesTableRow
		Case "Categories Add Modal"
			Segment = ModalAdd
		Case "Categories Edit Modal"
			Segment = ModalEdit
		Case "Categories Delete Modal"
			Segment = ModalDelete
		Case Else
			Segment.Initialize("")
	End Select
	MC.WriteToCache(App.ctx, CacheName, Segment.ConvertToBytes)
	Return Segment
End Sub

Private Sub CategoriesPage As MiniHtml
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContainerContent)
	main1.LoadModal(MH.ContainerModal)
	main1.LoadToast(MH.ContainerToast)
	Dim page1 As MiniHtml = main1.Render
	Dim nav1 As MiniHtml = page1.ChildByClass("navbar-nav") 'ul
	If App.api.EnableHelp Then
		MH.NavLinkItem("API", "/help", "bi bi-gear me-2", "API").up(nav1)
	End If
	MH.NavLinkItem("Home", "/", "bi bi-house me-2", "Home").up(nav1)
	Return page1
End Sub

Private Sub ContainerContent As MiniHtml
	Dim row1 As MiniHtml = MH.Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As MiniHtml = MH.Div.up(row1).cls("col-md-12 col-lg-6")
	Dim form1 As MiniHtml = MH.Form.up(col1).cls("form mb-3").attr("action", "")
	Dim row2 As MiniHtml = MH.Div.up(form1).cls("row")
	Dim col2 As MiniHtml = MH.Div.up(row2).cls("col-md-6 col-lg-6 text-start")
	MH.H3.up(col2).text("CATEGORY LIST")
	Dim div1 As MiniHtml = MH.Div.up(row2).cls("col-md-6 col-lg-6")
	Dim div2 As MiniHtml = MH.Div.up(div1).cls("text-end mt-2")
	MH.ButtonAdd("Add Category", "btn btn-success ml-2", "/hx/categories/add", "#modal-content", "click", "#modal-container", "modal").up(div2)
	MH.ContainerHxGet("categories-container", "/hx/categories/table", "load", "Loading...").up(col1)
	Return row1
End Sub

Public Sub CategoriesTableFilled (data As List) As MiniHtml
	Dim table1 As MiniHtml = CreateOrReadFromCache("Categories Table")
	Dim tbody1 As MiniHtml = table1.ChildByName("tbody")
	tbody1.Children.Clear
	For Each row As Map In data
		Dim tr1 As MiniHtml = CreateOrReadFromCache("Categories Table Row")
		tr1.child(0).text2(row.Get("id"))
		tr1.child(1).text2(row.Get("category_name"))
		tr1.child(2).child(0).attr("hx-get", "/hx/categories/edit/" & row.Get("id"))
		tr1.child(2).child(1).attr("hx-get", "/hx/categories/delete/" & row.Get("id"))
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
	MH.Td.up(tr1).cls("align-middle").sty("text-align: right")
	MH.Td.up(tr1).cls("align-middle")
	Dim td3 As MiniHtml = MH.Td.up(tr1).cls("align-middle text-center px-1 py-1")
	MH.AnchorIcon("edit text-primary mx-2", "/hx/categories/edit/{id}", "Edit", "bi bi-pencil").up(td3)
	MH.AnchorIcon("delete text-danger mx-2", "/hx/categories/delete/{id}", "Delete", "bi bi-trash3").up(td3)
	Return tr1
End Sub

Private Sub ModalAdd As MiniHtml	
	Dim form1 As MiniHtml = MH.FormHxPost("/hx/categories", "#modal-messages")
	MH.ModalHeader("Add Category").up(form1)
	Dim mb1 As MiniHtml = MH.ModalBody.up(form1)
	MH.ModalMessage.up(mb1)
	Dim fg1 As MiniHtml = MH.FormGroup.up(mb1)
	MH.RequiredLabel("Name ", "name").up(fg1)
	MH.RequiredTextInput("name", "name", "").up(fg1)
	MH.ModalFooter("Create", "Cancel", "success", "secondary").up(form1)
	Return form1
End Sub

Private Sub ModalEdit As MiniHtml	
	Dim form1 As MiniHtml = MH.FormHxPut("/hx/categories", "#modal-messages")
	MH.ModalHeader("Edit Category").up(form1)
	Dim mb1 As MiniHtml = MH.ModalBody.up(form1)
	MH.ModalMessage.up(mb1)
	MH.HiddenInput("id", "id", "").up(mb1)
	Dim fg1 As MiniHtml = MH.FormGroup.up(mb1)
	MH.RequiredLabel("Name ", "name").up(fg1)
	MH.RequiredTextInput("name", "name", "").up(fg1)
	MH.ModalFooter("Update", "Cancel", "primary", "secondary").up(form1)
	Return form1
End Sub

Private Sub ModalDelete As MiniHtml	
	Dim form1 As MiniHtml = MH.FormHxDelete("/hx/categories", "#modal-messages")
	MH.ModalHeader("Delete Category").up(form1)
	Dim mb1 As MiniHtml = MH.ModalBody.up(form1)
	MH.ModalMessage.up(mb1)
	MH.HiddenInput("id", "id", "").up(mb1)
	MH.P.up(mb1).Id = "p1"
	MH.ModalFooter("Delete", "Cancel", "danger", "secondary").up(form1)
	Return form1
End Sub