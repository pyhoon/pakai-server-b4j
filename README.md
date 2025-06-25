# Pakai - Web API Server framework

Version: 5.00 beta3

Create REST API Backend using B4J project template

### Preview
![Pakai](../main/pakai.png)

---

## Template:
- Pakai.Server.5.00beta3.b4xtemplate

## Depends on:
- [EndsMeet.b4xlib](https://github.com/pyhoon/EndsMeet)
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
Sub Process_Globals
	Public app As EndsMeet
End Sub

' <link>Open in browser|http://127.0.0.1:8080</link>
Sub AppStart (Args() As String)
	app.Initialize
	app.Route("", "Index")
	app.Start
	StartMessageLoop
End Sub
```

**Support this project**

<a href="https://paypal.me/aeric80/"><img src="https://github.com/pyhoon/pakai-server-b4j/blob/main/source/Objects/www/assets/img/sponsor.png" width="174" title="Buy me a coffee" /></a>
