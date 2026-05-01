B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Find Api Handler class
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
	
	Dim Data As List = Model.GetRowsByCategoryId(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = Data
	End If
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
	Dim keyword As String = data.Get("keyword")
	
	Dim results As List = Model.Search(keyword)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = results
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub