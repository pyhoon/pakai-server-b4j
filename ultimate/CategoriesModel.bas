B4J=true
Group=Models
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private DB As MiniORM
End Sub

Public Sub Initialize
	DB = Main.DB
End Sub

Public Sub GetRowById (Id As Int) As Map
	DB.Open
	DB.Table = "tbl_categories"
	DB.Condition = "id = ?"
	DB.Parameter = Id
	DB.Query
	If DB.Found Then
		Return DB.First
	End If
	Return CreateMap()
End Sub

Public Sub FindRowById (Id As Int) As Boolean
	DB.Open
	DB.Table = "tbl_categories"
	DB.Find(Id)
	Return DB.Found
End Sub

Public Sub FindRowByName (Name As String) As Boolean
	DB.Open
	DB.Table = "tbl_categories"
	DB.Conditions = Array("category_name = ?")
	DB.Parameters = Array(Name)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindRowByCategoryNameNotEqualId (Name As String, Id As Int) As Boolean
	DB.Open
	DB.Table = "tbl_categories"
	DB.Conditions = Array("category_name = ?", "id <> ?")
	DB.Parameters = Array(Name, Id)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindProductByCategoryId (Id As Int) As Boolean
	DB.Open
	DB.Table = "tbl_products"
	DB.Condition = "category_id = ?"
	DB.Parameter = Id
	DB.Query
	Return DB.Found
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

Public Sub Create (Name As String)
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("category_name")
	DB.Parameters = Array(Name)
	DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Read As List
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name")
	DB.Query
	Return DB.Results
End Sub

Public Sub Update (Id As Int, Name As String)
	DB.Open
	DB.Table = "tbl_categories"
	DB.Columns = Array("category_name")
	DB.Parameters = Array(Name)
	DB.Condition = "id = ?"
	DB.Parameter = Id
	DB.UpdateModifiedDate = True
	DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Delete (Id As Int)
	DB.Open
	DB.Table = "tbl_categories"
	DB.Id = Id
	DB.Delete
End Sub