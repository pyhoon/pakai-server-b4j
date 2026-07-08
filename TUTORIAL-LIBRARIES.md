# Pakai Framework — Dependency Libraries Guide

This guide covers each library that Pakai Framework depends on, explaining what it does, how to use it, and how the framework leverages it.

---

## Library Overview

| Library | Type | Version | Role in Pakai |
|---------|------|---------|---------------|
| EndsMeet | B4J | 2.20 | Web server, routing, sessions, SSL |
| MiniHtml | B4X | 3.00 | Server-side HTML generation (DSL) |
| MiniORMUtils | B4X | 6.00 | Database ORM & connection management |
| WebApiUtils | B4J | 6.99 | REST API response formatting |
| MiniCSS | B4X | 0.30 | CSS generation from B4X code |
| MiniJS | B4X | 0.60 | JavaScript generation from B4X code |
| MC + MH | B4J | 3.00 | Caching & HTML helpers (bundled with Pakai) |

---

## 1. EndsMeet — Web Server & Routing

**GitHub:** https://github.com/pyhoon/EndsMeet  
**Version in Pakai:** 2.20

### What It Does

EndsMeet is a lightweight B4J web server framework that handles:
- HTTP request routing (GET, POST, PUT, DELETE)
- Servlet request/response handling
- Session management
- SSL/HTTPS configuration
- CORS support
- Email (SMTP)
- Static file serving
- Logging

### Core API

```b4x
' Initialize
Dim App As EndsMeet
App.Initialize

' Load config from config.ini
App.LoadConfig

' --- Routes ---
' Match exact path
App.Get("/products", "ProductsHandler")       ' GET only
App.Post("/products", "ProductsHandler")      ' POST only
App.Put("/products", "ProductsHandler")       ' PUT only
App.Delete("/products", "ProductsHandler")    ' DELETE only

' Match path with wildcard - all 4 methods
App.Rest("/api/products/*", "ProductsApiHandler")

' Custom method list
App.Route("/api/search", "SearchHandler", Array("get", "post"))

' --- Start Server ---
App.Start

' --- Write Response ---
App.WriteHtml(Response, htmlString)           ' Write HTML
App.WriteHtml2(Response, htmlString, ctx)     ' Write HTML with variable substitution
```

### Handler Structure

Every handler must implement a `Handle` sub:

```b4x
Sub Handle (req As ServletRequest, resp As ServletResponse)
    ' req.Secure        ' Is this HTTPS?
    ' req.Method         ' GET, POST, PUT, DELETE
    ' req.RequestURI     ' Full path
    ' req.GetParameter("key")  ' Query/form parameter
    ' req.GetInputStream  ' Request body
    
    ' resp.ContentType = "text/html"
    ' resp.Write(responseText)
End Sub
```

### Configuration (config.ini)

| Key | Description |
|-----|-------------|
| `PORT` | HTTP port |
| `ROOT_URL` | Public server URL |
| `ROOT_PATH` | URL sub-path |
| `REDIRECT_TO_HTTPS` | Auto-redirect to SSL |
| `SSL_ENABLED` | Enable HTTPS |
| `SSL_PORT` | HTTPS port |
| `SSL_KEYSTORE_FILE` | Keystore filename |
| `SSL_KEYSTORE_PASSWORD` | Keystore password |

### Programmatic API

```b4x
' Access via App object
App.api.ContentType = "application/json"
App.api.VerboseMode = True
App.ssl.Enabled = True
App.ssl.Port = 8888
App.cors.Enabled = True
App.staticfiles.Folder = "/www"
```

**Key Properties:**
- `App.api` → ApiSettings (Name, Versioning, PayloadType, ContentType, EnableHelp, VerboseMode, OrderedKeys)
- `App.ssl` → SslSettings (Enabled, Port, KeystoreDir, KeystoreFile, KeystorePassword)
- `App.cors` → CorsSettings (Enabled, Path, Settings)
- `App.email` → EmailSettings (SmtpUserName, SmtpPassword, SmtpServer, SmtpPort, SmtpUseSsl)
- `App.staticfiles` → StaticFilesSettings (Folder, Browsable)
- `App.ctx` → Map for template variables (used in HTML substitution)

---

## 2. MiniHtml — HTML Generation

**GitHub:** https://github.com/pyhoon/MiniHtml2-B4X  
**Version in Pakai:** 3.00

### What It Does

MiniHtml is a B4X library that generates HTML using a **DSL builder pattern** — pure B4X code that constructs HTML elements programmatically with methods chaining.

### Core Concepts

Every HTML element is a `MiniHtml` object. You build a tree by creating elements and attaching them to parents using `.up(parent)`.

```b4x
' Create a div
Dim div1 As MiniHtml = MH.Div
div1.cls("container")              ' Set CSS class
div1.text("Hello World")           ' Set inner text
div1.attr("id", "main")            ' Set attribute
div1.sty("color: red")             ' Set inline style

' Parent-child relationship
Dim parent As MiniHtml = MH.Div
Dim child As MiniHtml = MH.Span.up(parent)  ' child is attached to parent
child.text("Click here")
```

### Available Element Creators

| Function | HTML Tag |
|----------|----------|
| `MH.Html` | `<html>` |
| `MH.Head` | `<head>` |
| `MH.Body` | `<body>` |
| `MH.Div` | `<div>` |
| `MH.Span` | `<span>` |
| `MH.P` | `<p>` |
| `MH.H1` to `MH.H6` | `<h1>` to `<h6>` |
| `MH.A` / `MH.Anchor` | `<a>` |
| `MH.Img` | `<img>` |
| `MH.Table` | `<table>` |
| `MH.Thead` | `<thead>` |
| `MH.Tbody` | `<tbody>` |
| `MH.Tr` | `<tr>` |
| `MH.Th` | `<th>` |
| `MH.Td` | `<td>` |
| `MH.Form` | `<form>` |
| `MH.Input` | `<input>` |
| `MH.Select` / `MH.Option` | `<select>` / `<option>` |
| `MH.Button` | `<button>` |
| `MH.Nav` | `<nav>` |
| `MH.Ul` / `MH.Li` | `<ul>` / `<li>` |
| `MH.Footer` | `<footer>` |
| `MH.Meta` | `<meta>` |
| `MH.Link` | `<link>` |
| `MH.Title` | `<title>` |
| `MH.Icon` | `<i>` (for Bootstrap icons) |
| `MH.Br` | `<br>` |
| `MH.Caption` | `<caption>` |

### Chaining Methods

Each method returns the element itself (fluent API):

```b4x
MH.Div.cls("row").attr("id", "mydiv").sty("margin: 10px")
```

### CDN Support

```b4x
' Stylesheet CDN
head1.cdn("style", "https://cdn.example.com/style.css")

' With integrity hash
head1.cdn2("style", "https://cdn.example.com/style.css", "sha384-...", "anonymous")

' Script CDN
body1.cdn("script", "https://cdn.example.com/script.js")
body1.cdn2("script", "https://cdn.example.com/script.js", "sha384-...", "anonymous")
```

### Variable Substitution

Use `$VARIABLE$` syntax in text — variables are replaced from the context map:

```b4x
' In View code:
title1.text("$APP_TITLE$")

' When rendering:
' Variables come from App.ctx map, set in config.ini or code
' App.ctx.Put("APP_TITLE", "My App")
```

Cached HTML still uses variables — they're substituted at render time via `App.WriteHtml2`.

### Pakai-Specific Helpers (MH.bas)

See the separate **MH.bas Helper Library** section below.

---

## 3. MiniORMUtils — Database ORM

**GitHub:** https://github.com/pyhoon/MiniORMUtils-B4X  
**Version in Pakai:** 6.00

### What It Does

