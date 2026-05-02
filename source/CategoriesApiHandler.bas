B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Api Handler class
' Version 6.80
Sub Class_Globals
	Private Path As String
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Model As CategoriesModel
End Sub

Public Sub Initialize
	HRM = Main.HRM
	Model.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	If Path = "/api/categories" And Method = "GET" Then
		GetCategories
	Else If Path = "/api/categories" And Method = "POST" Then
		PostCategory
	Else If Path.StartsWith("/api/categories/") And Method = "GET" Then
		GetCategoryById
	Else If Path.StartsWith("/api/categories/") And Method = "PUT" Then
		PutCategoryById
	Else If Path.StartsWith("/api/categories/") And Method = "DELETE" Then
		DeleteCategoryById
	Else
		WebApiUtils.ReturnBadRequest(HRM, Response)
	End If
End Sub

Private Sub GetCategories
	Log($"${Method}: ${Path}"$)
	Dim Data As List = Model.Read
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = Data
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub GetCategoryById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/categories/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	Dim Row As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
	Else
		If Model.Found Then
			HRM.ResponseCode = 200
			HRM.ResponseObject = Row
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Category not found"
		End If
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PostCategory
	Log($"${Method}: ${Path}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If HRM.PayloadType = WebApiUtils.MIME_TYPE_XML Then
		Dim data As Map = WebApiUtils.ParseXML(str)		' XML payload
	Else
		Dim data As Map = WebApiUtils.ParseJSON(str)	' JSON payload
	End If
	
	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("category_name")
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	
	' Check conflict category name
	Dim name As String = data.Get("category_name")
	Dim Found As Boolean = Model.FindRowByName(name)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Category already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Insert new row
	Model.Create(name, Main.CurrentDateTime)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Retrieve new row
	HRM.ResponseCode = 201
	HRM.ResponseObject = Model.First
	HRM.ResponseMessage = "Category created successfully"
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PutCategoryById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/categories/".Length)
		
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If HRM.PayloadType = WebApiUtils.MIME_TYPE_XML Then
		Dim data As Map = WebApiUtils.ParseXML(str)		' XML payload
	Else
		Dim data As Map = WebApiUtils.ParseJSON(str)	' JSON payload
	End If
	
	' Check whether required keys are provided
	If data.ContainsKey("category_name") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'category_name' not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Find row by id
	Dim Found As Boolean = Model.FindRowById(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Not(Found) Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Check conflict category name
	Dim name As String = data.Get("category_name")
	Dim Found As Boolean = Model.FindRowByCategoryNameNotEqualId(name, id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Category already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Update row by id
	Model.Update(id, name, Main.CurrentDateTime)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If

	' Return updated row
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Category updated successfully"
	HRM.ResponseObject = Model.First
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub DeleteCategoryById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/categories/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	' Find row by id
	Dim Found As Boolean = Model.FindRowById(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Not(Found) Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Delete row
	Model.Delete(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Category deleted successfully"
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub