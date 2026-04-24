# Pakai Server

Pakai Server is a B4J (Basic4Java) web project template designed for building modern, interactive web applications and RESTful APIs. It provides a structured framework that combines the ease of B4X development with powerful web technologies.

## Project Overview

- **Purpose**: A comprehensive template for B4J web development, supporting both HTML frontends and JSON/XML APIs.
- **Architecture**: Model-View-Handler architecture.
    - **Handlers**: Process requests and generate responses (`*Handler.bas` for web, `*ApiHandler.bas` for API).
    - **Views**: Define UI layouts using `MiniHtml` DSL (`MainView.bas`).
    - **Model**: Database interaction via `MiniORM`.
- **Main Technologies**:
    - **B4J**: Backend logic and server management.
    - **EndsMeet**: Core web framework.
    - **MiniORM**: Database abstraction and ORM.
    - **MiniHtml, MiniJS, MiniCSS**: B4X libraries for programmatic generation of web assets.
    - **HTMX & AlpineJS**: Frontend interactivity and state management.
    - **Bootstrap 5**: UI styling and components.

## Directory Structure

- `Pakai-Server.b4j`: The primary B4J project file.
- `*.bas`: B4J class modules (Handlers, Views, Helpers).
    - `MainView.bas`: Shared layout and UI components.
    - `MH.bas`: Utility module for `MiniHtml` shorthand.
    - `ProductsHandler.bas`, `CategoriesHandler.bas`: Web interface handlers.
    - `*ApiHandler.bas`: REST API endpoints.
- `Files/`: Contains example configuration files (`config.example`, `sqlite.example`, etc.).
- `Objects/www/`: Static web assets (CSS, JS, images).
- `libs.json`: Tracks required B4X libraries and their versions.
- `res.json`: Tracks external web resources and assets.

## Getting Started

### Prerequisites

- [B4J IDE](https://www.b4x.com/b4j.html) installed.
- Required B4X libraries as listed in `libs.json`. These are often managed by a library manager tool or manually added to the B4J Additional Libraries folder.

### Running the Project

1.  **Configuration**: Copy `Files/config.example` to the `Objects/` directory and rename it to `config.ini`. Update the settings (port, database connection, etc.) as needed.
2.  **Open Project**: Open `Pakai-Server.b4j` in the B4J IDE.
3.  **Run**: Press **F5** (Run) in the IDE.
4.  **Access**: Open your browser and navigate to `http://127.0.0.1:8080` (or the port specified in `config.ini`).

### Building for Release

- Use the **Release** build configuration in B4J IDE.
- The project includes macros (visible in `Pakai-Server.b4j`) for packaging the application as a template or a distribution zip.

## Development Conventions

- **HTML Generation**: Prefer using `MiniHtml` (via `MH.bas` helpers) for generating HTML server-side.
- **Interactivity**: Use **HTMX** for AJAX requests and partial page updates. Use **AlpineJS** for client-side reactive behavior.
- **API Responses**: API handlers should typically return JSON or XML. Use `WebApiUtils` for consistent API response structures.
- **Database**: Use `MiniORM` for all database operations to ensure cross-database compatibility (SQLite, MySQL, MariaDB).
- **Naming**: 
    - Web handlers: `*Handler.bas`
    - API handlers: `*ApiHandler.bas`
    - View components: `*View.bas` (or within `MainView.bas`)
