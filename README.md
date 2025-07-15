# Pakai - Web API Server framework

Version: 5.00

Create REST API Backend using B4J project template

### Preview
![Index](../main/pakai-index.png)
![Edit](../main/pakai-form-validation.png)
![Documentation](../main/pakai.png)
---

## Template:
- Pakai Server (5.00).b4xtemplate

## Depends on:
- [EndsMeet.b4xlib](https://github.com/pyhoon/EndsMeet)
- [WebApiUtils.b4xlib](https://github.com/pyhoon/WebApiUtils-B4J)
- [MiniORMUtils.b4xlib](https://github.com/pyhoon/MiniORMUtils-B4X)
- sqlite-jdbc-3.7.2.jar (SQLite)
- mysql-connector-java-8.0.30.jar (MySQL)

## Features:
- Use Server Handlers
- Improved API documentation
- Built-in web front-end with CRUD examples
- Supports JSON and XML formats payload and response

## What's New
- More cleaner code in Main module
- More control to allowed http methods
- Build-in CORS
- Optional config file

### Code Example
```b4x
Sub AppStart (Args() As String)
	app.Initialize
	app.api.VerboseMode = True
	app.api.OrderedKeys = True
	app.Get("", "IndexWebHandler")
	app.Get("/api/products", "ProductsApiHandler")
	app.Get("/api/products/*", "ProductsApiHandler")
	app.Post("/api/products", "ProductsApiHandler")
	app.Put("/api/products/*", "ProductsApiHandler")
	app.Delete("/api/products/*", "ProductsApiHandler")
	app.UseConfigFile = True
	app.Start
	StartMessageLoop
End Sub
```

**Support this project**

<a href="https://paypal.me/aeric80/"><img src="https://github.com/pyhoon/pakai-server-b4j/blob/main/source/Objects/www/assets/img/sponsor.png" width="174" title="Buy me a coffee" /></a>
