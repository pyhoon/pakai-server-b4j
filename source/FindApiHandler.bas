B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'Api Handler class
'Version 4.00 beta 6
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private DB As MiniORM
	Private Method As String
	Private Elements() As String
	Private ElementKey As String
	Private ElementId As Int
End Sub

Public Sub Initialize
	HRM.Initialize
	HRM.PayloadType = Main.conf.PayloadType
	HRM.ContentType = Main.conf.ContentType
	HRM.VerboseMode = Main.conf.VerboseMode
	HRM.OrderedKeys = Main.conf.OrderedKeys
	HRM.XmlElement = "item"
	'If HRM.PayloadType = "" Then HRM.PayloadType = "json"
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
				GetAllProducts
				Return
			End If
			If ElementMatch("key/id") Then
				If ElementKey = "products-by-category_id" Then
				GetProductsByCategoryId(ElementId)
				Return
				End If
			End If
		Case "POST"
			If ElementMatch("") Then
				SearchByKeywords
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
		Case "key/id"
			If Elements.Length = 2 Then
				ElementKey = Elements(0)
				If IsNumber(Elements(1)) Then
					ElementId = Elements(1)
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

Public Sub GetAllProducts
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products p"
	DB.Select = Array("category_id catid", "category_name category", "p.id id", "product_code code", "product_name name", "product_price price")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	If HRM.OrderedKeys Then
		HRM.ResponseKeys = Array("a", "s", "m", "e", "r")
		HRM.ResponseKeysAlias = Array("code", "status", "message", "error", "data")	' if ok, then show message first
		HRM.ResponseData = DB.Results2
	Else
		HRM.ResponseData = DB.Results
	End If
	DB.Close
	ReturnApiResponse
End Sub

Public Sub GetProductsByCategoryId (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products p"
	DB.Select = Array("p.*", "c.category_name")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	DB.WhereParam("c.id = ?", id)
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	If HRM.OrderedKeys Then
		HRM.ResponseKeys = Array("a", "s", "m", "e", "r")
		HRM.ResponseKeysAlias = Array("code", "status", "message", "error", "data")	' if ok, then show message first
		HRM.ResponseData = DB.Results2
	Else
		HRM.ResponseData = DB.Results
	End If
	DB.Close
	ReturnApiResponse
End Sub

Public Sub SearchByKeywords
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	'Try
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
		'Log(data)
	'Catch
	'	HRM.ResponseCode = 422
	'	'HRM.ResponseError = LastException.Message
	'	HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
	'	ReturnApiResponse
	'	Return
	'End Try
	'If HRM.ContentType = WebApiUtils.CONTENT_TYPE_XML Then
	'	data = data.Get("root")
	'End If
	' Check whether required keys are provided
	If data.ContainsKey("keyword") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'keyword' not found"
		ReturnApiResponse
		Return
	End If
	Dim SearchForText As String = data.Get("keyword")
	
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_products p"
	DB.Select = Array("p.id id", "product_code code", "product_name AS name", "category_id catid", "category_name category", "product_price price")
	DB.Join = DB.CreateJoin("tbl_categories c", "p.category_id = c.id", "")
	If SearchForText <> "" Then
		DB.Where = Array("p.product_code LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?")
		DB.Parameters = Array("%" & SearchForText & "%", "%" & SearchForText.ToUpperCase & "%", "%" & SearchForText.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	If HRM.OrderedKeys Then
		HRM.ResponseData = DB.Results2
		HRM.ResponseKeys = Array("m", "a", "r", "s", "e")
		HRM.ResponseKeysAlias = Array("message", "code", "data", "status", "error")
	Else
		HRM.ResponseData = DB.Results
	End If
	DB.Close
	ReturnApiResponse
End Sub