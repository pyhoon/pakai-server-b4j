B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
' ORM Module
' Version 6.99
Sub Process_Globals
	Private DB As MiniORM
	Private DBS As MiniORMSettings
	Private Const COLOR_RED  As Int = 0xFFFF0000
	Private Const COLOR_BLUE As Int = 0xFF0000FF
End Sub

Public Sub InitDatabase
	Try
		LogColor("Configuring database...", COLOR_BLUE)
		If File.Exists(File.DirApp, "sqlite.ini") = False Then
			File.Copy(File.DirAssets, "sqlite.example", File.DirApp, "sqlite.ini")
		End If
		Dim ctx As Map = File.ReadMap(File.DirApp, "sqlite.ini")
		DB.Initialize
		DBS.Initialize
		DBS.DBType = ctx.GetDefault("DbType", "")
		Select DBS.DBType
			Case DB.SQLITE
				DBS.DBDir = ctx.GetDefault("DbDir", File.DirApp)
				DBS.DBFile = ctx.GetDefault("DbFile", "data.db")
				DBS.JournalMode = "WAL"
			Case Else
				LogColor($"${DBS.DBType} not supported!"$, COLOR_RED)
				Log("Application is terminated.")
				ExitApplication
		End Select
		DB.Settings = DBS
		CheckDatabase
	Catch
		LogError(LastException.Message)
		LogColor("Error initialize database!", COLOR_RED)
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

Private Sub CheckDatabase
	Try
		LogColor("Checking database...", COLOR_BLUE)
		Select DB.DbType
			Case DB.SQLITE
				Dim DBExist As Boolean = DB.Exist
			Case Else
				LogColor("Database type is unknown!", COLOR_RED)
				ExitApplication
		End Select
		If DBExist = False Then
			LogColor($"${DB.DbType} database not existed!"$, COLOR_RED)
			CreateDatabase
			Return
		End If
		LogColor($"${DB.DbType} database existed!"$, COLOR_BLUE)
		Main.DB = DB
		' Create new tables after database has already created
	Catch
		LogError(LastException.Message)
		LogColor("Error checking database!", COLOR_RED)
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

' Create Database Tables and Populate Data
Private Sub CreateDatabase
	LogColor("Creating database...", COLOR_BLUE)
	Dim Success As Boolean = DB.CreateSQLite
	If Not(Success) Then
		LogColor("Database creation failed!", COLOR_RED)
		Return
	End If
	
	LogColor("Creating tables...", COLOR_BLUE)
	DB.UseTimestamps = True
	DB.QueryExecute = False
	DB.QueryAddToBatch = True
	
	DB.Table = "tbl_categories"
	DB.Columns.Add(CreateMap("N": "category_name", "AN": False))
	DB.Create

	DB.Columns = Array("category_name")
	DB.InsertWithParams = Array("Hardwares")
	DB.InsertWithParams = Array("Toys")

	DB.Table = "tbl_products"
	DB.Columns.Add(CreateMap("N": "category_id", "T": DB.INTEGER, "AN": False))
	DB.Columns.Add(CreateMap("N": "product_code", "L": "12", "AN": False))
	DB.Columns.Add(CreateMap("N": "product_name", "AN": False))
	DB.Columns.Add(CreateMap("N": "product_price", "T": DB.DECIMAL, "L": "10,2", "AN": False, "D": "0.00"))
	DB.Columns.Add(CreateMap("N": "product_image", "T": DB.BLOB))
	DB.Foreign = "category_id"
	DB.References("tbl_categories", "id")
	DB.Create
	
	DB.Columns = Array("category_id", "product_code", "product_name", "product_price")
	DB.InsertWithParams = Array(2, "T001", "Teddy Bear", 99.9)
	DB.InsertWithParams = Array(1, "H001", "Hammer", 15.75)
	DB.InsertWithParams = Array(2, "T002", "Optimus Prime", 1000)
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		LogColor("Database is created successfully!", COLOR_BLUE)
	Else
		LogColor("Database creation failed!", COLOR_RED)
	End If
	DB.Close
	DB.QueryExecute = True
	Main.DB = DB
End Sub