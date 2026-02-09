B4J=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Database class module
' Version 6.30
Sub Class_Globals
' Private conn As ORMConnector
' Private info As ConnectionInfo
	Private DB As MiniORM
	Private MS As ORMSettings
End Sub

Public Sub Initialize
	#If MariaDB
	Dim dbvar As String = "mariadb"
	#Else If MySQL
	Dim dbvar As String = "mysql"
	#Else
	Dim dbvar As String = "sqlite"
	#End If
	If File.Exists(File.DirApp, $"${dbvar}.ini"$) = False Then
		File.Copy(File.DirAssets, $"${dbvar}.example"$, File.DirApp, $"${dbvar}.ini"$)
	End If
	Dim ctx As Map = File.ReadMap(File.DirApp, $"${dbvar}.ini"$)
	DB.Initialize
	MS.Initialize
	MS.DBType = ctx.GetDefault("DbType", "")
	Select MS.DBType
		Case DB.MARIADB, DB.MYSQL
			MS.DBHost = ctx.GetDefault("DbHost", "")
			MS.DBPort = ctx.GetDefault("DbPort", "")
			MS.DBName = ctx.GetDefault("DbName", "")
			MS.DriverClass = ctx.GetDefault("DriverClass", "")
			MS.JdbcUrl = ctx.GetDefault("JdbcUrl", "")
			MS.User = ctx.GetDefault("User", "")
			MS.Password = ctx.GetDefault("Password", "")
			MS.MaxPoolSize = ctx.GetDefault("MaxPoolSize", 0)
		Case DB.SQLITE
			MS.DBDir = ctx.GetDefault("DbDir", "")
			MS.DBFile = ctx.GetDefault("DbFile", "")
			MS.JournalMode = "WAL"			
		Case Else
			LogColor($"${MS.DBType} not supported!"$, Main.COLOR_RED)
			Log("Application is terminated.")
			ExitApplication
	End Select
	DB.Settings = MS
End Sub

'Public Sub Engine As String
'	Return conn.DBType
'End Sub
'
'Public Sub Open As SQL
'	Return conn.DBOpen
'End Sub
'
'Public Sub Close
'	conn.DBClose
'End Sub

' Make Connection to Database
Public Sub ConnectDatabase
	Try
		If DB.Opened Then Return
		LogColor("Checking database...", Main.COLOR_BLUE)		
		Select DB.DbType
			Case DB.SQLITE
				Dim DBFound As Boolean = DB.Exist
			Case DB.MARIADB, DB.MYSQL
				Wait For (DB.InitSchema) Complete (Success As Boolean)
				If Success = False Then
					LogColor("Database initilialization failed!", Main.COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				If DB.Test = False Then
					LogColor("Database connection failed!", Main.COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				Wait For (DB.ExistAsync) Complete (DBFound As Boolean)
			Case Else
				Return
		End Select
		If DB.Found Then
			LogColor($"${DB.DbType} database found!"$, Main.COLOR_BLUE)
			'AddUsersTable
			If UsePool(DB.DbType) Then
				DB.InitPool
			End If
			Return
		End If
		LogColor($"${DB.DbType} database not found!"$, Main.COLOR_RED)
		CreateDatabase
	Catch
		LogError(LastException.Message)
		LogColor("Error checking database!", Main.COLOR_RED)
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

Private Sub UsePool (Name As String) As Boolean
	Dim DbArray() As String = Array As String(DB.MARIADB, DB.MYSQL)
	Return DbArray.As(List).IndexOf(Name) > -1
End Sub

' Create Database Tables and Populate Data
Private Sub CreateDatabase
	LogColor("Creating database...", Main.COLOR_BLUE)
	Wait For (DB.Create) Complete (Success As Boolean)
	If Not(Success) Then
		LogColor("Database creation failed!", Main.COLOR_RED)
		Return
	End If
	
	LogColor("Creating tables...", Main.COLOR_BLUE)
	If UsePool(DB.DbType) Then
		DB.InitPool
	End If
	
	'Dim DB As MiniORM
	'DB.Initialize'(Engine, Open)
	'DB.Settings = MS
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryAddToBatch = True
	
	DB.Table = "tbl_categories"
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "category_name", "Null": False)))
	DB.Create

	DB.Columns = Array("category_name")
	DB.Insert2(Array("Hardwares"))
	DB.Insert2(Array("Toys"))

	DB.Table = "tbl_products"
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "category_id", "Type": DB.INTEGER, "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_code", "Length": "12", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_name", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_price", "Type": DB.DECIMAL, "Length": "10,2", "Null": False, "Default": "0.00")))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_image", "Type": DB.BLOB)))
	DB.Foreign("category_id", "id", "tbl_categories", "", "")
	DB.Create
	
	DB.Columns = Array("category_id", "product_code", "product_name", "product_price")
	DB.Insert2(Array(2, "T001", "Teddy Bear", 99.9))
	DB.Insert2(Array(1, "H001", "Hammer", 15.75))
	DB.Insert2(Array(2, "T002", "Optimus Prime", 1000))
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		LogColor("Database is created successfully!", Main.COLOR_BLUE)
	Else
		LogColor("Database creation failed!", Main.COLOR_RED)
	End If
	DB.Close
End Sub

' Add sample code for creating new table
Public Sub AddUsersTable
	LogColor("Creating users table...", Main.COLOR_BLUE)
	If UsePool(DB.DbType) Then
		DB.InitPool
	End If
	
	'Dim DB As MiniORM
	'DB.Initialize'(Engine, Open)
	'DB.Settings = MS
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryAddToBatch = True

	DB.Table = "tbl_users"
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "first_name", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "last_name", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "email", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "hash", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "salt", "Null": False)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "admin", "Null": False, "Type": DB.INTEGER, "Default": "0")))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "active", "Null": False, "Type": DB.INTEGER, "Default": "0")))
	DB.Create
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		LogColor("Table is created successfully!", Main.COLOR_BLUE)
	Else
		LogColor("Table creation failed!", Main.COLOR_RED)
	End If
	DB.Close
End Sub

Public Sub CurrentTimeStamp As String
	Select DB.DbType
		Case DB.SQLITE
			Return "datetime('Now')"		
		Case DB.MARIADB, DB.MYSQL
			Return "NOW()"
		Case Else
			Return ""
	End Select
End Sub

Public Sub CurrentTimeStampAddMinute (Value As Int) As String
	Select DB.DbType
		Case DB.SQLITE
			Return $"datetime('Now', '+${Value} minute')"$		
		Case DB.MARIADB, DB.MYSQL
			Return $"DATE_ADD(NOW(), INTERVAL ${Value} MINUTE)"$
		Case Else
			Return ""
	End Select
End Sub