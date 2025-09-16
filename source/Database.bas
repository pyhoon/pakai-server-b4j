B4J=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Database class module
'Version 5.20
Sub Class_Globals
	Private DB 		As MiniORM
	Private conn 	As ORMConnector
	Private info 	As ConnectionInfo
End Sub

Public Sub Initialize
	ConnectDatabase
End Sub

Public Sub Open As SQL
	Return conn.DBOpen
End Sub

Public Sub Close
	conn.DBClose
End Sub

Public Sub Engine As String
	Return conn.DBType
End Sub

' Make Connection to Database
Public Sub ConnectDatabase
	Try
		LogColor("Checking database...", Main.COLOR_BLUE)
		#If SQLite
		If File.Exists(File.DirApp, "sqlite.ini") = False Then
			File.Copy(File.DirAssets, "sqlite.example", File.DirApp, "sqlite.ini")
		End If
		Dim ctx As Map = File.ReadMap(File.DirApp, "sqlite.ini")
		#Else If MySQL
		If File.Exists(File.DirApp, "mysql.ini") = False Then
			File.Copy(File.DirAssets, "mysql.example", File.DirApp, "mysql.ini")
		End If
		Dim ctx As Map = File.ReadMap(File.DirApp, "mysql.ini")
		#Else If MariaDB
		If File.Exists(File.DirApp, "mariadb.ini") = False Then
			File.Copy(File.DirAssets, "mariadb.example", File.DirApp, "mariadb.ini")
		End If	
		Dim ctx As Map = File.ReadMap(File.DirApp, "mariadb.ini")
		#End If
		info.Initialize
		info.DBType = ctx.GetDefault("DbType", "")
		Select info.DBType
			Case "MySQL", "MariaDB"
				info.DBHost = ctx.GetDefault("DbHost", "")
				info.DBPort = ctx.GetDefault("DbPort", "")
				info.DBName = ctx.GetDefault("DbName", "")
				info.DriverClass = ctx.GetDefault("DriverClass", "")
				info.JdbcUrl = ctx.GetDefault("JdbcUrl", "")
				info.User = ctx.GetDefault("User", "")
				info.Password = ctx.GetDefault("Password", "")
				info.MaxPoolSize = ctx.GetDefault("MaxPoolSize", 0)
				conn.Initialize(info)
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
			Case "SQLite"
				info.DBDir = ctx.GetDefault("DbDir", "")
				info.DBFile = ctx.GetDefault("DbFile", "")
				info.JournalMode = "WAL"
				conn.Initialize(info)
				Dim DBFound As Boolean = conn.DBExist
			Case Else
				LogColor($"DBType '${info.DBType}' not supported!"$, Main.COLOR_RED)
				Log("Application is terminated.")
				ExitApplication
		End Select
		If DBFound Then
			LogColor($"${info.DBType} database found!"$, Main.COLOR_BLUE)
			#If MySQL Or MariaDB
			conn.InitPool
			#End If
			DB.Initialize(conn.DBType, conn.DBOpen)
			Return
		End If
		LogColor($"${info.DBType} database not found!"$, Main.COLOR_RED)
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
	#If MySQL Or MariaDB
	conn.InitPool
	#End If
	DB.Initialize(conn.DBType, conn.DBOpen)
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryAddToBatch = True
	
	DB.Table = "tbl_categories"
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "category_name")))
	DB.Create

	DB.Columns = Array("category_name")
	DB.Insert2(Array("Hardwares"))
	DB.Insert2(Array("Toys"))

	DB.Table = "tbl_products"
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "category_id", "Type": DB.INTEGER)))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_code", "Length": "12")))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_name")))
	DB.Columns.Add(DB.CreateColumn2(CreateMap("Name": "product_price", "Type": DB.DECIMAL, "Length": "10,2", "Default": "0.00")))
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
	
	'' Adding an image to blob field
	'Dim b() As Byte = File.ReadBytes(File.DirAssets, "icon.png")
	'DB.Table = "tbl_products"
	'DB.Columns = Array("product_image")
	'DB.Parameters = Array(b)
	'DB.Id = 3 ' after setting Columns and Parameters
	'DB.Save
	
	DB.Close
End Sub

Public Sub CurrentTimeStamp As String
	Select DB.DBType.ToUpperCase
		Case "MYSQL"
			Return "NOW()"
		Case "SQLITE"
			Return "datetime('Now')"
		Case Else
			Return ""
	End Select
End Sub

Public Sub CurrentTimeStampAddMinute (Value As Int) As String
	Select DB.DBType.ToUpperCase
		Case "MYSQL"
			Return $"DATE_ADD(NOW(), INTERVAL ${Value} MINUTE)"$
		Case "SQLITE"
			Return $"datetime('Now', '+${Value} minute')"$
		Case Else
			Return ""
	End Select
End Sub