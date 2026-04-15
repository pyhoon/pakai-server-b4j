B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Users Api Handler class
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
	If Path = "/api/users" And Method = "GET" Then
		GetUsers
	Else If Path = "/api/users" And Method = "POST" Then
		PostUser
	Else If Path.StartsWith("/api/users/") And Method = "GET" Then
		GetUserById
	Else If Path.StartsWith("/api/users/") And Method = "PUT" Then
		PutUserById
	Else If Path.StartsWith("/api/users/") And Method = "DELETE" Then
		DeleteUserById	
	Else
		WebApiUtils.ReturnBadRequest(HRM, Response)
	End If
End Sub

Private Sub GetUsers
	Log($"${Method}: ${Path}"$)
	DB.Open
	DB.Table = "tbl_users"
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = DB.Results
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
	DB.Close
End Sub

Private Sub GetUserById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/users/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	DB.Open
	DB.Table = "tbl_users"
	DB.Find(Id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		If DB.Found Then
			HRM.ResponseCode = 200
			HRM.ResponseObject = DB.First
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "User not found"
		End If
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
	DB.Close
End Sub

Private Sub PostUser
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
	Dim RequiredKeys As List = Array As String("user_name", "key2", "key3")
	For Each RequiredKey As String In RequiredKeys
		If data.ContainsKey(RequiredKey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${RequiredKey}' not found"$
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	' Check conflict unique key
	Dim user_name As String = data.Get("user_name")
	Dim key2 As String = data.Get("key2")
	Dim key3 As String = data.Get("key3")
	Dim created_date As String = data.GetDefault("created_date", WebApiUtils.CurrentDateTime)
	
	DB.Open
	DB.Table = "tbl_users"
	DB.Conditions = Array("user_name = ?") ' user_name is unique
	DB.Parameters = Array(user_name)
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "user_name already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If
	
	' Insert new row
	DB.Table = "tbl_users"
	DB.Columns = Array("user_name", "key2", "key3", "created_date")
	DB.Parameters = Array(user_name, key2, key3, created_date)
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Retrieve new row
		HRM.ResponseCode = 201
		HRM.ResponseObject = DB.First
		HRM.ResponseMessage = "User (user_name) created successfully"
	End If	
	WebApiUtils.ReturnHttpResponse(HRM, Response)
	DB.Close
End Sub

Private Sub PutUserById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/users/".Length)
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
	Dim RequiredKeys As List = Array As String("user_name", "key2", "key3")
	For Each RequiredKey As String In RequiredKeys
		If data.ContainsKey(RequiredKey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${RequiredKey}' not found"$
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	
	' Check conflict unique key
	Dim user_name As String = data.Get("user_name")
	Dim key2 As String = data.Get("key2")
	Dim key3 As String = data.Get("key3")
	Dim modified_date As String = data.GetDefault("modified_date", WebApiUtils.CurrentDateTime)

	DB.Open
	DB.Table = "tbl_users"
	DB.Conditions = Array("user_name = ?", "id <> ?") ' duplicate keys not alowed
	DB.Parameters = Array(user_name, Id)
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "user_name already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If

	' Find row by id
	DB.Table = "tbl_users"
	DB.Find(Id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Id not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If

	' Update row by id
	DB.Table = "tbl_users"
	DB.Columns = Array("user_name", "key2", "key3", "modified_date")
	DB.Parameters = Array(user_name, key2, key3, modified_date)
	DB.Id = Id
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Return updated row
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "User updated successfully"
		HRM.ResponseObject = DB.First
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
	DB.Close
End Sub

Private Sub DeleteUserById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/users/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try	
	' Find row by id
	DB.Open
	DB.Table = "tbl_users"
	DB.Find(Id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "User not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		DB.Close
		Return
	End If

	' Delete row
	DB.Table = "tbl_users"
	DB.Id = Id
	DB.Delete
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "User deleted successfully"
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
	DB.Close
End Sub