MiniORMUtils is a lightweight ORM (Object-Relational Mapper) for B4X that simplifies SQL database operations. It supports SQLite, MySQL, and MariaDB.

### Supported Databases

| Database | DbType | Connection |
|----------|--------|------------|
| SQLite | `MDB.SQLITE` | File-based |
| MySQL | `MDB.MYSQL` | JDBC with connection pooling |
| MariaDB | `MDB.MARIADB` | JDBC with connection pooling |

### Setup

```b4x
Dim MDB As MiniORM
Dim DBS As MiniORMSettings

MDB.Initialize
DBS.Initialize

' SQLite
DBS.DBType = "SQLite"
DBS.DBDir = File.DirApp
DBS.DBFile = "mydb.db"

' MySQL/MariaDB
DBS.DBType = "MariaDB"  ' or "MySQL"
DBS.DBHost = "localhost"
DBS.DBPort = "3306"
DBS.DBName = "mydb"
DBS.User = "root"
DBS.Password = "password"
DBS.Driver = "org.mariadb.jdbc.Driver"
DBS.JdbcUrl = "jdbc:mariadb://{DbHost}:{DbPort}/{DbName}?useSSL=false"
DBS.MaxPoolSize = 10

MDB.Settings = DBS
```

### CRUD Operations

**Create Table:**
```b4x
MDB.Table = "tbl_products"
MDB.Columns.Add(CreateMap("Name": "product_name", "Null": False))
MDB.Columns.Add(CreateMap("Name": "price", "Type": MDB.DECIMAL, "Length": "10,2"))
MDB.Create
' Timestamps (created_date, modified_date) are auto-added when:
MDB.UseTimestamps = True
```

**Insert:**
```b4x
MDB.Table = "tbl_products"
MDB.Columns = Array("product_name", "price")
MDB.Parameters = Array("Widget", 9.99)
MDB.ReturnRow = True  ' Return inserted row
MDB.Save
```

**Select All:**
```b4x
MDB.Table = "tbl_products"
MDB.Query
Dim AllRows As List = MDB.Results
```

**Select with Condition:**
```b4x
MDB.Condition = "id = ?"
MDB.Parameter = 1
MDB.Query
If MDB.Found Then
    Dim Row As Map = MDB.First
End If

' Multiple conditions
MDB.Conditions = Array("name = ?", "price > ?")
MDB.Parameters = Array("Widget", 5)
MDB.Query
```

**Select with JOIN:**
```b4x
MDB.Table = "tbl_products p"
MDB.Columns = Array("p.id", "p.name", "c.category_name")
MDB.Join("", "tbl_categories c", Array("p.category_id = c.id"))
MDB.Query
```

**Search (LIKE):**
```b4x
MDB.Conditions = Array("UPPER(name) LIKE ?")
MDB.Parameters = Array("%" & keyword.ToUpperCase & "%")
MDB.Query
```

**Update:**
```b4x
MDB.Table = "tbl_products"
MDB.Columns = Array("product_name", "price")
MDB.Parameters = Array("New Name", 12.99)
MDB.Condition = "id = ?"
MDB.Parameter = 1
MDB.ReturnRow = True
MDB.Save
```

**Delete:**
```b4x
MDB.Table = "tbl_products"
MDB.Id = 1
MDB.Delete
```

**Using `Find`:**
```b4x
MDB.Find(id)  ' Finds by primary key. Sets MDB.Found.
```

### Database Existence & Creation

```b4x
' Check if database exists
If MDB.Exist = False Then
    ' Create SQLite database file
    Dim Success As Boolean = MDB.CreateSQLite
    
    ' Or for MySQL/MariaDB (async):
    ' Wait For (MDB.CreateDatabaseAsync) Complete (Success As Boolean)
End If
```

### Batch Operations

```b4x
MDB.QueryExecute = False          ' Don't execute immediately
MDB.QueryAddToBatch = True        ' Add to batch

' Queue multiple inserts
MDB.Columns = Array("name")
MDB.InsertWithParams = Array("Item 1")
MDB.InsertWithParams = Array("Item 2")

' Execute all at once
Wait For (MDB.ExecuteBatchAsync) Complete (Success As Boolean)
```

