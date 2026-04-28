B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Products Api Handler class
' Version 6.60
Sub Class_Globals
	Private DB As MiniORM
	Private HRM As HttpResponseMessage
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private Path As String
	Private Method As String
End Sub

Public Sub Initialize
	DB = Main.DB
	HRM = Main.HRM
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
	DB.Open
	DB.Table = "tbl_products"
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = DB.Results
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
	
	DB.Open
	DB.Table = "tbl_products"
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		If DB.Found Then
			HRM.ResponseCode = 200
			HRM.ResponseObject = DB.First
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
	
	' Check conflict product code
	DB.Open
	DB.Table = "tbl_products"
	DB.Conditions = Array("product_code = ?")
	DB.Parameters = Array(data.Get("product_code"))
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Insert new row
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("category_id", _
	"product_code", _
	"product_name", _
	"product_price", _
	"created_date")
	DB.Parameters = Array(data.Get("category_id"), _
	data.Get("product_code"), _
	data.Get("product_name"), _
	data.GetDefault("product_price", 0), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Retrieve new row
		HRM.ResponseCode = 201
		HRM.ResponseObject = DB.First
		HRM.ResponseMessage = "Product created successfully"
	End If
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
	
	' Check conflict product code
	DB.Open
	DB.Table = "tbl_products"
	DB.Conditions = Array("product_code = ?", "id <> ?")
	DB.Parameters = Array(data.Get("product_code"), id)
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product Code already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Find row by id
	DB.Open
	DB.Table = "tbl_products"
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Update row by id
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("category_id", _
	"product_code", _
	"product_name", _
	"product_price", _
	"modified_date")
	DB.Parameters = Array(data.Get("category_id"), _
	data.Get("product_code"), _
	data.Get("product_name"), _
	data.GetDefault("product_price", 0), _
	data.GetDefault("modified_date", WebApiUtils.CurrentDateTime))
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Return updated row
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "Product updated successfully"
		HRM.ResponseObject = DB.First
	End If
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
	DB.Open
	DB.Table = "tbl_products"
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Delete row
	DB.Open
	DB.Table = "tbl_products"
	DB.Id = id
	DB.Delete
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "Product deleted successfully"
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub