B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
' ORM module
' Version 6.90
Sub Process_Globals
	Private SQL1 As SQL
	Private ctx As Map
	Private DBType As String
	Private DBDir As String
	Private DBFile As String
	Private DBHost As String
	Private DBPort As String
	Private DBName As String
	Private Driver As String
	Private JdbcUrl As String
	Private User As String
	Private Password As String
	'Private MaxPoolSize As Int
	Private ConnectionPool As ConnectionPool
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
		ctx = File.ReadMap(File.DirApp, $"${dbvar}.ini"$)
		DBType = ctx.GetDefault("DbType", "")
		Select DBType.ToUpperCase
			Case "MARIADB", "MYSQL"
				 DBHost = ctx.GetDefault("DbHost", "")
				 DBPort = ctx.GetDefault("DbPort", "")
				 DBName = ctx.GetDefault("DbName", "")
				 Driver = ctx.GetDefault("DriverClass", "")
				 JdbcUrl = ctx.GetDefault("JdbcUrl", "")
				 User = ctx.GetDefault("User", "")
				 Password = ctx.GetDefault("Password", "")
				 'MaxPoolSize = ctx.GetDefault("MaxPoolSize", 0)
				SQL1.Initialize2(Driver, JdbcUrl, User, Password)
			Case "SQLITE"
				DBDir = ctx.GetDefault("DbDir", File.DirApp)
				If DBDir = "" Then DBDir = File.DirApp
				DBFile = ctx.GetDefault("DbFile", "Pakai.db")
				Main.DB = SQL1
			Case Else
				LogColor($"${DBType} not supported!"$, COLOR_RED)
				Log("Application is terminated.")
				ExitApplication
		End Select
		'CheckDatabase
	Catch
		LogError(LastException.Message)
		LogColor("Error initialize database!", COLOR_RED)
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

Private Sub UsePool (Name As String) As Boolean
	Dim DbArray() As String = Array As String("MARIADB", "MYSQL")
	Return DbArray.As(List).IndexOf(Name.ToUpperCase) > -1
End Sub

