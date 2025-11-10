B4J=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Database class module
'Version 6.00
Sub Class_Globals
	Private conn As ORMConnector
	Private info As ConnectionInfo
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
	info.Initialize
	info.DBType = ctx.GetDefault("DbType", "")
	Select info.DBType
		Case "SQLite"
			info.DBDir = ctx.GetDefault("DbDir", "")
			info.DBFile = ctx.GetDefault("DbFile", "")
			info.JournalMode = "WAL"
		Case "MariaDB", "MySQL"
			info.DBHost = ctx.GetDefault("DbHost", "")
			info.DBPort = ctx.GetDefault("DbPort", "")
			info.DBName = ctx.GetDefault("DbName", "")
			info.DriverClass = ctx.GetDefault("DriverClass", "")
			info.JdbcUrl = ctx.GetDefault("JdbcUrl", "")
			info.User = ctx.GetDefault("User", "")
			info.Password = ctx.GetDefault("Password", "")
			info.MaxPoolSize = ctx.GetDefault("MaxPoolSize", 0)
		Case Else
			LogColor($"${info.DBType} not supported!"$, Main.COLOR_RED)
			Log("Application is terminated.")
			ExitApplication
	End Select
	conn.Initialize(info)
End Sub

Public Sub Engine As String
	Return conn.DBType
End Sub

Public Sub Open As SQL
	Return conn.DBOpen
End Sub

Public Sub Close
	conn.DBClose
End Sub

' Make Connection to Database
Public Sub ConnectDatabase
	Try
		If conn.IsInitialized = False Then Return
		LogColor("Checking database...", Main.COLOR_BLUE)		
		Select Engine
			Case "SQLite"
				Dim DBFound As Boolean = conn.DBExist			
			Case "MariaDB", "MySQL"
				Wait For (conn.InitSchema) Complete (Success As Boolean)
				If Success = False Then
					LogColor("Database initilialization failed!", Main.COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				If conn.Test = False Then
					LogColor("Database connection failed!", Main.COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				Wait For (conn.DBExist2) Complete (DBFound As Boolean)
			Case Else
				Return
		End Select
		If DBFound Then
			LogColor($"${Engine} database found!"$, Main.COLOR_BLUE)
			'AddUsersTable
			If Engine = "MariaDB" Or Engine = "MySQL" Then
				conn.InitPool
			End If
			Return
		End If
		LogColor($"${Engine} database not found!"$, Main.COLOR_RED)
		CreateDatabase
	Catch
		LogError(LastException.Message)
		LogColor("Error checking database!", Main.COLOR_RED)
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

' Create Database Tables and Populate Data
Private Sub CreateDatabase
	LogColor("Creating database...", Main.COLOR_BLUE)
	Wait For (conn.DBCreate) Complete (Success As Boolean)
	If Not(Success) Then
		LogColor("Database creation failed!", Main.COLOR_RED)
		Return
	End If
	
	LogColor("Creating tables...", Main.COLOR_BLUE)
	If Engine = "MariaDB" Or Engine = "MySQL" Then
		conn.InitPool
	End If
	
	Dim DB As MiniORM
	DB.Initialize(Engine, Open)
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
	
	Wait For (DB.ExecuteBatch) Complete (Success As Boolean)
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
	If Engine = "MariaDB" Or Engine = "MySQL" Then
		conn.InitPool
	End If
	
	Dim DB As MiniORM
	DB.Initialize(Engine, Open)
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
	
	Wait For (DB.ExecuteBatch) Complete (Success As Boolean)
	If Success Then
		LogColor("Table is created successfully!", Main.COLOR_BLUE)
	Else
		LogColor("Table creation failed!", Main.COLOR_RED)
	End If
	DB.Close
End Sub

Public Sub CurrentTimeStamp As String
	Select Engine
		Case "SQLite"
			Return "datetime('Now')"		
		Case "MariaDB", "MySQL"
			Return "NOW()"
		Case Else
			Return ""
	End Select
End Sub

Public Sub CurrentTimeStampAddMinute (Value As Int) As String
	Select Engine
		Case "SQLite"
			Return $"datetime('Now', '+${Value} minute')"$		
		Case "MariaDB", "MySQL"
			Return $"DATE_ADD(NOW(), INTERVAL ${Value} MINUTE)"$
		Case Else
			Return ""
	End Select
End Sub