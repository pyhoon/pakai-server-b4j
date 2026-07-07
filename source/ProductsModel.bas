B4J=true
Group=Models
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Products Model
' Version 6.99
Sub Class_Globals
	Private DB As MiniORM
End Sub

Public Sub Initialize
	DB = Main.DB
End Sub

Public Sub GetRowById (Id As Int) As Map
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("id", "category_id", "product_code", "product_name", "product_price")
	DB.Condition = "id = ?"
	DB.Parameter = Id
	DB.Query
	If DB.Found Then
		Return DB.First
	End If
	Return CreateMap()
End Sub

Public Sub GetRowsByCategoryId (Category_Id As Int) As List	
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id", "p.category_id", "c.category_name", "p.product_code", "p.product_name", "p.product_price")
	DB.Join("", "tbl_categories c", Array("p.category_id = c.id"))
	DB.Condition = "c.id = ?"
	DB.Parameter = Category_Id
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	Return DB.Results
End Sub

Public Sub FindRowById (Id As Int) As Boolean
	DB.Open
	DB.Table = "tbl_products"
	DB.Find(Id)
	Return DB.Found
End Sub

Public Sub FindRowByProductCode (Code As String) As Boolean
	DB.Open
	DB.Table = "tbl_products"
	DB.Conditions = Array("product_code = ?")
	DB.Parameters = Array(Code)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindRowByProductCodeNotEqualId (Code As String, Id As Int) As Boolean
	DB.Open
	DB.Table = "tbl_products"
	DB.Conditions = Array("product_code = ?", "id <> ?")
	DB.Parameters = Array(Code, Id)
	DB.Query
	Return DB.Found
End Sub

Public Sub Search (keyword As String) As List
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id", "p.category_id", "c.category_name", "p.product_code", "p.product_name", "p.product_price")
	DB.Join("", "tbl_categories c", Array("p.category_id = c.id"))
	If keyword <> "" Then
		DB.Conditions = Array("UPPER(p.product_code) LIKE ? Or UPPER(p.product_name) LIKE ? Or UPPER(c.category_name) LIKE ?")
		DB.Parameters = Array("%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%")
	End If
	DB.Query
	Return DB.Results
End Sub

Public Sub Found As Boolean
	Return DB.Found
End Sub

Public Sub First As Map
	Return DB.First
End Sub

Public Sub Error As Exception
	Return DB.Error
End Sub

Public Sub Create (Category As Int, Code As String, Name As String, Price As Double, Created_Date As String)
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "created_date")
	DB.Parameters = Array(Category, Code, Name, Price, Created_Date)
	DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Read As List
	DB.Open
	DB.Table = "tbl_products p"
	DB.Columns = Array("p.id", "p.category_id", "c.category_name", "p.product_code", "p.product_name", "p.product_price")
	DB.Join("", "tbl_categories c", Array("p.category_id = c.id"))
	DB.Query
	Return DB.Results
End Sub

Public Sub Update (Id As Int, Category As Int, Code As String, Name As String, Price As Double, Modified_Date As String)
	DB.Open
	DB.Table = "tbl_products"
	DB.Columns = Array("category_id", "product_code", "product_name", "product_price", "modified_date")
	DB.Parameters = Array(Category, Code, Name, Price, Modified_Date)
	DB.Condition = "id = ?"
	DB.Parameter = Id
	DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Delete (Id As Int)
	DB.Open
	DB.Table = "tbl_products"
	DB.Id = Id
	DB.Delete
End Sub