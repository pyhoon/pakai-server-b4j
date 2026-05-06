B4J=true
Group=Repositories
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Categories Repo
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
	Dim query As String = "SELECT * FROM tbl_categories WHERE id = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Id))
	Do While rs.NextRow
		row.Initialize
		row.Put("id", rs.GetInt("id"))
		row.Put("category_name", rs.GetString("category_name"))
	Loop
	rs.Close
	Return row
End Sub

Public Sub FindRowById (Id As Int) As Boolean
	Dim found As Boolean
	Dim query As String = "SELECT * FROM tbl_categories WHERE id = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Id))
	Do While rs.NextRow
		found = True
	Loop
	rs.Close
	Return found
End Sub

Public Sub FindRowByName (Name As String) As Boolean
	Dim found As Boolean
	Dim query As String = "SELECT * FROM tbl_categories WHERE category_name = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Name))
	Do While rs.NextRow
		found = True
	Loop
	rs.Close
	Return found
End Sub

Public Sub FindRowByCategoryNameNotEqualId (Name As String, Id As Int) As Boolean
	Dim found As Boolean
	Dim query As String = "SELECT * FROM tbl_categories WHERE category_name = ? AND id <> ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Name, Id))
	Do While rs.NextRow
		found = True
	Loop
	rs.Close
	Return found	
End Sub

Public Sub FindProductByCategoryId (Id As Int) As Boolean
	Dim found As Boolean
	Dim query As String = "SELECT * FROM tbl_products WHERE category_id = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(query, Array(Id))
	Do While rs.NextRow
		found = True
	Loop
	rs.Close
	Return found
End Sub

Public Sub Error As Exception
	Return LastException
End Sub

Public Sub Create (Name As String, Created_Date As String)
	Try
		Dim query As String = "INSERT INTO tbl_categories (category_name, created_date) VALUES (?, ?)"
		SQL1.ExecNonQuery2(query, Array(Name, Created_Date))
	Catch
		Log(LastException)
	End Try
End Sub

Public Sub Read As List
	Dim rows As List
	rows.Initialize
	Dim query As String = "SELECT id, category_name FROM tbl_categories ORDER BY id"
	Dim rs As ResultSet = SQL1.ExecQuery(query)
	Do While rs.NextRow
		Dim row As Map
		row.Initialize
		row.Put("id", rs.GetInt("id"))
		row.Put("category_name", rs.GetString("category_name"))
		rows.Add(row)
	Loop
	rs.Close
	Return rows
End Sub

Public Sub Update (Id As Int, Name As String, Modified_Date As String)
	Dim query As String = "UPDATE tbl_categories SET category_name = ? WHERE id = ?"
	SQL1.ExecNonQuery2(query, Array(Name, Id))
End Sub

Public Sub Delete (Id As Int)
	Dim query As String = "DELETE FROM tbl_categories WHERE id = ?"
	SQL1.ExecNonQuery2(query, Array(Id))
End Sub