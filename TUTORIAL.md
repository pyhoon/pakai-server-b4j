# Pakai Framework v6.99 — Full Tutorial

> **Last updated:** July 2026  
> **Version:** 6.99  
> **Forum thread:** https://www.b4x.com/android/forum/threads/pakai-framework-v6.169286/  
> **Project template:** https://www.b4x.com/android/forum/threads/web-project-template-pakai-server-v6.169224/

---

## Chapter 1 — Introduction

Pakai Framework is a full-stack B4J web application framework built on top of the **EndsMeet** web server. It provides a complete foundation for building modern web applications with server-side HTML rendering, HTMX-driven interactivity, and a full REST API layer — all written in B4X.

### What's New in v6.99

- HTMX 2.0.8 frontend (no custom JavaScript needed for CRUD)
- Server-side HTML via MiniHtml 3.00 DSL (no HTML templates)
- Three project variants: Full Stack, API-only, Web-only
- Multi-database: SQLite, MySQL, MariaDB
- Auto-generated OpenAPI 3.0 + Swagger UI
- Interactive API console with AlpineJS
- B4X code snippets for all endpoints
- HTML caching for performance
- HTTPS/SSL with auto-redirect

### Three Flavors

| Variant | Modules | Use Case |
|---------|:---:|----------|
| **Pakai Server** (Full Stack) | 15 | Web UI + REST API + Docs |
| **Pakai Server Api** | 9 | REST API only |
| **Pakai Server Web** | 11 | Web UI only (no REST) |

### Architecture

```
┌─────────────────────────────────────────────────┐
│                   Browser                       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│              EndsMeet Web Server                │
│    ┌──────────────┐   ┌──────────────────┐      │
│    │ Web Handler  │   │  API Handler     │      │
│    │ (HTMX HTML)  │   │  (JSON/XML)      │      │
│    └──────┬───────┘   └────────┬─────────┘      │
│           │                    │                │
│    ┌──────▼────────────────────▼─────────┐      │
│    │           Model  (MiniORM)          │      │
│    └────────────────┬────────────────────┘      │
└─────────────────────┼───────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │ SQLite / MySQL / MariaDB  │
        └───────────────────────────┘
```

---

## Chapter 2 — Installation & Setup

### Prerequisites

