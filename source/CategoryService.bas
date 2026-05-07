B4J=true
Group=BLL
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Categories Handler class
' Version 6.90
Sub Class_Globals
	Private App      As EndsMeet
	Private Path     As String
	Private Method   As String
	Private FileMap  As Map
	Private Request  As ServletRequest
	Private Response As ServletResponse
	Private CR    	 As CategoryRepository
End Sub

Public Sub Initialize
	App = Main.App
	FileMap.Initialize
	FileMap.Put("/categories", "categories.html")
	FileMap.Put("/hx/categories/table", "categories-table.html")
	FileMap.Put("/hx/categories/table/row", "categories-table-row.html")
	FileMap.Put("/hx/categories/add", "categories-add.html")
	FileMap.Put("/hx/categories/edit", "categories-edit.html")
	FileMap.Put("/hx/categories/delete", "categories-delete.html")
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase	
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
	CR.Initialize
	Dim Row As Map = CR.GetRowById(id)
	If CR.Error.IsInitialized Then
		ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
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
	
	CR.Initialize
	Dim Row As Map = CR.GetRowById(id)
	If CR.Error.IsInitialized Then
		ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
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
			CR.Initialize
			Dim Found As Boolean = CR.FindRowByName(name)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			' Insert new row
			CR.Initialize
			CR.Create(name, Main.CurrentDateTime)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "created", "Category created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			CR.Initialize
			Dim Found As Boolean = CR.FindRowById(id)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			CR.Initialize
			Dim Found As Boolean = CR.FindRowByCategoryNameNotEqualId(name, id)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			' Update row
			CR.Initialize
			CR.Update(id, name, Main.CurrentDateTime)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "updated", "Category updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			CR.Initialize
			Dim Found As Boolean = CR.FindRowById(id)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			
			CR.Initialize
			Dim Found As Boolean = CR.FindProductByCategoryId(id)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				Return
			End If
			
			' Delete row
			CR.Initialize
			CR.Delete(id)
			If CR.Error.IsInitialized Then
				ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
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
	CR.Initialize
	Dim Rows As List = CR.Read
	If CR.Error.IsInitialized Then
		ShowAlert($"Database error: ${CR.Error.Message}"$, "danger")
		Return "              <tbody></tbody>"
	End If
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append(CRLF).Append("              <tbody>")
	For Each Row As Map In Rows
		Row.Put("name", Row.Get("category_name"))
		Dim elem_row As String = LoadFromCache("/hx/categories/table/row")
		elem_row = WebUtils.ReplaceMap(elem_row, Row)
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