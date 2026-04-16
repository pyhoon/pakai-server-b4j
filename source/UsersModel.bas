B4J=true
Group=Models
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
Sub Process_Globals
	Type Users ( _
	user_name As String, _
	user_email As String, _
	user_mobile As String, _
	password_hash As String, _
	password_salt As String, _
	user_image() As Byte, _
	admin As Int, _
	active As Int)
End Sub

Public Sub CreateUsersTable
	Dim DB As MiniORM
	DB = Main.DB
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryAddToBatch = True
	DB.IfNotExist = True
	
	Log("Creating Users table...")
	DB.Open
	DB.Table = "tbl_users"
	DB.Columns.Add(CreateMap("Name": "user_name", "Null": False))
	DB.Columns.Add(CreateMap("Name": "user_email", "Null": False))
	DB.Columns.Add(CreateMap("Name": "user_mobile", "Null": False))
	DB.Columns.Add(CreateMap("Name": "password_hash", "Null": False))
	DB.Columns.Add(CreateMap("Name": "password_salt", "Null": False))
	DB.Columns.Add(CreateMap("Name": "user_image", "Type": DB.BLOB))
	DB.Columns.Add(CreateMap("Name": "admin", "Type": DB.INTEGER, "Default": "0"))
	DB.Columns.Add(CreateMap("Name": "active", "Type": DB.INTEGER, "Default": "0"))
	DB.Create
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		Log("Table Users created successfully!")
	Else
		Log("Table Users creation failed!")
	End If
	DB.Close
End Sub