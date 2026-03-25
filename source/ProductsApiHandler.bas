B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Products Api Handler class
' Version 6.51
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Method As String
	Private Elements() As String
	Private ElementId As Int
End Sub

Public Sub Initialize
	DB = Main.DB
	App = Main.App
	HRM.Initialize
	Main.SetApiMessage(HRM)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3) ' 3 For Api handler
	If ElementMatch("") Then
		If App.MethodAvailable2(Method, "/api/products", Me) Then
			Select Method
				Case "GET"
					GetProducts
					Return
				Case "POST"
					PostProduct
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	Else If ElementMatch("id") Then
		If App.MethodAvailable2(Method, "/api/products/*", Me) Then
			Select Method
				Case "GET"
					GetProductById(ElementId)
					Return
				Case "PUT"
					PutProductById(ElementId)
					Return
				Case "DELETE"
					DeleteProductById(ElementId)
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	End If
	ReturnBadRequest
End Sub

Private Sub ElementMatch (Pattern As String) As Boolean
	Select Pattern
		Case ""
			If Elements.Length = 0 Then
				Return True
			End If
		Case "id"
			If Elements.Length = 1 Then
				If IsNumber(Elements(0)) Then
					ElementId = Elements(0)
					Return True
				End If
			End If
	End Select
	Return False
End Sub

Private Sub ReturnApiResponse
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub ReturnBadRequest
	WebApiUtils.ReturnBadRequest(HRM, Response)
End Sub

Private Sub ReturnMethodNotAllow
	WebApiUtils.ReturnMethodNotAllow(HRM, Response)
End Sub

Private Sub GetProducts
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Open
	DB.Table = "tbl_products"
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = DB.Results2
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub GetProductById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Open
	DB.Table = "tbl_products"
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		If DB.Found Then
			HRM.ResponseCode = 200
			HRM.ResponseObject = DB.First2
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Product not found"
		End If
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PostProduct
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
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
			ReturnApiResponse
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
		DB.Close
		ReturnApiResponse
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product already exist"
		DB.Close
		ReturnApiResponse
		Return
	End If
	' Insert new row
	DB.Reset
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
		HRM.ResponseObject = DB.First2
		HRM.ResponseMessage = "Product created successfully"
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PutProductById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
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
			ReturnApiResponse
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
		DB.Close
		ReturnApiResponse
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product Code already exist"
		DB.Close
		ReturnApiResponse
		Return
	End If
	' Find row by id
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		DB.Close
		ReturnApiResponse
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
		DB.Close
		ReturnApiResponse
		Return
	End If
	' Update row by id
	DB.Reset
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
	DB.Id = id
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Return updated row
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "Product updated successfully"
		HRM.ResponseObject = DB.First2
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub DeleteProductById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Open
	DB.Table = "tbl_products"
	' Find row by id
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		DB.Close
		ReturnApiResponse
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
		DB.Close
		ReturnApiResponse
		Return
	End If
	' Delete row
	DB.Reset
	DB.Id = id
	DB.Delete
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "Product deleted successfully"
	End If
	DB.Close
	ReturnApiResponse
End Sub