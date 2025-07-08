# Pakai - Web API Server framework

Version: 5.00 beta5

Create REST API Backend using B4J project template

### Preview
![Pakai](../main/pakai.png)

---

## Template:
- Pakai.Server.5.00beta5.b4xtemplate

## Depends on:
- [EndsMeet.1.00.b4xlib](https://github.com/pyhoon/EndsMeet)
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
Private Sub GetCategories
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_categories"
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results
	ReturnApiResponse
	DB.Close
End Sub
```

**Support this project**

<a href="https://paypal.me/aeric80/"><img src="https://github.com/pyhoon/pakai-server-b4j/blob/main/source/Objects/www/assets/img/sponsor.png" width="174" title="Buy me a coffee" /></a>