### Error Handling

```b4x
MDB.Save
If MDB.Error.IsInitialized Then
    Log("Error: " & MDB.Error.Message)
End If
```

### Pooling (MySQL/MariaDB)

```b4x
If MDB.DbType = MDB.MARIADB Or MDB.DbType = MDB.MYSQL Then
    MDB.InitPool
End If
```

---

## 4. WebApiUtils — REST API Utilities

**GitHub:** https://github.com/pyhoon/WebApiUtils-B4J  
**Version in Pakai:** 6.99

### What It Does

WebApiUtils provides utilities for building RESTful APIs, including:
- HTTP response formatting (JSON/XML)
- Request payload parsing
- Content type validation
- Help/API documentation generation
- OpenAPI 3.0 spec generation

### Core Response Methods

```b4x
' Create response message
Dim HRM As HttpResponseMessage
HRM.Initialize
HRM.ResponseCode = 200
HRM.ResponseData = ListOfMaps    ' For list responses
HRM.ResponseObject = SingleMap   ' For single object responses
HRM.ResponseMessage = "Success"
HRM.VerboseMode = True
HRM.OrderedKeys = True
HRM.ContentType = "application/json"

' Send response
WebApiUtils.ReturnHttpResponse(HRM, Response)

' Shortcuts for errors
WebApiUtils.ReturnBadRequest(HRM, Response)
```

### Request Parsing

```b4x
' Read request body as text
Dim str As String = WebApiUtils.RequestDataText(Request)

' Validate content type
If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
    ' Invalid payload
End If

' Parse payload
Dim data As Map
If HRM.PayloadType = WebApiUtils.MIME_TYPE_XML Then
    data = WebApiUtils.ParseXML(str)    ' XML → Map
Else
    data = WebApiUtils.ParseJSON(str)   ' JSON → Map
End If
```

### Response Format

Verbose mode (default: True):
```json
{
    "a": 200,        "code": 200,
    "m": "Success",  "message": "Success",
    "s": true,       "status": true,
    "t": "json",     "type": "json",
    "r": [...]       "result": [...]
}
```
Short key names in the actual output (`a`, `m`, `s`, `t`, `r`) for bandwidth efficiency.

Non-verbose mode:
```json
{
    "data": [...]  /** response body as json object or array **/
}
```
*status code 200 is sent using http response header*

### HTML Response Helpers

```b4x
' Return HTML page
WebApiUtils.ReturnHtml(htmlString, Response)

' Build HTML with variable substitution
strMain = WebApiUtils.BuildHtml(strMain, App.ctx)
```

### Constants

```b4x
WebApiUtils.MIME_TYPE_JSON   ' "application/json"
WebApiUtils.MIME_TYPE_XML    ' "application/xml"
```

---

## 5. MiniCSS — CSS Generation

**GitHub:** https://github.com/pyhoon/MiniCSS-B4X  
**Version in Pakai:** 0.30

### What It Does

MiniCSS generates CSS stylesheets from B4X code. It's the CSS counterpart of MiniHtml — instead of writing CSS files by hand, you generate them programmatically.

### Usage

```b4x
Dim css1 As MiniCSS
css1.Initialize

' Add a rule
css1.AddRule("body", "font-family", "Arial")
css1.AddRule(".myclass", "color", "red")
css1.AddRule("#myid", "background-color", "blue")

' Generate CSS string
Dim cssText As String = css1.ToString
' Result: body { font-family: Arial; } .myclass { color: red; } ...
```

### In Pakai Framework

MiniCSS is available as a library but Pakai primarily uses pre-built Bootstrap CSS and a small `main.css` for custom styles. You can use MiniCSS to dynamically generate additional CSS.

---

## 6. MiniJS — JavaScript Generation