- **B4J IDE** v10.5 or later (https://www.b4x.com/b4j.html)
- **Java JDK** 19+ (bundled with B4J or download separately)
- **B4X Libraries** (see below)

### Step 1: Download the Required Libraries

Download these `.b4xlib` and `.jar` files and place them in your B4J **Additional Libraries** folder:

| Library | Version | Download |
|---------|---------|----------|
| EndsMeet | 2.20 | [GitHub](https://github.com/pyhoon/EndsMeet/releases/download/v2.20/EndsMeet.b4xlib) |
| MiniHtml | 3.00 | [GitHub](https://github.com/pyhoon/MiniHtml2-B4X/releases/download/v3.00/MiniHtml.b4xlib) |
| MiniORMUtils | 6.00 | [GitHub](https://github.com/pyhoon/MiniORMUtils-B4X/releases/download/v6.00/MiniORMUtils.b4xlib) |
| MiniCSS | 0.30 | [GitHub](https://github.com/pyhoon/MiniCSS-B4X/releases/download/v0.30/MiniCSS.b4xlib) |
| MiniJS | 0.60 | [GitHub](https://github.com/pyhoon/MiniJS-B4X/releases/download/v0.60/MiniJS.b4xlib) |
| WebApiUtils | 6.99 | [GitHub](https://github.com/pyhoon/WebApiUtils-B4J/releases/download/v6.99/WebApiUtils.b4xlib) |
| sqlite-jdbc | 3.7.2 | (included or download from Maven) |
| mariadb-java-client | 3.5.6 | (included or download from MariaDB) |

> **Pro tip:** Use `libget.jar` (https://github.com/pyhoon/libget-b4j) to auto-download all libraries. Place it in your Additional folder and click the **GetLibraries** macro in the IDE.

### Step 2: Install the Project Template

Copy the `release/Pakai Server (6.99).b4xtemplate` file to your B4J **Additional Libraries** folder.

**Default paths:**
- Windows: `C:\Program Files\Anywhere Software\B4J\Additional`
- Or the path shown in B4J IDE under **Tools → Configure Paths**

### Step 3: Create a New Project

| Screenshot | Description |
|------------|-------------|
| *(screenshot: File → New → Pakai Server)* | In B4J IDE, go to **File → New** and select **Pakai Server (6.99)** from the template list |
| *(screenshot: New Project dialog)* | Enter your **Project Name** (e.g., "MyApp"), confirm the project folder, and click **OK** |
| *(screenshot: IDE with project loaded)* | The project is created and all modules are loaded in the IDE. You should see 15 `.bas` files in the Modules tab |

### Step 4: Run the Project

1. Press **F5** (Compile & Run) or click the **Play** button on the toolbar
2. Wait for the first-time compilation — you'll see in the Logs:

```
Configuring database...
Checking database...
SQLite database not existed!
Creating database...
Creating tables...
Database is created successfully!
```

| Screenshot | Description |
|------------|-------------|
| *(screenshot: Logs showing database creation)* | The database is auto-created with `tbl_categories` and `tbl_products` tables, seeded with sample data (Hardwares, Toys categories; Teddy Bear, Hammer, Optimus Prime products) |

3. Hover over the comment link in the IDE (the blue underlined URL in the code) or open your browser to:

```
http://127.0.0.1:8080
```

| Screenshot | Description |
|------------|-------------|
| *(screenshot: Products index page)* | The Products page loads with a search bar, "Add Product" button, and a table showing 3 seed products |

---

## Chapter 3 — Exploring the Application

### Products Page (Home)

| Feature | Screenshot |
|---------|------------|
| Full page with search, table, and "Add Product" button | *(screenshot: Products page)* |
| Add Product modal with form fields (Category, Code, Name, Price) | *(screenshot: Add Product modal)* |
| Edit Product modal with pre-filled data | *(screenshot: Edit Product modal)* |
| Delete confirmation modal | *(screenshot: Delete confirmation)* |
| Toast notification after CRUD | *(screenshot: Toast message)* |
| Required field validation via Bootstrap | *(screenshot: validation popup)* |

The table loads dynamically via HTMX — notice `hx-get="/hx/products/table"` with `hx-trigger="load"` in the view. The search box sends a POST request to the same endpoint with a `keyword` parameter.

### Categories Page

Navigate via the **Categories** link in the navbar (use the hamburger menu on mobile).

| Feature | Screenshot |
|---------|------------|
| Categories list with Add/Edit/Delete | *(screenshot: Categories page)* |
| Error when deleting a category with associated products | *(screenshot: Cannot delete error)* |

The handler checks `Model.FindProductByCategoryId(id)` before allowing deletion, enforcing referential integrity at the application level.

### API Documentation Page

Navigate to `http://127.0.0.1:8080/help`

| Feature | Screenshot |
|---------|------------|
| Interactive API docs with all endpoints listed | *(screenshot: API docs page)* |
| Each endpoint shows method, path, parameters, and "Try It" button | *(screenshot: endpoint detail)* |
| AlpineJS-powered interactive console | *(screenshot: API console)* |

You can also access:
- **OpenAPI 3.0 spec:** `http://127.0.0.1:8080/help?format=openapi` (JSON)
- **B4X code snippets:** `http://127.0.0.1:8080/help?format=snippets` (text)

---

## Chapter 4 — Server Configuration

The server is configured via `Objects/config.ini` (auto-created on first run):

```ini
# App Constants
APP_TITLE=Pakai                 # Browser tab title
APP_TRADEMARK=PAKAI             # Navbar brand text
HOME_TITLE=PAKAI FRAMEWORK      # Heading on home page
APP_COPYRIGHT=Copyright Your Company 2026  # Footer text

# Server
ROOT_URL=http://127.0.0.1       # Public-facing URL
ROOT_PATH=                      # Sub-path (e.g., /myapp)
PORT=8080                       # HTTP port
REDIRECT_TO_HTTPS=False         # Auto-redirect to HTTPS

# SSL
SSL_PORT=8888
SSL_KEYSTORE_DIR=
SSL_KEYSTORE_FILE=keystore.jks
SSL_KEYSTORE_PASSWORD=password
SSL_ENABLED=False

# Email
SMTP_SERVER=xxxxxxxxx
SMTP_USERNAME=xxxxxxxxx
SMTP_PASSWORD=xxxxxxxxx
SMTP_PORT=465
SMTP_USESSL=True
```

> Lines starting with `#` are comments; lines starting with `;` are disabled.

### Programmatic Configuration

Some settings can only be set in code:

```b4x
Sub AppStart (Args() As String)
    App.Initialize
    App.LoadConfig
    
    ' Override settings programmatically
    App.api.ContentType = "application/xml"
    App.api.VerboseMode = True
    App.api.EnableHelp = True
    
    ' SSL
    'App.ssl.Enabled = True
    'App.RedirectToHttps = True
    ...
End Sub
```

### Available ApiSettings

| Property | Default | Description |
|----------|---------|-------------|
| `Name` | `"api"` | API route prefix |
| `Versioning` | `False` | Enable API versioning |
| `PayloadType` | `"application/json"` | Default request payload type |
| `ContentType` | `"application/json"` | Default response content type |
| `EnableHelp` | `False` | Enable `/help` endpoint |
| `VerboseMode` | `True` | Verbose JSON response format |
| `OrderedKeys` | `True` | Preserve key order in response |

---

## Chapter 5 — Database Configuration

### Database Backend Switching

The database type is selected via **Build Configurations** in the B4J IDE toolbar:

| Configuration | Symbol | Database | Driver JAR |
|---------------|--------|----------|------------|
| Default | `hu2_acceptall` | SQLite | sqlite-jdbc-3.7.2.jar |
| MariaDB | `MariaDB,hu2_acceptall` | MariaDB | mariadb-java-client-3.5.6.jar |
| MySQL | `MySQL,hu2_acceptall` | MySQL | mysql-connector-j-9.3.0.jar |

The build symbols are defined at the top of the `.b4j` project file:
```b4j
Build1=Default,b4j.pakai,hu2_acceptall
Build2=MariaDB,b4j.pakai,MariaDB,hu2_acceptall
Build3=MySQL,b4j.pakai,MySQL,hu2_acceptall
```

### SQLite Configuration (`Objects/sqlite.ini`)

```ini
DbType=SQLite
DbDir=                # Leave empty for Objects folder (or same dir as JAR in production)
DbFile=pakai.db
```

SQLite uses **WAL (Write-Ahead Logging)** mode for better concurrent read performance — set automatically in `ORM.bas`:
```b4x
DBS.JournalMode = "WAL"
```

### MariaDB Configuration (`Objects/mariadb.ini`)

```ini
DbType=MariaDB
DbHost=localhost
DbPort=3306
DbName=pakai
User=root
Password=password
DriverClass=org.mariadb.jdbc.Driver
JdbcUrl=jdbc:mariadb://{DbHost}:{DbPort}/{DbName}?characterEncoding=utf8&useSSL=false
MaxPoolSize=0
```

For MySQL, create `mysql.ini` with the same structure but use `com.mysql.cj.jdbc.Driver` as the DriverClass.

> **Connection Pooling:** MariaDB and MySQL use connection pooling (`MDB.InitPool`). SQLite does not.

---

## Chapter 6 — Understanding the Code Architecture

### File Structure

```
source/
├── Pakai-Server.b4j        # Main project file (entry point)
├── ORM.bas                 # Database init & schema
├── MainView.bas            # Main HTML layout (navbar, footer, containers)
├── MC.bas                  # HTML caching utility
├── MH.bas                  # MiniHtml helper methods
│
├── ProductsModel.bas       # Products DB operations
├── ProductsView.bas        # Products HTML rendering
├── ProductsHandler.bas     # Products web handler (HTMX)
├── ProductsApiHandler.bas  # Products REST API handler
│
├── CategoriesModel.bas     # Categories DB operations
├── CategoriesView.bas      # Categories HTML rendering
├── CategoriesHandler.bas   # Categories web handler (HTMX)
├── CategoriesApiHandler.bas# Categories REST API handler
│
├── FindApiHandler.bas      # Search/filter API
├── HelpHandler.bas         # Auto-generated API docs
└── HttpsFilter.bas         # SSL redirect filter
```

### Entry Point — `AppStart`

The application starts in `Pakai-Server.b4j` (or the variant you're using):

```b4x
Sub AppStart (Args() As String)
    App.Initialize
    App.LoadConfig
    App.LogEnabled = True
    
    ' Register web routes (HTMX frontend)
    App.Get("", "ProductsHandler")
    App.Get("/categories", "CategoriesHandler")
    App.Rest("/hx/products/*", "ProductsHandler")
    App.Rest("/hx/categories/*", "CategoriesHandler")
    
    ' Register API routes
    App.Route("/api/find", "FindApiHandler", Array("get", "post"))
    App.Get("/api/find/products-by-category_id/*", "FindApiHandler")
    App.Rest("/api/products/*", "ProductsApiHandler")
    App.Rest("/api/categories/*", "CategoriesApiHandler")
    App.Get("/help", "HelpHandler")
    
    App.Start
    App.LogStartupMessage
    
    Api = App.api
    Api.EnableHelp = True
    ORM.InitDatabase
    
    StartMessageLoop
End Sub
```

### Routing Methods

| Method | Description |
|--------|-------------|
| `App.Get(path, handler)` | Register GET route |
| `App.Post(path, handler)` | Register POST route |
| `App.Put(path, handler)` | Register PUT route |
| `App.Delete(path, handler)` | Register DELETE route |
| `App.Rest(path, handler)` | Register all 4 methods (GET/POST/PUT/DELETE) |
| `App.Route(path, handler, methods)` | Register with custom method list |

### Request Flow

```
1. Browser sends HTTP request
2. EndsMeet matches route → calls Handler.Handle(req, resp)
3. Handler parses path/method, calls appropriate sub
4. Web Handler: returns HTML fragment via View (MiniHtml)
5. API Handler: returns JSON/XML via WebApiUtils
6. Model: performs database operations via MiniORM
```

---

## Chapter 7 — Building Web UI with MiniHtml

### The MiniHtml DSL

All HTML is generated in B4X code using a builder pattern:

```b4x
' Create a Bootstrap table
Dim table1 As MiniHtml = MH.Table
table1.cls("table table-bordered table-hover")
Dim thead1 As MiniHtml = MH.Thead.up(table1)
    MH.Th.up(thead1).text("Name")
    MH.Th.up(thead1).text("Actions")
MH.Tbody.up(table1)
```

The `.up(parent)` method attaches an element to its parent. `.cls()` sets CSS classes. `.text()` sets inner text.

### Common Helper Methods (MH.bas)

```b4x
' Buttons
MH.ButtonAdd(...)       ' Green "Add" button with HTMX attributes
MH.ButtonSubmit(...)    ' Submit button for forms
MH.ButtonCancel(...)    ' Cancel/Close button
MH.ButtonSearch(...)    ' Search button with HTMX

' Inputs
MH.TextLabel(...)       ' Label for input groups
MH.InputSearch(...)     ' Search input field
MH.RequiredLabel(...)   ' Required field label with asterisk
MH.RequiredTextInput(...) ' Required text input
MH.RequiredDropdown(...)  ' Required dropdown
MH.HiddenInput(...)     ' Hidden form input

' Navigation
MH.NavLinkItem(...)     ' Navbar link item
MH.AnchorIcon(...)      ' Icon link anchor
MH.GitHubLink           ' GitHub corner ribbon

' Layout
MH.Form                ' Form element
MH.FormGroup           ' Form group wrapper
MH.InputGroup          ' Input group with label+field
MH.ContainerModal      ' Modal dialog container
MH.ContainerToast      ' Toast notification container
MH.Alert(info)         ' Alert message
MH.Toast(...)          ' Toast notification with table
```

### HTML Caching with MC

Views can cache rendered HTML for better performance:

```b4x
Public Sub Show As String
    Dim CacheName As String = "Products Page"
    If MC.ExistInCache(App.ctx, CacheName) = False Then
        MC.WriteToCache(App.ctx, CacheName, ProductsPage)
    End If
    Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
    ' ...
End Sub
```

Table row caching is especially useful for lists:
```b4x
' Cache the table row template
Dim CacheName As String = "Products Table Row"
If MC.ExistInCache(App.ctx, CacheName) = False Then
    MC.WriteToCache(App.ctx, CacheName, ProductsTableRow.ConvertToBytes)
End If

' Clone it for each data row
For Each row As Map In data
    Dim tr1 As MiniHtml = MC.ReadFromCache(App.ctx, "Products Table Row")
    tr1.ChildByIndex(0).text2(row.Get("id"))
    ' ...
Next
```

### HTMX Integration

Forms and buttons use HTMX attributes for AJAX requests:

```b4x
' Form that sends POST via HTMX
Dim form1 As MiniHtml = MH.Form
form1.attr("hx-post", "/hx/products")
form1.attr("hx-target", "#modal-messages")
form1.attr("hx-swap", "innerHTML")

' Add button that opens a modal
MH.ButtonAdd("Add Product", "btn btn-success ml-2", _
    "/hx/products/add", "#modal-content", "click", "#modal-container", "modal")
```

HTMX attributes used:
- `hx-get`, `hx-post`, `hx-put`, `hx-delete` — HTTP method and URL
- `hx-target` — CSS selector for element to swap content into
- `hx-trigger` — Event that triggers the request (e.g., `load`, `click`)
- `hx-swap` — How to swap the content (e.g., `innerHTML`, `outerHTML`)

### Frontend JavaScript (`app.js`)

The minimal JavaScript handles:
1. Closing modal and showing toast after successful CRUD
2. Global HTMX error handling
3. Chrome `aria-hidden` focus fix

---

## Chapter 8 — Building REST API

### Handler Structure

Each API handler follows the same pattern:

```b4x
Sub Handle (req As ServletRequest, resp As ServletResponse)
    Request = req
    Response = resp
    Path = Request.RequestURI
    Method = Request.Method.ToUpperCase
    
    If Path = "/api/products" And Method = "GET" Then
        GetProducts
    Else If Path = "/api/products" And Method = "POST" Then
        PostProduct
    Else If Path.StartsWith("/api/products/") And Method = "GET" Then
        GetProductById
    ...
End Sub
```

### Complete API Reference

#### Products

| Method | URL | Handler Sub | Description |
|--------|-----|-------------|-------------|
| GET | `/api/products` | `GetProducts` | List all products |
| GET | `/api/products/{id}` | `GetProductById` | Get product by ID |
| POST | `/api/products` | `PostProduct` | Create product |
| PUT | `/api/products/{id}` | `PutProductById` | Update product |
| DELETE | `/api/products/{id}` | `DeleteProductById` | Delete product |

**POST/PUT required fields:** `category_id`, `product_code`, `product_name`  
**Optional field:** `product_price` (default 0.00)

#### Categories

| Method | URL | Handler Sub | Description |
|--------|-----|-------------|-------------|
| GET | `/api/categories` | `GetCategories` | List all categories |
| GET | `/api/categories/{id}` | `GetCategoryById` | Get category by ID |
| POST | `/api/categories` | `PostCategory` | Create category |
| PUT | `/api/categories/{id}` | `PutCategoryById` | Update category |
| DELETE | `/api/categories/{id}` | `DeleteCategoryById` | Delete category |

**POST/PUT required fields:** `category_name`

#### Find

| Method | URL | Handler Sub | Description |
|--------|-----|-------------|-------------|
| GET | `/api/find` | `GetAllProducts` | List all products |
| POST | `/api/find` | `SearchByKeywords` | Search products by keyword |
| GET | `/api/find/products-by-category_id/{id}` | `GetProductsByCategoryId` | Filter by category ID |

**POST body:** `{"keyword": "search text"}`

### Response Format

Successful response (verbose mode):
```json
{
    "a": 200,
    "m": "Success",
    "s": true,
    "t": "application/json",
    "r": [ ... data ... ]
}
```

Error response:
```json
{
    "a": 400,
    "e": "Key 'category_name' not found"
}
```

### Error Codes

| Code | When |
|------|------|
| 200 | Success |
| 201 | Created |
| 400 | Missing required field, invalid ID format |
| 404 | Resource not found |
| 409 | Duplicate (product code or category name already exists) |
| 422 | Database error, invalid payload |

### JSON and XML Payloads

The API automatically detects the payload format:

```b4x
' In handler:
Dim str As String = WebApiUtils.RequestDataText(Request)
If HRM.PayloadType = WebApiUtils.MIME_TYPE_XML Then
    Dim data As Map = WebApiUtils.ParseXML(str)    ' XML payload
Else
    Dim data As Map = WebApiUtils.ParseJSON(str)   ' JSON payload
End If
```

Set default format:
```b4x
App.api.PayloadType = WebApiUtils.MIME_TYPE_XML   ' Default to XML
' or
App.api.PayloadType = WebApiUtils.MIME_TYPE_JSON  ' Default to JSON
```

---

## Chapter 9 — Creating a New Model (CRUD Example)

Here's how to add a new entity. Let's say we want to add **Suppliers**.

### Step 1: Create the Model (`SuppliersModel.bas`)

```b4x
Sub Class_Globals
    Private DB As MiniORM
End Sub

Public Sub Initialize
    DB = Main.DB
End Sub

Public Sub Create (Name As String, Created_Date As String)
    DB.Open
    DB.Table = "tbl_suppliers"
    DB.Columns = Array("supplier_name", "created_date")
    DB.Parameters = Array(Name, Created_Date)
    DB.ReturnRow = True
    DB.Save
End Sub

Public Sub Read As List
    DB.Open
    DB.Table = "tbl_suppliers"
    DB.Columns = Array("id", "supplier_name")
    DB.Query
    Return DB.Results
End Sub

Public Sub GetRowById (Id As Int) As Map
    DB.Open
    DB.Table = "tbl_suppliers"
    DB.Condition = "id = ?"
    DB.Parameter = Id
    DB.Query
    If DB.Found Then Return DB.First
    Return CreateMap()
End Sub

Public Sub Update (Id As Int, Name As String, Modified_Date As String)
    DB.Open
    DB.Table = "tbl_suppliers"
    DB.Columns = Array("supplier_name", "modified_date")
    DB.Parameters = Array(Name, Modified_Date)
    DB.Condition = "id = ?"
    DB.Parameter = Id
    DB.ReturnRow = True
    DB.Save
End Sub

Public Sub Delete (Id As Int)
    DB.Open
    DB.Table = "tbl_suppliers"
    DB.Id = Id
    DB.Delete
End Sub

Public Sub Found As Boolean
    Return DB.Found
End Sub

Public Sub First As Map
    Return DB.First
End Sub

Public Sub Error As Exception
    Return DB.Error
End Sub
```

### Step 2: Add Table Creation to `ORM.bas`

In `CreateDatabase`:
```b4x
MDB.Table = "tbl_suppliers"
MDB.Columns.Add(CreateMap("Name": "supplier_name", "Null": False))
MDB.Create

MDB.Columns = Array("supplier_name")
MDB.InsertWithParams = Array("Acme Corp")
MDB.InsertWithParams = Array("Globex Inc")
```

### Step 3: Create the View (`SuppliersView.bas`)

Use the same pattern as `CategoriesView.bas` — create a `Show` method with caching, modal methods for Add/Edit/Delete, and table rendering.

### Step 4: Create the Web Handler (`SuppliersHandler.bas`)

Register routes in `AppStart`:
```b4x
App.Get("/suppliers", "SuppliersHandler")
App.Rest("/hx/suppliers/*", "SuppliersHandler")
```

### Step 5: Create the API Handler (`SuppliersApiHandler.bas`)

Register routes:
```b4x
App.Rest("/api/suppliers/*", "SuppliersApiHandler")
```

### Step 6: Add to HelpHandler

In `HelpHandler.Initialize`:
```b4x
Handlers.Add("SuppliersApiHandler")
```

---

## Chapter 10 — Deployment & Production

### Build for Release

1. Enable SSL in `config.ini`:
```ini
SSL_ENABLED=True
SSL_PORT=443
```

Or in code:
```b4x
#If Release
App.ssl.Enabled = True
App.RedirectToHttps = True
#End If
```

2. Generate a keystore (or use Let's Encrypt):
```
keytool -keystore keystore.jks -alias jetty -genkey -keyalg RSA
```

3. Select **Release** build configuration in the IDE

4. Compile (Ctrl+F5) to generate the runnable JAR file in `Objects\`

### Database Migration

For SQLite → MariaDB/MySQL migration:
1. Export SQLite data to SQL
2. Create the target database
3. Change build configuration to MariaDB/MySQL
4. Update the `.ini` file with connection details
5. Recompile and run

### Environment Variables

For sensitive data (passwords), use environment variables or external config files. The config.ini system supports reading from different sources.

---

## Appendix A — Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 8080 already in use | Change `PORT` in config.ini or kill the process using that port |
| Database creation fails | Check write permissions in Objects folder. For MySQL/MariaDB, verify credentials and network access |
| Libraries not found | Run the **GetLibraries** macro or manually download and place in Additional folder |
| Browser shows blank page | Check the B4J Logs tab for errors. Verify `ROOT_URL` in config.ini |
| HTMX requests not working | Check browser console for 404 errors. Verify route paths match handler methods |
| SSL handshake error | Regenerate keystore or check keystore password in config.ini |

---

## Appendix B — Quick Reference

### Common MiniHtml Patterns

```b4x
' Element with class
MH.Div.cls("my-class")

' Element as child of parent
MH.Span.up(parentElement)

' Element with text
MH.H1.text("Hello World")

' Element with attributes
MH.Input.attr("type", "text").attr("name", "username")

' CDN link
head1.cdn("style", "https://cdn.example.com/style.css")

' CDN with integrity
head1.cdn2("style", "url", "sha384-...", "anonymous")

' Icon
MH.Icon.cls("bi bi-pencil")
```

### MiniORM Quick Reference

```b4x
' Insert
DB.Columns = Array("name", "price")
DB.Parameters = Array("Widget", 9.99)
DB.ReturnRow = True
DB.Save

' Select all
DB.Table = "tbl_products"
DB.Query
Dim AllRows As List = DB.Results

' Select with condition
DB.Condition = "id = ?"
DB.Parameter = 1
DB.Query
Dim Row As Map = DB.First

' Update
DB.Columns = Array("name")
DB.Parameters = Array("New Name")
DB.Condition = "id = ?"
DB.Parameter = 1
DB.ReturnRow = True
DB.Save

' Delete
DB.Id = 1
DB.Delete

' Join
DB.Table = "tbl_products p"
DB.Join("", "tbl_categories c", Array("p.category_id = c.id"))
DB.Query

' Search (LIKE)
DB.Conditions = Array("UPPER(name) LIKE ?")
DB.Parameters = Array("%" & keyword.ToUpperCase & "%")
DB.Query
```

---

*This tutorial is based on Pakai Server v6.99. The source code and project template are available on GitHub: https://github.com/pyhoon/pakai-server-b4j*
