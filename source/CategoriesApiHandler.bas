B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Api Handler class
' Version 6.70
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
	If Path = "/api/categories" And Method = "GET" Then
		GetCategories
	Else If Path = "/api/categories" And Method = "POST" Then
		PostCategory
	Else If Path.StartsWith("/api/categories/") And Method = "GET" Then
		GetCategoryById
	Else If Path.StartsWith("/api/categories/") And Method = "PUT" Then
		PutCategoryById
	Else If Path.StartsWith("/api/categories/") And Method = "DELETE" Then
		DeleteCategoryById
	Else
		WebApiUtils.ReturnBadRequest(HRM, Response)
	End If
End Sub

Private Sub GetCategories
	Log($"${Method}: ${Path}"$)
	DB.Open
	DB.Table = "tbl_categories"
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

Private Sub GetCategoryById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/categories/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	DB.Open
	DB.Table = "tbl_categories"
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
			HRM.ResponseError = "Category not found"
		End If
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PostCategory
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
	Dim RequiredKeys As List = Array As String("category_name") 
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	
	' Check conflict category name
	DB.Open
	DB.Table = "tbl_categories"
	DB.Conditions = Array("category_name = ?")
	DB.Parameters = Array(data.Get("category_name"))
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Category already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Insert new row
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("category_name", _
	"created_date")
	DB.Parameters = Array(data.Get("category_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.ReturnRow = True
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Retrieve new row
		HRM.ResponseCode = 201
		HRM.ResponseObject = DB.First
		HRM.ResponseMessage = "Category created successfully"
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PutCategoryById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/categories/".Length)
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
	If data.ContainsKey("category_name") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'category_name' not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Check conflict category name
	DB.Open
	DB.Table = "tbl_categories"
	DB.Conditions = Array("category_name = ?", "id <> ?")
	DB.Parameters = Array(data.Get("category_name"), id)
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Category already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Find row by id
	DB.Open
	DB.Table = "tbl_categories"
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Update row by id
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("category_name", _
	"modified_date")
	DB.Parameters = Array(data.Get("category_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.ReturnRow = True
	DB.Save
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		' Return updated row
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "Category updated successfully"
		HRM.ResponseObject = DB.First
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub DeleteCategoryById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/categories/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	' Find row by id
	DB.Open
	DB.Table = "tbl_categories"
	DB.Find(id)
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Delete row
	DB.Open
	DB.Table = "tbl_categories"
	DB.Id = id
	DB.Delete
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseMessage = "Category deleted successfully"
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub