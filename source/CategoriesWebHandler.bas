B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
' Version 6.80
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private FileMap As Map
	Private Model As CategoriesModel
End Sub

Public Sub Initialize
	App = Main.App
	Model.Initialize
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
	Dim Row As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	Dim EditModal As String = LoadFromCache("/hx/categories/edit")
	App.WriteHtml2(Response, EditModal, Row)
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
	
	Dim Row As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	Dim DeleteModal As String = LoadFromCache("/hx/categories/delete")
	App.WriteHtml2(Response, DeleteModal, Row)
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
			Dim Found As Boolean = Model.FindRowByName(name)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			' Insert new row
			Model.Create(name, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "created", "Category created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			Dim Found As Boolean = Model.FindRowByCategoryNameNotEqualId(name, id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			' Update row
			Model.Update(id, name, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "updated", "Category updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindProductByCategoryId(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				Return
			End If
			
			' Delete row
			Model.Delete(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
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
	Dim Rows As List = Model.Read
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return "              <tbody></tbody>"
	End If
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append(CRLF).Append("              <tbody>")
	For Each Row As Map In Rows
		Row.Put("name", Row.Get("category_name"))
		Dim elem_row As String = LoadFromCache("/hx/categories/table/row")
		elem_row = WebApiUtils.ReplaceMap(elem_row, Row)
		SB.Append(CRLF).Append("                " & elem_row)
	Next
	SB.Append(CRLF).Append("              </tbody>")
	Dim elem_table As String = LoadFromCache("/hx/categories/table")
	Return elem_table.Replace("<tbody></tbody>", SB.ToString)
End Sub

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