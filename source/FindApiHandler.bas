B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Find Api Handler class
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
	If Path = "/api/find" And Method = "GET" Then
		GetAllProducts
	Else If Path = "/api/find" And Method = "POST" Then
		SearchByKeywords
	Else If Path.StartsWith("/api/find/products-by-category_id/") And Method = "GET" Then
		GetProductsByCategoryId
	Else
		WebApiUtils.ReturnBadRequest(HRM, Response)
	End If
End Sub

Private Sub GetAllProducts
	Log($"${Method}: ${Path}"$)
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name name", "p.product_price price")
	DB.Join = DB.CreateJoin("", "tbl_categories AS c", Array("p.category_id = c.id"))
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = DB.Results
	End If
	DB.Close
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Public Sub GetProductsByCategoryId
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/find/products-by-category_id/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	DB.Open
	DB.Table = "tbl_products AS p"
	DB.Columns = Array("p.id AS id", "p.category_id AS catid", "c.category_name AS category", "p.product_code AS code", "p.product_name AS name", "p.product_price AS price")
	DB.Join = DB.CreateJoin("", "tbl_categories AS c", Array("p.category_id = c.id"))
	DB.Condition = "c.id = ?"
	DB.Parameter = id
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = DB.Results
	End If
	DB.Close
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Public Sub SearchByKeywords
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
	If data.ContainsKey("keyword") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'keyword' not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	Dim SearchForText As String = data.Get("keyword")
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name AS name", "p.product_price price")
	DB.Join = DB.CreateJoin("", "tbl_categories AS c", Array("p.category_id = c.id"))
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
		HRM.ResponseData = DB.Results
	End If
	DB.Close
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub