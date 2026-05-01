B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Products Handler class
' Version 6.80
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As ProductsView
	Private Model As ProductsModel
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
	If Path = "/" Then
		HandlePage
	Else If Path = "/hx/products/table" Then
		HandleTable
	Else If Path = "/hx/products/add" Then
		HandleModalAdd
	Else If Path.StartsWith("/hx/products/edit/") Then
		HandleModalEdit
	Else If Path.StartsWith("/hx/products/delete/") Then
		HandleModalDelete
	Else
		HandleProducts
	End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub

' Return default or search results table
Private Sub HandleTable
	Dim keyword As String = Request.GetParameter("keyword")
	Dim Rows As List = Model.Search(keyword)
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

' Add modal
Private Sub HandleModalAdd
	Dim CM As CategoriesModel
	CM.Initialize
	Dim Categories As List = CM.Read
	If CM.Error.IsInitialized Then
		ShowAlert($"Database error: ${CM.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Add", Categories, Null))
End Sub

' Edit modal
Private Sub HandleModalEdit
	Try
		Dim id As Int = Path.SubString("/hx/products/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim CM As CategoriesModel
	CM.Initialize
	Dim Categories As List = CM.Read
	If CM.Error.IsInitialized Then
		ShowAlert($"Database error: ${CM.Error.Message}"$, "danger")
		Return
	End If
	Dim Product As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Edit", Categories, Product))
End Sub

' Delete modal
Private Sub HandleModalDelete
	Try
		Dim id As Int = Path.SubString("/hx/products/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Product As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Delete", Null, Product))
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
			Dim Found As Boolean = Model.FindRowByProductCode(code)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Product Code already exists!", "warning")
				Return
			End If

			' Insert new row
			Model.Create(category, code, name, price, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If			
			ShowToast("Product", "created", "Product created successfully!", "success")
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
			
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Product not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindRowByProductCodeNotEqualId(code, id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Product Code already exists!", "warning")
				Return
			End If
			
			' Update row
			Model.Update(id, category, code, name, price, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Product", "updated", "Product updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Product not found!", "warning")
				Return
			End If

			' Delete row
			Model.Delete(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Product", "deleted", "Product deleted successfully!", "danger")
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