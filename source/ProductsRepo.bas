B4J=true
Group=Repositories
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Products Repo
' Version 6.90
Sub Class_Globals
	Private SQL1 As SQL
End Sub

Public Sub Initialize
	#If MARIADB Or MYSQL
	SQL1 = Main.Pool.GetConnection
	#Else
	SQL1 = Main.DB
	#End If	
End Sub

Public Sub GetRowById (Id As Int) As Map
	Dim row As Map
	Dim query As String = "SELECT id, category_id, product_code, product_name, product_price FROM tbl_products WHERE id = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Id))
	Do While rs.NextRow
		row.Initialize
		row.Put("id", rs.GetInt("id"))
		row.Put("category_id", rs.GetString("category_id"))
		row.Put("product_code", rs.GetString("product_code"))
		row.Put("product_name", rs.GetString("product_name"))
		row.Put("product_price", rs.GetString("product_price"))
	Loop
	rs.Close
	Return row
End Sub

Public Sub GetRowsByCategoryId (Category_Id As Int) As List
	Dim rows As List
	rows.Initialize
	Dim query As String = "SELECT p.id, p.category_id, c.category_name, p.product_code, p.product_name, p.product_price FROM tbl_products p JOIN tbl_categories c ON p.category_id = c.id WHERE p.category_id = ? ORDER BY p.id DESC"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Category_Id))
	Do While rs.NextRow
		Dim row As Map
		row.Initialize
		row.Put("id", rs.GetInt("id"))
		row.Put("category_id", rs.GetString("category_id"))
		row.Put("category_name", rs.GetString("category_name"))
		row.Put("product_code", rs.GetString("product_code"))
		row.Put("product_name", rs.GetString("product_name"))
		row.Put("product_price", rs.GetString("product_price"))
		rows.Add(row)
	Loop
	rs.Close
	Return rows
End Sub

Public Sub FindRowById (Id As Int) As Boolean
	Dim Found As Boolean
	Dim query As String = "SELECT * FROM tbl_products WHERE id = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Id))
	Do While rs.NextRow
		Found = True
	Loop
	rs.Close
	Return Found
End Sub

Public Sub FindRowByProductCode (Code As String) As Boolean
	Dim found As Boolean
	Dim query As String = "SELECT * FROM tbl_products WHERE product_code = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Code))
	Do While rs.NextRow
		found = True
	Loop
	rs.Close
	Return found
End Sub

Public Sub FindRowByProductCodeNotEqualId (Code As String, Id As Int) As Boolean
	Dim found As Boolean
	Dim query As String = "SELECT * FROM tbl_products WHERE product_code = ? AND id <> ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Code, Id))
	Do While rs.NextRow
		found = True
	Loop
	rs.Close
	Return found
End Sub

Public Sub Search (keyword As String) As List
	Dim rows As List
	rows.Initialize
	Dim query As String = "SELECT p.id, p.category_id, c.category_name, p.product_code, p.product_name, p.product_price FROM tbl_products p JOIN tbl_categories c ON p.category_id = c.id"
	If keyword <> "" Then
		query = query & " WHERE UPPER(p.product_code) LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?"
	End If
	query = query & " ORDER BY p.id DESC"
	If keyword <> "" Then
		Dim rs As ResultSet = SQL1.ExecQuery2(query, Array("%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%"))
	Else
		Dim rs As ResultSet = SQL1.ExecQuery(query)
	End If
	Do While rs.NextRow
		Dim row As Map
		row.Initialize
		row.Put("id", rs.GetInt("id"))
		row.Put("category_id", rs.GetString("category_id"))
		row.Put("category_name", rs.GetString("category_name"))
		row.Put("product_code", rs.GetString("product_code"))
		row.Put("product_name", rs.GetString("product_name"))
		row.Put("product_price", rs.GetString("product_price"))
		rows.Add(row)
	Loop
	rs.Close
	Return rows
End Sub

Public Sub Error As Exception
	Return LastException
End Sub

Public Sub Create (Category As Int, Code As String, Name As String, Price As Double, Created_Date As String)
	Dim query As String = "INSERT INTO tbl_products (category_id, product_code, product_name, product_price) VALUES (?, ?, ?, ?)"
	SQL1.ExecNonQuery2(query, Array(Category, Code, Name, Price))
End Sub

Public Sub Read As List
	Dim rows As List
	rows.Initialize
	Dim query As String = "SELECT p.id, p.category_id, c.category_name, p.product_code, p.product_name, p.product_price FROM tbl_products p JOIN tbl_categories c ON p.category_id = c.id ORDER BY p.id DESC"
	Dim rs As ResultSet = SQL1.ExecQuery(query)
	Do While rs.NextRow
		Dim row As Map
		row.Initialize
		row.Put("id", rs.GetInt("id"))
		row.Put("category_id", rs.GetString("category_id"))
		row.Put("category_name", rs.GetString("category_name"))
		row.Put("product_code", rs.GetString("product_code"))
		row.Put("product_name", rs.GetString("product_name"))
		row.Put("product_price", rs.GetString("product_price"))
		rows.Add(row)
	Loop
	rs.Close
	Return rows
End Sub

Public Sub Update (Id As Int, Category As Int, Code As String, Name As String, Price As Double, Modified_Date As String)
	Dim query As String = "UPDATE tbl_products SET category_id = ?, product_code = ?, product_name = ?, product_price = ? WHERE id = ?"
	SQL1.ExecNonQuery2(query, Array(Category, Code, Name, Price, Id))
End Sub

Public Sub Delete (Id As Int)
	Dim query As String = "DELETE FROM tbl_products WHERE id = ?"
	SQL1.ExecNonQuery2(query, Array(Id))
End Sub