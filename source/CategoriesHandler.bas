B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
' Version 6.80
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As CategoriesView
	Private Model As CategoriesModel
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	View.Initialize
	Model.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	Log($"${Method}: ${Path}"$)
	If Path = "/categories" Then
		HandlePage
	Else If Path = "/hx/categories/table" Then
		HandleTable
	Else If Path = "/hx/categories/add" Then
		HandleModalAdd
	Else If Path.StartsWith("/hx/categories/edit/") Then
		HandleModalEdit
	Else If Path.StartsWith("/hx/categories/delete/") Then
		HandleModalDelete
	Else
		HandleCategories
	End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub

' Return table HTML
Private Sub HandleTable
	Dim Rows As List = Model.Read
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

' Add modal
Private Sub HandleModalAdd
	App.WriteHtml(Response, View.Modal("Add"))
End Sub

' Edit modal
Private Sub HandleModalEdit
	Try
		Dim id As Int = Path.SubString("/hx/categories/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	
	Dim Category As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If	
	App.WriteHtml2(Response, View.Modal("Edit"), Category)
End Sub

' Delete modal
Private Sub HandleModalDelete
	Try
		Dim id As Int = Path.SubString("/hx/categories/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Category As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If	
	App.WriteHtml2(Response, View.Modal("Delete"), Category)
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
			
			Dim Found As Boolean = Model.FindRowByName(name)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			
			' Insert new row
			Model.Create(name, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "created", "Category created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindRowByCategoryNameNotEqualId(name, id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			
			' Update row
			Model.Update(id, name, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "updated", "Category updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindProductByCategoryId(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				Return
			End If
			
			' Delete row
			Model.Delete(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "deleted", "Category deleted successfully!", "danger")
	End Select
End Sub

Private Sub ShowAlert (Message As String, Status As String)
	Dim info As AlertInfo = Main.CreateAlertInfo(Message, Status)
	App.WriteHtml(Response, View.Alert(info))
End Sub

Private Sub ShowToast (Entity As String, Action As String, Message As String, Status As String)
	Dim data As List = Model.Read
	Dim info As ToastInfo = Main.CreateToastInfo(Entity, Action, Message, Status)
	App.WriteHtml(Response, View.Toast(info, data))
End Sub