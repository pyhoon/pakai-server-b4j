B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
' ORM Module
' Version 6.99
Sub Process_Globals
	Private MDB As MiniORM
	Private DBS As MiniORMSettings
	Private Const COLOR_RED  As Int = 0xFFFF0000
	Private Const COLOR_BLUE As Int = 0xFF0000FF
End Sub

Public Sub InitDatabase
	Try
		LogColor("Configuring database...", COLOR_BLUE)
		Dim dbvar As String = "sqlite"
		#If MariaDB
		Dim dbvar As String = "mariadb"
		#End If
		#If MySQL
		Dim dbvar As String = "mysql"
		#End If
		If File.Exists(File.DirApp, $"${dbvar}.ini"$) = False Then
			File.Copy(File.DirAssets, $"${dbvar}.example"$, File.DirApp, $"${dbvar}.ini"$)
		End If
		Dim ctx As Map = File.ReadMap(File.DirApp, $"${dbvar}.ini"$)
		MDB.Initialize
		'MDB.ShowExtraLogs = True
		DBS.Initialize
		DBS.DBType = ctx.GetDefault("DbType", "")
		Select DBS.DBType
			Case MDB.MARIADB, MDB.MYSQL
				DBS.DBHost = ctx.GetDefault("DbHost", "")
				DBS.DBPort = ctx.GetDefault("DbPort", "")
				DBS.DBName = ctx.GetDefault("DbName", "")
				DBS.Driver = ctx.GetDefault("DriverClass", "")
				DBS.JdbcUrl = ctx.GetDefault("JdbcUrl", "")
				DBS.User = ctx.GetDefault("User", "")
				DBS.Password = ctx.GetDefault("Password", "")
				DBS.MaxPoolSize = ctx.GetDefault("MaxPoolSize", 0)
			Case MDB.SQLITE
				DBS.DBDir = ctx.GetDefault("DbDir", File.DirApp)
				DBS.DBFile = ctx.GetDefault("DbFile", "Pakai.db")
				DBS.JournalMode = "WAL"
			Case Else
				LogColor($"${DBS.DBType} not supported!"$, COLOR_RED)
				Log("Application is terminated.")
				ExitApplication
		End Select
		MDB.Settings = DBS
		CheckDatabase
	Catch
		LogError(LastException.Message)
		LogColor("Error initialize database!", COLOR_RED)
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

Private Sub UsePool (Name As String) As Boolean
	Dim DbArray() As String = Array As String(MDB.MARIADB, MDB.MYSQL)
	Return DbArray.As(List).IndexOf(Name) > -1
End Sub

Private Sub CheckDatabase
	Try
		LogColor("Checking database...", COLOR_BLUE)
		Select MDB.DbType
			Case MDB.SQLITE
				Dim DBExist As Boolean = MDB.Exist
			Case MDB.MARIADB, MDB.MYSQL
				Wait For (MDB.InitSchemaAsync) Complete (Success As Boolean)
				If Success = False Then
					LogColor("Database initilialization failed!", COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				If MDB.Test = False Then
					LogColor("Database connection test failed!", COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				Wait For (MDB.ExistAsync) Complete (DBExist As Boolean)
			Case Else
				LogColor("Database type is unknown!", COLOR_RED)
				ExitApplication
		End Select
		If DBExist = False Then
			LogColor($"${MDB.DbType} database not existed!"$, COLOR_RED)
			CreateDatabase
			Return
		End If
		LogColor($"${MDB.DbType} database existed!"$, COLOR_BLUE)
		If UsePool(MDB.DbType) Then
			MDB.InitPool
		End If
		Main.DB = MDB
		' Create new tables after database has already created
		'MDB.Open
		'If MDB.TableExists("tbl_users") = False Then
		'	Dim Model As UsersModel
		'	Model.Initialize
		'	Model.CreateUsersTable
		'Else
		'	Log("Existed")
		'End If
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
	If UsePool(MDB.DbType) Then
		Wait For (MDB.CreateDatabaseAsync) Complete (Success As Boolean)
	Else
		Dim Success As Boolean = MDB.CreateSQLite
	End If
	If Not(Success) Then
		LogColor("Database creation failed!", COLOR_RED)
		Return
	End If
	
	LogColor("Creating tables...", COLOR_BLUE)
	If UsePool(MDB.DbType) Then
		MDB.InitPool
	End If
	
	MDB.UseTimestamps = True
	MDB.QueryExecute = False
	MDB.QueryAddToBatch = True
	
	MDB.Table = "tbl_categories"
	MDB.Columns.Add(CreateMap("Name": "category_name", "Null": False))
	MDB.Create

	MDB.Columns = Array("category_name")
	MDB.InsertWithParams = Array("Hardwares")
	MDB.InsertWithParams = Array("Toys")

	MDB.Table = "tbl_products"
	MDB.Columns.Add(CreateMap("Name": "category_id", "Type": MDB.INTEGER, "Null": False))
	MDB.Columns.Add(CreateMap("Name": "product_code", "Length": "12", "Null": False))
	MDB.Columns.Add(CreateMap("Name": "product_name", "Null": False))
	MDB.Columns.Add(CreateMap("Name": "product_price", "Type": MDB.DECIMAL, "Length": "10,2", "Null": False, "Default": "0.00"))
	MDB.Columns.Add(CreateMap("Name": "product_image", "Type": MDB.BLOB))
	MDB.Foreign = "category_id"
	MDB.References("tbl_categories", "id")
	MDB.Create
	
	MDB.Columns = Array("category_id", "product_code", "product_name", "product_price")
	MDB.InsertWithParams = Array(2, "T001", "Teddy Bear", 99.9)
	MDB.InsertWithParams = Array(1, "H001", "Hammer", 15.75)
	MDB.InsertWithParams = Array(2, "T002", "Optimus Prime", 1000)
	
	Wait For (MDB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		LogColor("Database is created successfully!", COLOR_BLUE)
	Else
		LogColor("Database creation failed!", COLOR_RED)
	End If
	MDB.Close
	MDB.QueryExecute = True
	Main.DB = MDB
End Sub