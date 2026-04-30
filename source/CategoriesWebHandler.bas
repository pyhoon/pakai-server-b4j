B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
' Version 6.70
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private FileMap As Map
End Sub

Public Sub Initialize
	DB = Main.DB
	App = Main.App
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	
	FileMap.Initialize
	FileMap.Put("/categories", "categories.html")
	FileMap.Put("/hx/categories/table", "categories-table.html")
	FileMap.Put("/hx/categories/table/row", "categories-table-row.html")
	FileMap.Put("/hx/categories/add", "categories-add.html")
	FileMap.Put("/hx/categories/edit", "categories-edit.html")
	FileMap.Put("/hx/categories/delete", "categories-delete.html")
	
	Log($"${Method}: ${Path}"$)
	If Path = "/categories" Then
		RenderPage
	Else If Path = "/hx/categories/table" Then
		HandleTable
	Else If Path = "/hx/categories/add" Then
		HandleAddModal
	Else If Path.StartsWith("/hx/categories/edit/") Then
		HandleEditModal
	Else If Path.StartsWith("/hx/categories/delete/") Then
		HandleDeleteModal
	Else
		HandleCategories
	End If
End Sub

Private Sub RenderPage
	Dim page As String = LoadFromCache("/categories")
	'Dim help As String
	'If App.api.EnableHelp Then
	'	help = HelpLink
	'End If
	'App.ctx.Put("help", help)
	App.WriteHtml2(Response, page, App.ctx)
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CategoriesTable)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim AddModal As String = LoadFromCache("/hx/categories/add")
	App.WriteHtml(Response, AddModal)
End Sub

' Edit modal
Private Sub HandleEditModal
	Try
		Dim id As Int = Path.SubString("/hx/categories/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try

	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		Return
	End If
	Dim row As Map
	If DB.Found Then
		row = DB.First
	End If
	
	Dim EditModal As String = LoadFromCache("/hx/categories/edit")
	App.WriteHtml2(Response, EditModal, row)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Try
		Dim id As Int = Path.SubString("/hx/categories/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		Return
	End If
	Dim row As Map
	If DB.Found Then
		row = DB.First
	End If
	
	Dim DeleteModal As String = LoadFromCache("/hx/categories/delete")
	App.WriteHtml2(Response, DeleteModal, row)
End Sub

' Handle CRUD operations
Private Sub HandleCategories
	Select Method
		Case "POST"
			' Create
			Dim name As String = Request.GetParameter("name")
			If name = "" Or name.Trim.Length < 2 Then
				ShowAlert("Category name must be at least 2 characters long.", "warning")
				Return
			End If
			DB.Open
			DB.Table = "tbl_categories"
			DB.Conditions = Array("category_name = ?")
			DB.Parameters = Array(name)
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			' Insert new row
			DB.Open
			DB.Table = "tbl_categories"
			DB.Columns = Array("category_name", "created_date")
			DB.Parameters = Array(name, Main.CurrentDateTime)
			DB.Save
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "created", "Category created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			DB.Open
			DB.Table = "tbl_categories"
			DB.Find(id)
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found = False Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			DB.Open
			DB.Table = "tbl_categories"
			DB.Conditions = Array("category_name = ?", "id <> ?")
			DB.Parameters = Array(name, id)
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			' Update row
			DB.Open
			DB.Table = "tbl_categories"
			DB.Columns = Array("category_name", "modified_date")
			DB.Parameters = Array(name, Main.CurrentDateTime)
			DB.Id = id
			DB.Save
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "updated", "Category updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.Open
			DB.Table = "tbl_categories"
			DB.Find(id)
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found = False Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			DB.Open
			DB.Table = "tbl_products"
			DB.Condition = "category_id = ?"
			DB.Parameter = id
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				Return
			End If
			' Delete row
			DB.Open
			DB.Table = "tbl_categories"
			DB.Id = id
			DB.Delete
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "deleted", "Category deleted successfully!", "danger")
	End Select
End Sub

Private Sub LoadFromCache (Key As String) As String
	If App.ctx.ContainsKey(Key) Then
		Return App.ctx.Get(Key)
	End If
	
	Dim FileName As String = FileMap.Get(Key)
	If File.Exists(File.DirApp, FileName) Then
		Dim element As String = File.ReadString(File.DirApp, FileName)
	End If
	App.ctx.Put(Key, element)
	Return element
End Sub

Private Sub CategoriesTable As String
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.OrderBy = CreateMap("id": "DESC")
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		Return "              <tbody></tbody>"
	End If
	
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append(CRLF).Append("              <tbody>")
	For Each row As Map In DB.Results
		Dim elem_row As String = LoadFromCache("/hx/categories/table/row")
		elem_row = WebApiUtils.ReplaceMap(elem_row, row)
		SB.Append(CRLF).Append("                " & elem_row)
	Next
	SB.Append(CRLF).Append("              </tbody>")
	Dim elem_table As String = LoadFromCache("/hx/categories/table")
	Return elem_table.Replace("<tbody></tbody>", SB.ToString)
End Sub

'Private Sub HelpLink As String
'	Return $"
'<li class="nav-item d-block d-lg-block">
'  <a href="/help" class="nav-link float-end">
'    API 
'	<i class="bi bi-gear me-2" title="API"></i>
'  </a>
'</li>"$
'End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As StringBuilder
	div1.Initialize
	div1.Append($"<div class="alert alert-${status}">"$)
	div1.Append(CRLF).Append($"  ${message}"$)
	div1.Append(CRLF).Append("</div>")
	App.WriteHtml(Response, div1.ToString)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As StringBuilder
	div1.Initialize
	div1.Append($"<div id="categories-container" hx-swap-oob="true">"$)
	div1.Append(CRLF).Append(CategoriesTable)
	div1.Append(CRLF).Append("</div>")
	
	Dim script1 As StringBuilder
	script1.Initialize
	script1.Append("<script>")
	script1.Append(CRLF).Append($"document.dispatchEvent(new CustomEvent('entity:changed', {"$)
	script1.Append(CRLF).Append("  detail: {")
	script1.Append(CRLF).Append($"    "entity": "${entity}","$)
	script1.Append(CRLF).Append($"    "action": "${action}","$)
	script1.Append(CRLF).Append($"    "message": "${message}","$)
	script1.Append(CRLF).Append($"    "status": "${status}""$)
	script1.Append(CRLF).Append("  }")
	script1.Append(CRLF).Append("}));")
	script1.Append("</script>")
	App.WriteHtml(Response, div1.ToString & CRLF & script1.ToString)
End Sub