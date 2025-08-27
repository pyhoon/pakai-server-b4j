# Web API Server

Version: 3.51

Create Web API Server using B4X project template

### Preview
![Web API Server](../v3.51/web-api-server-b4j.png)

*For version 2.08, please check https://github.com/pyhoon/web-api-server-b4j/tree/v2.08*

*If you don't want to connect to any SQL database, see [MinimaList API Server](https://github.com/pyhoon/minimalist-api-b4j)*

---

## Template:
- Web API Server (3.51).b4xtemplate

## Depends on:
- [WebApiUtils (3.05).b4xlib](https://github.com/pyhoon/WebApiUtils-B4J/blob/v3.05/WebApiUtils%20(3.05).b4xlib)
- [MiniORMUtils (2.60).b4xlib](https://github.com/pyhoon/MiniORMUtils-B4X/blob/v2.60/MiniORMUtils%20(2.60).b4xlib)
- sqlite-jdbc-3.7.2.jar (or your preferred version)
- mysql-connector-java-8.0.30.jar (or your preferred version)

## Features:
- Code simplified
- Back to basics - use multiple Server Handlers
- Improved API documentation
- Built-in web front-end (bootstrap 4)

### Code Example
```basic
Private Sub GetCategoryById (id As Int)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_categories"
	DB.Find(id)
	If DB.Found Then
		HRM.ResponseCode = 200
		HRM.ResponseObject = DB.First
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
	End If
	ReturnApiResponse
	DB.Close
End Sub
```

**Support this project**

<a href="https://paypal.me/aeric80/"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="174" title="Buy me a coffee" /></a>
