# Pakai Server - Web Application framework

Version: 6.00

Create Web Application using B4J project template

### Preview
![Index](../v6.00/pakai-index.png)

---

## Templates
- Pakai Server (6.00) starter.b4xtemplate **recommended**
- Pakai Server (6.00) bundle.b4xtemplate (local css/js)
- Pakai Server (6.00) min.b4xtemplate (assets excluded)

## Depends on
- [EndsMeet.b4xlib](https://github.com/pyhoon/EndsMeet)
- [MiniJs.b4xlib](https://github.com/pyhoon/MiniJs-B4X)
- [MiniHtml.b4xlib](https://github.com/pyhoon/MiniHtml-B4X)
- [MiniORMUtils.b4xlib](https://github.com/pyhoon/MiniORMUtils-B4X)
- sqlite-jdbc-3.7.2.jar (SQLite)
- mysql-connector-j-9.3.0.jar (MySQL)
- mariadb-java-client-3.5.6.jar (MariaDB)

## Features
- Frontend using HTMX v2.0.8, Bootstrap v5.3.8, Bootstrap Icons v1.13.1
- Responsive design with modal dialog and toast
- SQLite and MySQL/MariaDB backend
- Built-in CRUD/REST examples

## Improvement
- Better UI/UX/DX compared to version 5.x
- More flexible to generate new models
- HTML generated using B4X
- No JavaScript module
- No jQuery AJAX parsing
- JSON/XML API is optional
- WebApiUtils is optional

### Code Example
```b4x
Sub AppStart (Args() As String)
	App.Initialize
	App.LoadConfig
	App.Get("", "ProductsHandler")
	App.Get("/categories", "CategoriesHandler")
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
