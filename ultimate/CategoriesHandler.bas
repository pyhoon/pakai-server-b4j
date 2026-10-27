B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private App As EndsMeet, Path As String, Method As String, View As CategoriesView, Model As CategoriesModel, Request As ServletRequest, Response As ServletResponse
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

Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub

Sub HandleTable
	Dim Rows As List = Model.Read
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

Sub HandleModalAdd
	App.WriteHtml(Response, View.Modal("Add", Null))
End Sub

Sub HandleModalEdit
	Try
		Dim id As Int = Path.SubString("/hx/categories/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Category As Map = Model.GetRowById(id)
	If ModelError Then Return
	App.WriteHtml2(Response, View.Modal("Edit", Category), Category)
End Sub

Sub HandleModalDelete
	Try
		Dim id As Int = Path.SubString("/hx/categories/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Category As Map = Model.GetRowById(id)
	If ModelError Then Return
	App.WriteHtml2(Response, View.Modal("Delete", Category), Category)
End Sub

Sub HandleCategories
	Select Method
		Case "POST"
			' Create
			Dim name As String = Request.GetParameter("name")
			If name = "" Or name.Trim.Length < 2 Then
				ShowAlert("Category name must be at least 2 characters long.", "warning")
				Return
			End If
			Dim Found As Boolean = Model.FindRowByName(name)
			If ModelError Then Return
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			Model.Create(name)
			If ModelError Then Return
			ShowToast("Category", "created", "Category created successfully!", "success")
		Case "PUT"
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
			If ModelError Then Return
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			Model.Update(id, name)
			If ModelError Then Return
			ShowToast("Category", "updated", "Category updated successfully!", "info")
		Case "DELETE"
			Dim id As Int = Request.GetParameter("id")
			Dim Found As Boolean = Model.FindRowById(id)
			If ModelError Then Return
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			Dim Found As Boolean = Model.FindProductByCategoryId(id)
			If ModelError Then Return
			If Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				Return
			End If
			Model.Delete(id)
			If ModelError Then Return
			ShowToast("Category", "deleted", "Category deleted successfully!", "danger")
	End Select
End Sub

Sub ModelError As Boolean
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return True
	End If
	Return False
End Sub

Sub ShowAlert (Message As String, Status As String)
	App.WriteHtml(Response, MH.Alert(Message, Status))
End Sub

Sub ShowToast (Entity As String, Action As String, Message As String, Status As String)
	App.WriteHtml(Response, View.Toast(Model.Read, CreateMap("entity": Entity, "action": Action, "message": Message, "status": Status)))
End Sub