# Pakai - Web API Server framework

Version: 5.00beta1

Create REST API Backend using B4J project template

### Preview
![Pakai](../main/pakai.png)

---

## Template:
- Pakai Server (5.00beta1).b4xtemplate

## Depends on:
- [WebApiUtils.b4xlib](https://github.com/pyhoon/WebApiUtils-B4J)
- [MiniORMUtils.b4xlib](https://github.com/pyhoon/MiniORMUtils-B4X)
- sqlite-jdbc-3.7.2.jar (or your preferred version)
- mysql-connector-java-8.0.30.jar (or your preferred version)

## Features:
- Use Server Handlers
- Improved API documentation
- Built-in web front-end with CRUD examples
- Supports JSON and XML formats payload and response

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

<a href="https://paypal.me/aeric80/"><img src="https://github.com/pyhoon/pakai-server-b4j/blob/main/source/Objects/www/assets/img/sponsor.png" width="174" title="Buy me a coffee" /></a>
