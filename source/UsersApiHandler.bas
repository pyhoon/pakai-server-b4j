B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Users Api Handler class
' Version 6.36
Sub Class_Globals
	'Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Method As String
	'Private Elements() As String
End Sub

Public Sub Initialize
	'App = Main.App
	HRM.Initialize
	Main.SetApiMessage(HRM)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	'Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	'Elements = WebApiUtils.CropElements(FullElements, 3) ' 3 For Api handler
	'If ElementMatch("") Then
	'	If App.MethodAvailable2(Method, "/client", Me) Then
	'		RenderPage
	'		Return
	'	End If
	'	If App.MethodAvailable2(Method, "/api/login", Me) Then
	'		Select Method
	'			Case "POST"
	'				PostLogin
	'				Return
	'		End Select
	'	End If
	'	If App.MethodAvailable2(Method, "/api/secure-data", Me) Then
	'		Select Method
	'			Case "GET"
	'				GetSecureData
	'				Return
	'		End Select
	'	End If
	'	ReturnMethodNotAllow
	'	Return
	'End If
	Dim path As String = req.RequestURI
	If path = "/client" And Method = "GET" Then
		RenderPage
		Return
	Else If path = "/api/login" And Method = "POST" Then
		PostLogin
		Return
	Else If path = "/api/secure-data" And Method = "GET" Then
		GetSecureData
		Return
	End If	
	ReturnBadRequest
End Sub

'Private Sub ElementMatch (Pattern As String) As Boolean
'	Select Pattern
'		Case ""
'			If Elements.Length = 0 Then
'				Return True
'			End If
'	End Select
'	Return False
'End Sub

Private Sub ReturnApiResponse
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub ReturnBadRequest
	WebApiUtils.ReturnBadRequest(HRM, Response)
End Sub

'Private Sub ReturnMethodNotAllow
'	WebApiUtils.ReturnMethodNotAllow(HRM, Response)
'End Sub

Private Sub RenderPage
	'Dim page As String = File.ReadString(File.DirAssets, "client.html")
	Dim page As String = File.ReadString(File.DirAssets, "test.html")
	Response.ContentType = WebApiUtils.MIME_TYPE_HTML
	Response.Write(page)
End Sub

Private Sub GetSecureData
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim token As String = WebApiUtils.RequestBearerToken(Request)
	Log(token)
	If token.EqualsIgnoreCase("null") Then
		'HRM.ResponseCode = 409
		'HRM.ResponseError = "Unauthorized Access"
		Response.SendError(401, "Unauthorized Access")
	Else		
		HRM.ResponseCode = 200
		HRM.ResponseObject = CreateMap("data1": "secure data", "data2": Rnd(100000, 200000))
		ReturnApiResponse
	End If
End Sub

Private Sub PostLogin
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	'Dim str As String = WebApiUtils.RequestDataJson(Request).As(JSON).ToString
	Log(str)
	
	'Log(Request.ParameterMap)
	'Dim L As List = Request.GetParameterValues("username")
	'Log(L)
	
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
	'Dim result As List
	'result.Initialize
	'result.Add(CreateMap("access_token": "a5de6293fe36c1a9de23cb", "user_name": data.Get("username")))
	HRM.ResponseCode = 200
	'HRM.ResponseObject = CreateMap("access_token": "a5de6293fe36c1a9de23cb", "user_name": data.Get("username").As(String).Replace(CRLF, "").Trim)
	HRM.ResponseObject = CreateMap("user_name": data.Get("username").As(String).Replace(CRLF, "").Trim, "access_token": "a5de6293fe36c1a9de23cb")
	'HRM.ResponseData = result
	HRM.ResponseMessage = "Login created successfully"
	ReturnApiResponse
End Sub