**GitHub:** https://github.com/pyhoon/MiniJS-B4X  
**Version in Pakai:** 0.60

### What It Does

MiniJS generates JavaScript code from B4X. Similar to MiniHtml/MiniCSS — write JS in B4X syntax.

### Usage

```b4x
Dim js As MiniJS
js.Initialize

' Add JS statements
js.log("Hello from B4X!")
' Generates: console.log("Hello from B4X!");

js.alert("Welcome")
' Generates: alert("Welcome");
```

### In Pakai Framework

Pakai uses a minimal `app.js` file for HTMX toast handling, error handling, and the Chrome `aria-hidden` fix. MiniJS can be used if you need dynamic JS generation.

---

## 7. MH.bas & MC.bas — Pakai Helper Modules

These static code modules come bundled with Pakai Framework and provide convenient wrappers. They can also be added from **MiniHtml** library using `Code Snippets`.

### MH.bas (MiniHtml Helpers)

Provides pre-built UI components:

```b4x
' Buttons
MH.ButtonAdd("Label", "btn-class", "/hx/url", "#target", "click", "#modal", "modal")
MH.ButtonSubmit("Label", "btn-class")
MH.ButtonCancel("Label", "btn-class")
MH.ButtonSearch("Label", "btn-class", "/hx/search", "#target")

' Forms & Inputs
MH.FormGroup   ' Wrapper div with margin
MH.InputGroup  ' Label + input in one group
MH.TextLabel("Text", "class", "id")
MH.InputSearch("class", "name", "id")
MH.RequiredLabel("Label", "id")
MH.RequiredTextInput("id", "name", "value")
MH.RequiredDropdown("id", "name")
MH.HiddenInput("id", "name", "value")

' Navigation
MH.NavLinkItem("Text", "/url", "icon-class", "Name")
MH.AnchorIcon("class", "/url", "title", "icon-class")
MH.GitHubLink   ' GitHub corner ribbon

' Alerts & Toasts
MH.Alert(AlertInfo)              ' Bootstrap alert
MH.Toast(containerId, tableHtml, ToastInfo)  ' Toast + table refresh
MH.CreateAlertInfo("msg", "status")   ' Create AlertInfo object
MH.CreateToastInfo("entity", "action", "msg", "status")

' Modals
MH.ContainerModal    ' Modal dialog container HTML
MH.ContainerToast    ' Toast notification container HTML
```

### MC.bas (MiniHtml Caching)

```b4x
' Check if cached
If MC.ExistInCache(ctx, "CacheName") = False Then
    ' Build and cache
    MC.WriteToCache(ctx, "CacheName", htmlContent)
End If

' Read from cache
Dim cachedHtml As MiniHtml = MC.ReadFromCache(ctx, "CacheName")
```

Two cache modes:
- **String mode:** `MC.WriteToCache(ctx, name, MiniHtmlObject)` — stores the MiniHtml object
- **Binary mode:** `MC.WriteToCache(ctx, name, MiniHtmlObject.ConvertToBytes)` — stores as bytes (for cloned rows)

The cache is keyed by the context map (`App.ctx`) and persists for the lifetime of the server process.

---

## Summary

| Task | Library | Key Class |
|------|---------|-----------|
| Start HTTP server, register routes | EndsMeet | `App` (EndsMeet) |
| Generate HTML views | MiniHtml | `MiniHtml` |
| UI helpers | MiniHtml | `MH` (Code Snippet: Helper) |
| Cache rendered HTML | MiniHtml | `MC` (Code Snippet: Cache) |
| Database CRUD | MiniORMUtils | `MiniORM` |
| Generate CSS | MiniCSS | `MiniCSS` |
| Generate JavaScript | MiniJS | `MiniJS` |
| Format API responses | WebApiUtils | `HttpResponseMessage` |
| Format text responses | WebApiUtils | `HttpResponseContent` |

---

*All libraries are open source under MIT license. See individual repositories for detailed documentation.*