Public Sub CheckDatabase
	Try
		LogColor("Checking database...", COLOR_BLUE)
		Select DBType.ToUpperCase
			Case "SQLITE"
				Dim DBExist As Boolean = File.Exists(DBDir, DBFile)
			Case "MARIADB", "MYSQL"
				SQL1.InitializeAsync("SQL1", Driver, JdbcUrl, User, Password)
				Wait For SQL1_Ready (Success As Boolean)
				If Success = False Then
					LogColor("Database initilialization failed!", COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				If NotInitialized(SQL1) Then
					LogColor("Database connection test failed!", COLOR_RED)
					Log("Application is terminated.")
					ExitApplication
				End If
				Dim DBExist As Boolean
				Dim qry As String = "SELECT * FROM SCHEMATA WHERE SCHEMA_NAME = ?"
				Dim RS As ResultSet = SQL1.ExecQuery2(qry, Array As String(DBName))
				Do While RS.NextRow
					DBExist = True
				Loop
				RS.Close
			Case Else
				LogColor("Database type is unknown!", COLOR_RED)
				ExitApplication
		End Select
		If DBExist = False Then
			LogColor($"${DBType} database not existed!"$, COLOR_RED)
			CreateDatabase
			Return
		End If
		LogColor($"${DBType} database existed!"$, COLOR_BLUE)
		If UsePool(DBType) Then
			JdbcUrl = ctx.GetDefault("JdbcUrl", "")
			JdbcUrl = JdbcUrl.Replace("{DbHost}", DBHost)
			JdbcUrl = JdbcUrl.Replace("{DbName}", DBName)
			JdbcUrl = IIf(DBPort.Length = 0, JdbcUrl.Replace(":{DbPort}", ""), JdbcUrl.Replace("{DbPort}", DBPort))
			ConnectionPool.Initialize(Driver, JdbcUrl, User, Password)
			Main.DB = ConnectionPool.GetConnection
		Else
			SQL1.InitializeSQLite(DBDir, DBFile, False)
			Main.DB = SQL1
		End If
		' Create new tables after database has already created
		'Users.CreateUsersTable
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
	If UsePool(DBType) Then
		Wait For (CreateDatabaseAsync) Complete (Success As Boolean)
	Else
		Dim Success As Boolean = CreateSQLite
	End If
	If Not(Success) Then
		LogColor("Database creation failed!", COLOR_RED)
		Return
	End If
	
	LogColor("Creating tables...", COLOR_BLUE)
	If UsePool(DBType) Then
		JdbcUrl = ctx.GetDefault("JdbcUrl", "")
		JdbcUrl = JdbcUrl.Replace("{DbHost}", DBHost)
		JdbcUrl = JdbcUrl.Replace("{DbName}", DBName)
		JdbcUrl = IIf(DBPort.Length = 0, JdbcUrl.Replace(":{DbPort}", ""), JdbcUrl.Replace("{DbPort}", DBPort))
		ConnectionPool.Initialize(Driver, JdbcUrl, User, Password)
		SQL1 = ConnectionPool.GetConnection
		Main.Pool = ConnectionPool
	End If
	
	If UsePool(DBType) Then	
		Dim query As String = "CREATE TABLE tbl_categories (id int NOT NULL AUTO_INCREMENT, category_name varchar(255) NOT NULL, created_date timestamp DEFAULT CURRENT_TIMESTAMP, modified_date datetime ON UPDATE CURRENT_TIMESTAMP, deleted_date datetime)"
	Else
		Dim query As String = "CREATE TABLE tbl_categories (id INTEGER, category_name TEXT NOT NULL, created_date TEXT DEFAULT (datetime('now')), modified_date TEXT, deleted_date TEXT, PRIMARY KEY(id AUTOINCREMENT))"
	End If
	SQL1.AddNonQueryToBatch(query, Null)

	Dim query As String = "INSERT INTO tbl_categories (category_name) VALUES (?)"
	SQL1.AddNonQueryToBatch(query, Array("Hardwares"))
	SQL1.AddNonQueryToBatch(query, Array("Toys"))

	If UsePool(DBType) Then
		Dim query As String = "CREATE TABLE tbl_products (id int NOT NULL AUTO_INCREMENT, category_id int, product_code varchar(12) NOT NULL, product_name varchar(255) NOT NULL, product_price decimal(10,2) NOT NULL DEFAULT (0.00), product_image mediumblob, created_date timestamp DEFAULT CURRENT_TIMESTAMP, modified_date datetime ON UPDATE CURRENT_TIMESTAMP, deleted_date datetime, FOREIGN KEY (category_id) REFERENCES tbl_categories (id))"
	Else
		Dim query As String = "CREATE TABLE tbl_products (id INTEGER, category_id INTEGER, product_code TEXT NOT NULL, product_name TEXT NOT NULL, product_price NUMERIC NOT NULL DEFAULT (0.00), product_image BLOB, created_date TEXT DEFAULT (datetime('now')), modified_date TEXT, deleted_date TEXT, PRIMARY KEY(id AUTOINCREMENT), FOREIGN KEY (category_id) REFERENCES tbl_categories (id))"
	End If
	Log(query)
	SQL1.AddNonQueryToBatch(query, Null)
	
	Dim query As String = "INSERT INTO tbl_products (category_id, product_code, product_name, product_price) VALUES (?, ?, ?, ?)"
	SQL1.AddNonQueryToBatch(query, Array(2, "T001", "Teddy Bear", 99.9))
	SQL1.AddNonQueryToBatch(query, Array(1, "H001", "Hammer", 15.75))
	SQL1.AddNonQueryToBatch(query, Array(2, "T002", "Optimus Prime", 1000))
	
	Dim SenderFilter As Object = SQL1.ExecNonQueryBatch("SQL")
	Wait For (SenderFilter) SQL_NonQueryComplete (Success As Boolean)
	If Success Then
		LogColor("Database is created successfully!", COLOR_BLUE)
	Else
		LogColor("Database creation failed!", COLOR_RED)
	End If
	'SQL1.Close
	Main.DB = SQL1
End Sub

Public Sub CreateSQLite As Boolean
	Try
		If DBDir = "" Then
			DBDir = File.DirApp
		End If
		If DBFile = "" Then
			DBFile = "Pakai.db"
		End If
		SQL1.InitializeSQLite(DBDir, DBFile, True)
		SQL1.ExecQuerySingleResult("PRAGMA journal_mode = wal")
		Return True
	Catch
		LogColor(LastException.Message, COLOR_RED)
		Return False
	End Try
End Sub

Public Sub CreateDatabaseAsync As ResumableSub
	Try
		If SQL1.IsInitialized = False Then
			Dim JdbcUrl As String = ctx.Get("JdbcUrl")
			JdbcUrl = JdbcUrl.Replace("{DbHost}", DBHost)
			JdbcUrl = JdbcUrl.Replace("{DbName}", "information_schema")
			JdbcUrl = IIf(DBPort.Length = 0, JdbcUrl.Replace(":{DbPort}", ""), JdbcUrl.Replace("{DbPort}", DBPort))
			SQL1.InitializeAsync("SQL1", Driver, JdbcUrl, User, Password)
			Wait For SQL1_Ready (Success As Boolean)
			If Success = False Then
				Return False
			End If
		End If
		Dim	CharSet As String = "utf8mb4"
		Dim Collate As String = "utf8mb4_unicode_ci"
		Dim qry As String = $"CREATE DATABASE ${DBName} CHARACTER SET ${CharSet} COLLATE ${Collate}"$
		SQL1.ExecNonQuery(qry)
		Return True
	Catch
		LogColor(LastException.Message, COLOR_RED)
		Return False
	End Try
End Sub