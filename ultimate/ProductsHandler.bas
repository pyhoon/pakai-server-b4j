B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private App As EndsMeet, Path As String, Method As String, View As ProductsView, Model As ProductsModel, Model2 As CategoriesModel, Request As ServletRequest, Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	View.Initialize
	Model.Initialize
	Model2.Initialize
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

Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub

Sub HandleTable
	Dim keyword As String = Request.GetParameter("keyword")
	Dim Rows As List = Model.Search(keyword)
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

Sub HandleModalAdd
	Dim Categories As List = Model2.Read
	If Model2Error Then Return
	App.WriteHtml(Response, View.Modal("Add", Categories, Null))
End Sub

Sub HandleModalEdit
	Try
		Dim id As Int = Path.SubString("/hx/products/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Categories As List = Model2.Read
	If Model2Error Then Return
	Dim Product As Map = Model.GetRowById(id)
	If ModelError Then Return
	App.WriteHtml(Response, View.Modal("Edit", Categories, Product))
End Sub

Sub HandleModalDelete
	Try
		Dim id As Int = Path.SubString("/hx/products/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Product As Map = Model.GetRowById(id)
	If ModelError Then Return
	App.WriteHtml(Response, View.Modal("Delete", Null, Product))
End Sub

Sub HandleProducts
	Select Method
		Case "POST"
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim tempprice As String = Request.GetParameter("price")
			Dim price As Double = IIf(tempprice.Trim = "", 0, tempprice)
			Dim category As Int = Request.GetParameter("category")
			If code = "" Or code.Trim.Length < 2 Then
				ShowAlert("Product Code must be at least 2 characters long.", "warning")
				Return
			End If
			Dim Found As Boolean = Model.FindRowByProductCode(code)
			If ModelError Then Return
			If Found Then
				ShowAlert("Product Code already exists!", "warning")
				Return
			End If
			Model.Create(category, code, name, price)
			If ModelError Then Return
			ShowToast("Product", "created", "Product created successfully!", "success")
		Case "PUT"
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
			If ModelError Then Return
			If Not(Found) Then
				ShowAlert("Product not found!", "warning")
				Return
			End If
			Dim Found As Boolean = Model.FindRowByProductCodeNotEqualId(code, id)
			If ModelError Then Return
			If Found Then
				ShowAlert("Product Code already exists!", "warning")
				Return
			End If
			Model.Update(id, category, code, name, price)
			If ModelError Then Return
			ShowToast("Product", "updated", "Product updated successfully!", "info")
		Case "DELETE"
			Dim id As Int = Request.GetParameter("id")
			Dim Found As Boolean = Model.FindRowById(id)
			If ModelError Then Return
			If Not(Found) Then
				ShowAlert("Product not found!", "warning")
				Return
			End If
			Model.Delete(id)
			If ModelError Then Return
			ShowToast("Product", "deleted", "Product deleted successfully!", "danger")
	End Select
End Sub

Sub ModelError As Boolean
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return True
	End If
	Return False
End Sub

Sub Model2Error As Boolean
	If Model2.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model2.Error.Message}"$, "danger")
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