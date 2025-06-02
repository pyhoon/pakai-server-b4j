B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'Api Handler class
'Version 4.00 beta 9
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private DB As MiniORM
	Private Method As String
	Private Elements() As String
	Private ElementId As Int
End Sub

Public Sub Initialize
	HRM.Initialize
	HRM.PayloadType = Main.conf.PayloadType
	HRM.ContentType = Main.conf.ContentType
	HRM.VerboseMode = Main.conf.VerboseMode
	HRM.OrderedKeys = Main.conf.OrderedKeys
	If HRM.VerboseMode Then
		HRM.ResponseKeys = Array("a", "s", "e", "m", "r")
		HRM.ResponseKeysAlias = Array("code", "status", "error", "message", "data")
	End If
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3)
	Select Method
		Case "GET"
			If ElementMatch("") Then
				GetProducts
				Return
			End If
			If ElementMatch("id") Then
				GetProductById(ElementId)
				Return
			End If
		Case "POST"
			If ElementMatch("") Then
				PostProduct
				Return
			End If
		Case "PUT"
			If ElementMatch("id") Then
				PutProductById(ElementId)
				Return
			End If
		Case "DELETE"
			If ElementMatch("id") Then
				DeleteProductById(ElementId)
				Return
			End If
		Case Else
			Log("Unsupported method: " & Method)
			ReturnMethodNotAllow
			Return
	End Select
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
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products"
	DB.Query
	HRM.ResponseCode = 200
	If HRM.OrderedKeys Then
		HRM.ResponseData = DB.Results2
	Else
		HRM.ResponseData = DB.Results
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub GetProductById (id As Int)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products"
	DB.Find(id)
	If DB.Found Then
		HRM.ResponseCode = 200
		If HRM.OrderedKeys Then
			HRM.ResponseObject = DB.Results2.Get(0)
		Else
			HRM.ResponseObject = DB.First
		End If
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub PostProduct
	'Dim data As Map = WebApiUtils.RequestData(Request)
	'If NotInitialized(data) Then
	'	HRM.ResponseCode = 400
	'	HRM.ResponseError = "Invalid json object"
	'	ReturnApiResponse
	'	Return
	'End If
	'Try
	'	Dim str As String = WebApiUtils.RequestDataText(Request)
	'	Dim data As Map = str.As(JSON).ToMap
	'Catch
	'	HRM.ResponseCode = 422
	'	'HRM.ResponseError = LastException.Message
	'	HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
	'	ReturnApiResponse
	'	Return
	'End Try
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
		Return
	End If
	Select HRM.PayloadType
		Case "xml"
			Dim data As Map = WebApiUtils.ParseXML(str).Get("root") ' XML
		Case Else
			Dim data As Map = str.As(JSON).ToMap ' JSON
	End Select
	Log(data)
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
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products"
	DB.Where = Array("product_code = ?")
	DB.Parameters = Array As String(data.Get("product_code"))
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product already exist"
		ReturnApiResponse
		DB.Close
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

	' Retrieve new row
	HRM.ResponseCode = 201
	If HRM.OrderedKeys Then
		HRM.ResponseObject = DB.Results2.Get(0)
	Else
		HRM.ResponseObject = DB.First
	End If
	HRM.ResponseMessage = "Product created successfully"
	ReturnApiResponse
	DB.Close
End Sub

Private Sub PutProductById (id As Int)
	'Dim data As Map = WebApiUtils.RequestData(Request)
	'If Not(data.IsInitialized) Then
	'	HRM.ResponseCode = 400
	'	HRM.ResponseError = "Invalid json object"
	'	ReturnApiResponse
	'	Return
	'End If
	Try
		Dim str As String = WebApiUtils.RequestDataText(Request)
		Dim data As Map = str.As(JSON).ToMap
	Catch
		HRM.ResponseCode = 422
		'HRM.ResponseError = LastException.Message
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End Try
	' Check conflict product code
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products"
	DB.Where = Array("product_code = ?", "id <> ?")
	DB.Parameters = Array As String(data.Get("product_code"), id)
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Product Code already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
		ReturnApiResponse
		DB.Close
		Return
	End If

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

	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Product updated successfully"
	If HRM.OrderedKeys Then
		HRM.ResponseObject = DB.Results2.Get(0)
	Else
		HRM.ResponseObject = DB.First
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub DeleteProductById (id As Int)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products"
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Product not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	
	DB.Reset
	DB.Id = id
	DB.Delete
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Product deleted successfully"
	ReturnApiResponse
	DB.Close
End Sub