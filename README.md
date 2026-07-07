# Pakai Server — B4J Fullstack Web Application & API Framework

**Version:** 6.99 | **License:** MIT | **Author:** Poon Yip Hoon (Aeric)

Pakai Server is a full-stack B4J project template for building modern web applications and REST APIs. It generates **all HTML server-side** using B4X code (no client-side rendering), leverages **HTMX** for dynamic interactions without custom JavaScript, and includes both a **Web UI** and a **REST API** with auto-generated **OpenAPI 3.0** documentation and **Swagger UI**.

> **Forum thread:** [https://www.b4x.com/android/forum/threads/web-project-template-pakai-server-v6.169224/](https://www.b4x.com/android/forum/threads/web-project-template-pakai-server-v6.169224/)  
> **GitHub:** [https://github.com/pyhoon/pakai-server-b4j](https://github.com/pyhoon/pakai-server-b4j)

![Index](pakai-index.png)

---

## Features

- **Three deployment variants** — Full Stack (Web + API), API-only, Web-only
- **HTMX 2.0.8** frontend — no custom JavaScript for CRUD; server returns HTML fragments
- **Bootstrap 5.3.8** responsive UI with modal dialogs and toast notifications
- **AlpineJS 3.15.8** interactive API console on the documentation page
- **REST API** — JSON and XML payload support with full CRUD operations
- **Auto-generated API docs** — `/help` page with interactive console
- **OpenAPI 3.0** JSON spec generation at `/help?format=openapi`
- **B4X code snippets** generation at `/help?format=snippets`
- **Swagger UI** integration
- **Multi-database** — SQLite (default), MySQL, MariaDB (compile-time switching)
- **Server-side HTML generation** via MiniHtml B4X library (DSL-like builder)
- **HTML caching** for performance optimization
- **SSL/HTTPS** support with automatic HTTP-to-HTTPS redirect
- **SQLite WAL mode** for better concurrent read performance
- **Connection pooling** for MySQL/MariaDB
- **Input validation** and duplicate-conflict checking at both UI and API levels

---

## Project Variants (Templates)

| Template | Modules | Description |
|----------|---------|-------------|
| `Pakai Server (6.99).b4xtemplate` | 15 | Full stack: Web UI + REST API + Documentation |
| `Pakai Server Api (6.99).b4xtemplate` | 9 | API only: REST endpoints + HelpHandler as landing page |
| `Pakai Server Web (6.99).b4xtemplate` | 11 | Web only: HTMX frontend without REST API |

### Build Configurations

| Configuration | Compile Symbol | Database |
|---------------|---------------|----------|
| Default | `hu2_acceptall` | SQLite |
| MariaDB | `MariaDB,hu2_acceptall` | MariaDB |
| MySQL | `MySQL,hu2_acceptall` | MySQL |

---

## Quick Start

### Prerequisites

- B4J IDE (version 10.5 or later)
- Java JDK 19+ (or compatible)

### Setup & Run

1. **Install B4J IDE** from [https://www.b4x.com/b4j.html](https://www.b4x.com/b4j.html)
2. **Download libraries** — click the `GetLibraries` macro button in the IDE (uses `libget.jar`) or manually download the dependencies listed below
3. **Open a project file** in B4J:
   - `source/Pakai-Server.b4j` — Full stack
   - `source/Pakai-Server-Api.b4j` — API only
   - `source/Pakai-Server-Web.b4j` — Web only
4. **Select build configuration** — Default (SQLite), MariaDB, or MySQL
5. **Press F5** (Run) — the server starts
6. **Open a browser** to `http://127.0.0.1:8080`

On first run, the application auto-creates the database file (`pakai.db` for SQLite), creates the `tbl_categories` and `tbl_products` tables, and populates them with seed data (2 categories, 3 products).

### Database Configuration

**SQLite** (`Objects/sqlite.ini`):
```ini
DbType=SQLite
DbDir=
DbFile=pakai.db
```

**MariaDB** (`Objects/mariadb.ini`):
```ini
DbType=MariaDB
DbHost=localhost
DbPort=
DbName=pakai
User=root
Password=password
DriverClass=org.mariadb.jdbc.Driver
JdbcUrl=jdbc:mariadb://{DbHost}:{DbPort}/{DbName}?characterEncoding=utf8&useSSL=false
MaxPoolSize=0
```

**MySQL** — create `Objects/mysql.ini` following the same pattern as `mariadb.ini`.

> When the database is configured for MariaDB or MySQL, the application auto-creates the schema (database) if it does not exist.

---

## Server Configuration (`Objects/config.ini`)

```ini
APP_TITLE=Pakai
APP_TRADEMARK=PAKAI
HOME_TITLE=PAKAI FRAMEWORK
APP_COPYRIGHT=Copyright Computerise System Solutions 2026

ROOT_URL=http://127.0.0.1
ROOT_PATH=
PORT=8080
REDIRECT_TO_HTTPS=False

SSL_PORT=8888
SSL_KEYSTORE_FILE=keystore.jks
SSL_KEYSTORE_PASSWORD=password
SSL_ENABLED=False
```

SMTP email settings are also available for notification features.

---

## Architecture

The application follows a **Model-View-Handler** pattern:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Handler    │ ──> │    Model     │ ──> │  Database    │
│ (Routing)    │     │  (Business)  │     │  (MiniORM)   │
├──────────────┤     ├──────────────┤     └──────────────┘
│ - Web Handler│     │ - CRUD       │
│ - API Handler│     │ - Validation │
│ - Find/Help  │     │ - Search     │
└──────────────┘     └──────────────┘
       │                      │
       v                      v
┌──────────────┐     ┌──────────────┐
│    View      │     │  Json/XML    │
│  (MiniHtml)  │     │ (WebApiUtils)│
└──────────────┘     └──────────────┘
```

### Module Map (Full Stack — 15 Modules)

| Module | Type | Purpose |
|--------|------|---------|
| `ORM.bas` | Static Code | Database init, table creation, seed data |
| `MainView.bas` | Class | Main HTML layout (Bootstrap navbar, footer, containers) |
| `MC.bas` | Class | MiniHtml caching utility |
| `MH.bas` | Class | MiniHtml helper methods |
| `CategoriesModel.bas` | Class | tbl_categories CRUD operations |
| `CategoriesView.bas` | Class | Categories HTML rendering (table, modals) |
| `CategoriesHandler.bas` | Class | Web handler for `/categories`, `/hx/categories/*` |
| `CategoriesApiHandler.bas` | Class | REST API handler for `/api/categories/*` |
| `ProductsModel.bas` | Class | tbl_products CRUD with JOIN and search |
| `ProductsView.bas` | Class | Products HTML rendering (table, search, modals) |
| `ProductsHandler.bas` | Class | Web handler for `/`, `/hx/products/*` |
| `ProductsApiHandler.bas` | Class | REST API handler for `/api/products/*` |
| `FindApiHandler.bas` | Class | Search/filter API for products |
| `HelpHandler.bas` | Class | Auto-generated API docs + OpenAPI 3.0 spec |
| `HttpsFilter.bas` | Class | SSL redirect filter |

---

## Database Schema

### `tbl_categories`

| Column | Type | Constraints |
|--------|------|------------|
| id | INTEGER | Auto-increment, Primary Key |
| category_name | TEXT | NOT NULL |
| created_date | TEXT | Timestamp |
| modified_date | TEXT | Timestamp |

### `tbl_products`

| Column | Type | Constraints |
|--------|------|------------|
| id | INTEGER | Auto-increment, Primary Key |
| category_id | INTEGER | NOT NULL, FK → tbl_categories.id |
| product_code | TEXT | NOT NULL, length 12 |
| product_name | TEXT | NOT NULL |
| product_price | DECIMAL(10,2) | Default 0.00 |
| product_image | BLOB | Optional |
| created_date | TEXT | Timestamp |
| modified_date | TEXT | Timestamp |

### Seed Data

**Categories:** Hardwares, Toys  
**Products:** Teddy Bear (Toys, $99.90), Hammer (Hardwares, $15.75), Optimus Prime (Toys, $1000.00)

---

## Routes

### Web UI (HTMX)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/` | ProductsHandler | Product listing page with search |
| GET | `/categories` | CategoriesHandler | Category listing page |
| GET | `/hx/products/table` | ProductsHandler | Product table HTML (search results) |
| GET | `/hx/products/add` | ProductsHandler | Add product modal dialog |
| GET | `/hx/products/edit/{id}` | ProductsHandler | Edit product modal dialog |
| GET | `/hx/products/delete/{id}` | ProductsHandler | Delete confirmation modal |
| POST | `/hx/products/*` | ProductsHandler | Create product |
| PUT | `/hx/products/*` | ProductsHandler | Update product |
| DELETE | `/hx/products/*` | ProductsHandler | Delete product |
| GET | `/hx/categories/table` | CategoriesHandler | Categories table HTML |
| GET | `/hx/categories/add` | CategoriesHandler | Add category modal dialog |
| GET | `/hx/categories/edit/{id}` | CategoriesHandler | Edit category modal dialog |
| GET | `/hx/categories/delete/{id}` | CategoriesHandler | Delete confirmation modal |
| POST | `/hx/categories/*` | CategoriesHandler | Create category |
| PUT | `/hx/categories/*` | CategoriesHandler | Update category |
| DELETE | `/hx/categories/*` | CategoriesHandler | Delete category |

### REST API

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/products` | ProductsApiHandler | List all products |
| GET | `/api/products/{id}` | ProductsApiHandler | Get product by ID |
| POST | `/api/products` | ProductsApiHandler | Create product |
| PUT | `/api/products/{id}` | ProductsApiHandler | Update product |
| DELETE | `/api/products/{id}` | ProductsApiHandler | Delete product |
| GET | `/api/categories` | CategoriesApiHandler | List all categories |
| GET | `/api/categories/{id}` | CategoriesApiHandler | Get category by ID |
| POST | `/api/categories` | CategoriesApiHandler | Create category |
| PUT | `/api/categories/{id}` | CategoriesApiHandler | Update category |
| DELETE | `/api/categories/{id}` | CategoriesApiHandler | Delete category |
| GET | `/api/find` | FindApiHandler | List all products (alias) |
| POST | `/api/find` | FindApiHandler | Search products by keyword |
| GET | `/api/find/products-by-category_id/{id}` | FindApiHandler | Get products by category |

### Documentation

| Method | Path | Description |
|--------|------|-------------|
| GET | `/help` | Interactive API documentation page |
| GET | `/help?format=openapi` | OpenAPI 3.0 JSON specification |
| GET | `/help?format=snippets` | B4X code snippets for all endpoints |

---

## API Usage Examples

### Products

**List all products**
```http
GET /api/products
```
Response:
```json
{
  "code": 200,
  "data": [
    {"id": 1, "category_id": 2, "category_name": "Toys", "product_code": "T001", "product_name": "Teddy Bear", "product_price": 99.9},
    {"id": 2, "category_id": 1, "category_name": "Hardwares", "product_code": "H001", "product_name": "Hammer", "product_price": 15.75},
    {"id": 3, "category_id": 2, "category_name": "Toys", "product_code": "T002", "product_name": "Optimus Prime", "product_price": 1000}
  ]
}
```

**Get product by ID**
```http
GET /api/products/1
```
```json
{
  "code": 200,
  "data": {"id": 1, "category_id": 2, "product_code": "T001", "product_name": "Teddy Bear", "product_price": 99.9}
}
```

**Create a product**
```http
POST /api/products
Content-Type: application/json

{
  "category_id": 1,
  "product_code": "H002",
  "product_name": "Screwdriver",
  "product_price": 8.50
}
```
```json
{
  "code": 201,
  "message": "Product created successfully",
  "data": {"id": 4, "category_id": 1, "product_code": "H002", "product_name": "Screwdriver", "product_price": 8.5}
}
```

**Update a product**
```http
PUT /api/products/4
Content-Type: application/json

{
  "category_id": 1,
  "product_code": "H002",
  "product_name": "Screwdriver Set",
  "product_price": 12.00
}
```
```json
{
  "code": 200,
  "message": "Product updated successfully",
  "data": {...}
}
```

**Delete a product**
```http
DELETE /api/products/4
```
```json
{
  "code": 200,
  "message": "Product deleted successfully"
}
```

### Categories

**List all categories**
```http
GET /api/categories
```
```json
{
  "code": 200,
  "data": [
    {"id": 1, "category_name": "Hardwares"},
    {"id": 2, "category_name": "Toys"}
  ]
}
```

**Create a category**
```http
POST /api/categories
Content-Type: application/json

{"category_name": "Electronics"}
```
```json
{
  "code": 201,
  "message": "Category created successfully",
  "data": {"id": 3, "category_name": "Electronics"}
}
```

### Search / Find

**Search products by keyword**
```http
POST /api/find
Content-Type: application/json

{"keyword": "bear"}
```
```json
{
  "code": 200,
  "data": [
    {"id": 1, "category_id": 2, "category_name": "Toys", "product_code": "T001", "product_name": "Teddy Bear", "product_price": 99.9}
  ]
}
```

**Products by category**
```http
GET /api/find/products-by-category_id/1
```
```json
{
  "code": 200,
  "data": [
    {"id": 2, "category_id": 1, "category_name": "Hardwares", "product_code": "H001", "product_name": "Hammer", "product_price": 15.75}
  ]
}
```

### Error Responses

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad request (missing required field, invalid ID) |
| 404 | Not found |
| 409 | Conflict (duplicate product code or category name) |
| 422 | Unprocessable entity (database error, invalid payload) |

```json
{
  "code": 400,
  "error": "Key 'category_name' not found"
}
```

> The API supports both **JSON** and **XML** payloads. Set `Content-Type: application/xml` to send XML. Response format is determined by the client's `Accept` header or the server's default configuration.

---

## Dependencies

### B4X Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| [EndsMeet](https://github.com/pyhoon/EndsMeet) | 2.20 | Web framework (routing, HTTP server, sessions, SSL) |
| [MiniCSS](https://github.com/pyhoon/MiniCSS-B4X) | 0.30 | CSS generation from B4X code |
| [MiniHtml](https://github.com/pyhoon/MiniHtml2-B4X) | 3.00 | HTML generation (DSL-like builder) |
| [MiniJS](https://github.com/pyhoon/MiniJS-B4X) | 0.60 | JavaScript generation from B4X code |
| [MiniORMUtils](https://github.com/pyhoon/MiniORMUtils-B4X) | 6.00 | ORM database abstraction layer |
| [WebApiUtils](https://github.com/pyhoon/WebApiUtils-B4J) | 6.99 | REST API utilities (response formatting, XML/JSON) |

### Optional Tools

- [B4X libraries downloader](https://github.com/pyhoon/libget-b4j) java app `libget.jar` for auto update dependencies via B4J IDE #Macro

### JDBC Drivers

| Driver | Version | Database |
|--------|---------|----------|
| sqlite-jdbc-3.7.2.jar | 3.7.2 | SQLite |
| mysql-connector-j-9.3.0.jar | 9.3.0 | MySQL |
| mariadb-java-client-3.5.6.jar | 3.5.6 | MariaDB |

### Frontend (CDN-loaded)

| Library | Version | Used In |
|---------|---------|---------|
| Bootstrap | 5.3.8 | All pages |
| Bootstrap Icons | 1.13.1 | All pages |
| HTMX | 2.0.8 | Web UI pages |
| AlpineJS | 3.15.8 | API documentation page |

---

## Project Structure

```
pakai-server-b4j/
├── README.md
├── LICENSE                      # MIT License
├── pakai-index.png              # Preview image
├── release/                     # Compiled b4xtemplate files
│   ├── Pakai Server (6.99).b4xtemplate
│   ├── Pakai Server Api (6.99).b4xtemplate
│   └── Pakai Server Web (6.99).b4xtemplate
└── source/
    ├── Pakai-Server.b4j         # Full stack project file
    ├── Pakai-Server-Api.b4j     # API-only project file
    ├── Pakai-Server-Web.b4j     # Web-only project file
    ├── $APPNAME$.b4j            # Template placeholder
    ├── libs.json                # Library dependency definitions
    ├── res.json                 # External resource URLs
    ├── ORM.bas                  # Database initialization
    ├── MainView.bas             # Main page layout
    ├── MC.bas                   # HTML caching utility
    ├── MH.bas                   # MiniHtml helper
    ├── CategoriesModel.bas      # Categories CRUD
    ├── CategoriesView.bas       # Categories HTML views
    ├── CategoriesHandler.bas    # Categories Web handler
    ├── CategoriesApiHandler.bas # Categories API handler
    ├── ProductsModel.bas        # Products CRUD
    ├── ProductsView.bas         # Products HTML views
    ├── ProductsHandler.bas      # Products Web handler
    ├── ProductsApiHandler.bas   # Products API handler
    ├── FindApiHandler.bas       # Search/filter API
    ├── HelpHandler.bas          # API documentation
    ├── HttpsFilter.bas          # SSL redirect
    └── Objects/
        ├── config.ini           # Server configuration
        ├── sqlite.ini           # SQLite settings
        ├── mariadb.ini          # MariaDB settings
        ├── keystore.jks         # SSL keystore
        ├── pakai.db             # SQLite database
        └── www/                 # Static assets
            ├── assets/css/      # Bootstrap, main.css
            ├── assets/js/       # Bootstrap, HTMX, AlpineJS, app.js
            ├── assets/img/      # favicon, sponsor images
            └── swagger/         # Swagger UI files
```

---

## Creating a New Project from Template

1. Copy the desired `.b4xtemplate` from the `release/` folder to your B4J additional libraries folder
2. In B4J IDE: **File → New → Pakai Server template**
3. Set the project name and start coding

> Use `libget.jar` to auto-download all library dependencies.  
> Use `modgen.jar` (Model Generator) to scaffold new models from your database schema.

---

## Improvement over v5.x

- Better UI/UX/DX compared to version 5.x
- More flexible model generation pipeline
- HTML generated entirely in B4X (no external templates)
- No JavaScript module required for CRUD (HTMX handles it)
- No jQuery AJAX parsing needed
- JSON/XML API with unified response format
- WebApiUtils with HelpHandler for auto-documentation
- OpenAPI 3.0 spec (Swagger UI) integration
- B4X code snippets for client-side API consumption

---

## Support

If you find this project helpful, consider supporting its development:

[![Buy me a coffee](https://github.com/pyhoon/pakai-server-b4j/blob/main/source/Objects/www/assets/img/sponsor.png)](https://paypal.me/aeric80/)

**Links:** [Forum](https://www.b4x.com/android/forum/threads/web-project-template-pakai-server-v6.169224/) | [GitHub](https://github.com/pyhoon/pakai-server-b4j) | [PayPal](https://paypal.me/aeric80/)

---

## License

MIT License — Copyright (c) 2022-2026 Poon Yip Hoon (Aeric). See `LICENSE` for details.
