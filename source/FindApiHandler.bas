B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Find Api Handler class
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
	Private ElementKey As String
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
	Elements = WebApiUtils.CropElements(FullElements, 3)
	If ElementMatch("") Then
		If App.MethodAvailable2(Method, "/api/find", Me) Then
			Select Method
				Case "GET"
					GetAllProducts
					Return
				Case "POST"
					SearchByKeywords
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	Else If ElementMatch("key/id") Then
		If App.MethodAvailable2(Method, "/api/find/products-by-category_id/*", Me) Then
			If ElementKey = "products-by-category_id" Then
				GetProductsByCategoryId(ElementId)
				Return
			End If
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

Private Sub GetAllProducts
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = Array("tbl_categories c", "p.category_id = c.id")
	DB.OrderBy = CreateMap("p.id": "")
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

Public Sub GetProductsByCategoryId (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = Array("tbl_categories c", "p.category_id = c.id")
	DB.Condition = "c.id = ?"
	DB.Parameter = id
	DB.OrderBy = CreateMap("p.id": "")
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

Public Sub SearchByKeywords
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
	If data.ContainsKey("keyword") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'keyword' not found"
		ReturnApiResponse
		Return
	End If
	Dim SearchForText As String = data.Get("keyword")
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name AS name", "p.product_price price")
	DB.Join = Array("tbl_categories c", "p.category_id = c.id")
	If SearchForText <> "" Then
		DB.Conditions = Array("p.product_code LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?")
		DB.Parameters = Array("%" & SearchForText & "%", "%" & SearchForText.ToUpperCase & "%", "%" & SearchForText.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "")
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