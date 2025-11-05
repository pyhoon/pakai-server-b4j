# Pakai Server - Web Application framework

Version: 6.00beta

Create Web Application using B4J project template

### Preview
![Index](../main/pakai-index.png)
![Edit](../main/pakai-form-validation.png)
![Documentation](../main/pakai.png)
---

## Template:
- Pakai Server (6.00beta).b4xtemplate

## Depends on:
- [EndsMeet.b4xlib](https://github.com/pyhoon/EndsMeet)
- [MiniJs.b4xlib](https://github.com/pyhoon/MiniJs-B4X)
- [MiniHtml.b4xlib](https://github.com/pyhoon/MiniHtml-B4X)
- [MiniORMUtils.b4xlib](https://github.com/pyhoon/MiniORMUtils-B4X)
- sqlite-jdbc-3.7.2.jar (SQLite)
- mysql-connector-j-9.3.0.jar (MySQL)
- mariadb-java-client-3.5.6.jar (MariaDB)

## Features:
- Use Server Handlers
- Use HTMX v2.0 and Bootstrap v5.3
- Built-in CRUD examples


## What's New
- More cleaner code in Main module
- More control to allowed http methods
- Build-in CORS
- Optional config file

### Code Example
```b4x
Sub AppStart (Args() As String)
	App.Initialize
	App.LoadConfig
	
	' *** Web handlers ***
	App.Get("", "ProductsHandler")
	App.Get("/categories", "CategoriesHandler")
	
	' *** Api handlers ***
	App.Rest("/api/products/*", "ProductsHandler")
	App.Rest("/api/categories/*", "CategoriesHandler")
	
	App.Start

	DB.Initialize
	DB.ConnectDatabase
	StartMessageLoop
End Sub
```

**Support this project**

<a href="https://paypal.me/aeric80/"><img src="https://github.com/pyhoon/pakai-server-b4j/blob/main/source/Objects/www/assets/img/sponsor.png" width="174" title="Buy me a coffee" /></a>
