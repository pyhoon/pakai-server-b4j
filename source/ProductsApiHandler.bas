B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Products Api Handler class
' Version 6.80
Sub Class_Globals
	Private Path As String
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Model As ProductsModel
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
	If Path = "/api/products" And Method = "GET" Then
		GetProducts
	Else If Path = "/api/products" And Method = "POST" Then
		PostProduct
	Else If Path.StartsWith("/api/products/") And Method = "GET" Then
		GetProductById
	Else If Path.StartsWith("/api/products/") And Method = "PUT" Then
		PutProductById
	Else If Path.StartsWith("/api/products/") And Method = "DELETE" Then
		DeleteProductById
	Else
		WebApiUtils.ReturnBadRequest(HRM, Response)
	End If
End Sub

Private Sub GetProducts
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

Private Sub GetProductById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/products/".Length)
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
			HRM.ResponseError = "Product not found"
		End If
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PostProduct
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
	Dim RequiredKeys As List = Array As String("category_id", "product_code", "product_name") ' "product_price" is optional
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	
	Dim category_id As Int = data.Get("category_id")
	Dim product_code As String = data.Get("product_code")
	Dim product_name As String = data.Get("product_name")
	Dim product_price As Double = data.GetDefault("product_price", 0)
	
	' Check conflict product code
	Dim Found As Boolean = Model.FindRowByProductCode(product_code)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Insert new row
	Model.Create(category_id, product_code, product_name, product_price, Main.CurrentDateTime)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Retrieve new row
	HRM.ResponseCode = 201
	HRM.ResponseObject = Model.First
	HRM.ResponseMessage = "Product created successfully"
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PutProductById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/products/".Length)
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
	Dim RequiredKeys As List = Array As String("category_id", "product_code", "product_name") ' "product_price" is optional
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	
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
		HRM.ResponseError = "Product not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	Dim category_id As Int = data.Get("category_id")
	Dim product_code As String = data.Get("product_code")
	Dim product_name As String = data.Get("product_name")
	Dim product_price As Double = data.GetDefault("product_price", 0)
	
	' Check conflict product code
	Dim Found As Boolean = Model.FindRowByProductCodeNotEqualId(product_code, id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product Code already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Update row by id
	Model.Update(id, category_id, product_code, product_name, product_price, Main.CurrentDateTime)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If

	' Return updated row
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Product updated successfully"
	HRM.ResponseObject = Model.First

	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub DeleteProductById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/products/".Length)
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
		HRM.ResponseError = "Product not found"
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
	HRM.ResponseMessage = "Product deleted successfully"
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub