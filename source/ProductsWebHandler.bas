B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Products Handler class
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
	FileMap.Put("/products", "products.html")
	FileMap.Put("/hx/products/table", "products-table.html")
	FileMap.Put("/hx/products/table/row", "products-table-row.html")
	FileMap.Put("/hx/products/add", "products-add.html")
	FileMap.Put("/hx/products/edit", "products-edit.html")
	FileMap.Put("/hx/products/delete", "products-delete.html")
	
	Log($"${Method}: ${Path}"$)
	If Path = "/" Then
		RenderPage
	Else If Path = "/hx/products/table" Then
		HandleTable
	Else If Path = "/hx/products/add" Then
		HandleAddModal
	Else If Path.StartsWith("/hx/products/edit/") Then
		HandleEditModal
	Else If Path.StartsWith("/hx/products/delete/") Then
		HandleDeleteModal
	Else
		HandleProducts
	End If
End Sub

Private Sub RenderPage
	Dim page As String = LoadFromCache("/products")
	App.WriteHtml2(Response, page, App.ctx)
End Sub

' Return default or search results table
Private Sub HandleTable
	App.WriteHtml(Response, ProductsTable)
End Sub

' Add modal
Private Sub HandleAddModal
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name name")
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
	End If
	Dim select1 As StringBuilder
	select1.Initialize
	select1.Append(CRLF).Append($"      <select class="form-select" id="category2" name="category" required>"$)
	select1.Append(CRLF).Append($"        <option value="" disabled>Select Category</option>"$)
	For Each row As Map In DB.Results
		Dim cat_id As Int = row.Get("id")
		Dim cat_name As String = row.Get("name")
		select1.Append(CRLF).Append($"        <option value="${cat_id}""$)
		select1.Append(">")
		select1.Append(cat_name)
		select1.Append("        </option>")
	Next
	select1.Append("      </select>")
	
	Dim AddModal As String = LoadFromCache("/hx/products/add")
	AddModal = AddModal.Replace($"<select class="form-select" id="category1" name="category" required></select>"$, select1.ToString)
	App.WriteHtml(Response, AddModal)
End Sub

' Edit modal
Private Sub HandleEditModal
	Try
		Dim id As Int = Path.SubString("/hx/products/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try

	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("id", "category_id category", "product_code code", "product_name name", "product_price price")
	DB.Condition = "id = ?"
	DB.Parameter = id
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		Return
	End If
	If DB.Found Then
		Dim row1 As Map = DB.First
		Dim category_id As Int = row1.Get("category")
		'row1.Put("id", id)
		row1.Put("price", NumberFormat2(row1.Get("price"), 1, 2, 2, False))
		
		DB.Open
		DB.Table = "tbl_categories"
		DB.Columns = Array("id", "category_name name")
		DB.Query
		If DB.Error.IsInitialized Then
			ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		End If
		Dim select1 As StringBuilder
		select1.Initialize
		select1.Append(CRLF).Append($"      <select class="form-select" id="category2" name="category" required>"$)
		select1.Append(CRLF).Append($"        <option value="" disabled>Select Category</option>"$)
		For Each row2 As Map In DB.Results
			Dim cat_id As Int = row2.Get("id")
			Dim cat_name As String = row2.Get("name")
			select1.Append(CRLF).Append($"        <option value="${cat_id}""$)
			If cat_id = category_id Then select1.Append(" selected")
			select1.Append(">")
			select1.Append(cat_name)
			select1.Append("        </option>")
		Next
		select1.Append("      </select>")
	End If
	Dim EditModal As String = LoadFromCache("/hx/products/edit")
	EditModal = WebApiUtils.ReplaceMap(EditModal, row1)
	EditModal = EditModal.Replace($"<select class="form-select" id="category2" name="category" required></select>"$, select1.ToString)
	App.WriteHtml(Response, EditModal)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Try
		Dim id As Int = Path.SubString("/hx/products/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("id", "product_code code", "product_name name")
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
		'row.Put("id", id)
	End If
	Dim DeleteModal As String = LoadFromCache("/hx/products/delete")
	'DeleteModal = DeleteModal.Replace($"<select class="form-select" id="category2" name="category" required></select>"$, select1.ToString)
	App.WriteHtml2(Response, DeleteModal, row)
End Sub

' Handle CRUD operations
Private Sub HandleProducts
	Select Method
		Case "POST"
			' Create
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim tempprice As String = Request.GetParameter("price")
			Dim price As Double = IIf(tempprice.Trim = "", 0, tempprice)
			Dim category As Int = Request.GetParameter("category")

			If code = "" Or code.Trim.Length < 2 Then
				ShowAlert("Product Code must be at least 2 characters long.", "warning")
				Return
			End If
			
			' Check conflict
			DB.Open
			DB.Table = "tbl_products"
			DB.Conditions = Array("product_code = ?")
			DB.Parameters = Array(code)
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found Then
				ShowAlert("Product Code already exists!", "warning")
				Return
			End If

			' Insert new row
			DB.Open
			DB.Table = "tbl_products"
			DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "created_date")
			DB.Parameters = Array(category, code, name, price, Main.CurrentDateTime)
			DB.Save
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Product", "created", "Product created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim code As String = Request.GetParameter("code")
			Dim name As String = Request.GetParameter("name")
			Dim price As Double = Request.GetParameter("price")
			Dim category As Int = Request.GetParameter("category")
			
			If code = "" Or code.Trim.Length < 2 Then
				ShowAlert("Product Code must be at least 2 characters long.", "warning")
				Return
			End If
			If name = "" Or name.Trim.Length < 2 Then
				ShowAlert("Product Name must be at least 2 characters long.", "warning")
				Return
			End If
			
			DB.Open
			DB.Table = "tbl_products"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Product not found!", "warning")
				Return
			End If
			
			DB.Open
			DB.Table = "tbl_products"
			DB.Conditions = Array("product_code = ?", "id <> ?")
			DB.Parameters = Array(code, id)
			DB.Query
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			If DB.Found Then
				ShowAlert("Product Code already exists!", "warning")
				Return
			End If
			
			' Update row
			DB.Open
			DB.Table = "tbl_products"
			DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "modified_date")
			DB.Parameters = Array(category, code, name, price, Main.CurrentDateTime)
			DB.Id = id
			DB.Save
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Product", "updated", "Product updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.Open
			DB.Table = "tbl_products"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Product not found!", "warning")
				Return
			End If

			' Delete row
			DB.Open
			DB.Table = "tbl_products"
			DB.Id = id
			DB.Delete
			If DB.Error.IsInitialized Then
				ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Product", "deleted", "Product deleted successfully!", "danger")
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

Private Sub ProductsTable As String
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id id", "p.category_id catid", "c.category_name category", "p.product_code code", "p.product_name AS name", "p.product_price price")
	DB.Join("JOIN", "tbl_categories c", Array("p.category_id = c.id"))
	Dim keyword As String = Request.GetParameter("keyword")
	If keyword <> "" Then
		DB.Conditions = Array("p.product_code LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?")
		DB.Parameters = Array("%" & keyword & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "DESC")
	DB.Query
	If DB.Error.IsInitialized Then
		ShowAlert($"Database error: ${DB.Error.Message}"$, "danger")
		Return "              <tbody></tbody>"
	End If
		
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append(CRLF).Append("              <tbody>")
	For Each row As Map In DB.Results
		row.Put("price", NumberFormat2(row.Get("price"), 1, 2, 2, False))
		Dim elem_row As String = LoadFromCache("/hx/products/table/row")
		elem_row = WebApiUtils.ReplaceMap(elem_row, row)
		SB.Append(CRLF).Append("                " & elem_row)
	Next
	SB.Append(CRLF).Append("              </tbody>")
	Dim elem_table As String = LoadFromCache("/hx/products/table")
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
	div1.Append($"<div id="products-container" hx-swap-oob="true">"$)
	div1.Append(CRLF).Append(ProductsTable)
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