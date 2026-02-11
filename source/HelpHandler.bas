B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Help Handler class
'Version 6.36
Sub Class_Globals
	Private Request As ServletRequest 'ignore
	Private Response As ServletResponse
	Private Handlers As List
	Private AllMethods As List
	Private AllGroups As Map
	Type VerbSection (Verb As String, Color As String, ElementId As String, Link As String, FileUpload As String, Authenticate As String, Description As String, Params As String, Format As String, Body As String, Expected As String, InputDisabled As Boolean, DisabledBackground As String, Raw As Boolean, Noapi As Boolean)
End Sub

Public Sub Initialize
	AllMethods.Initialize
	AllGroups.Initialize
	Handlers.Initialize
	'Handlers.Add("TokensAuthHandler")
	Handlers.Add("CategoriesApiHandler")
	Handlers.Add("ProductsApiHandler")
	Handlers.Add("FindApiHandler")
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	ShowHelpPage
End Sub

'Private Sub ShowHelpPage
'	#If Debug
'	ReadHandlers ' Read from source (optional) - comment hashtags are required
'	'BuildMethods
'	#Else
'	BuildMethods ' Build programatically
'	#End If
'
'	Dim Contents As String = GenerateHtml
'	
'	#If Debug
'	If File.Exists(File.DirApp, "help.html") = False Then
'	WebApiUtils.WriteTextFile("help.html", Contents)
'	End If
'	#Else
'	'Read from file
'	If File.Exists(File.DirApp, "help.html") Then
'		Contents = File.ReadString(File.DirApp, "help.html")
'	End If
'	#End If
'	
'	Dim strMain As String = WebApiUtils.ReadTextFile("main.html")
'	strMain = WebApiUtils.BuildDocView(strMain, Contents)
'	
'	#Region CSRF TOKEN
'	' Store csrf_token inside server session variables
'	'Dim HSR As HashGenerator
'	'HSR.Initialize
'	'Dim csrf_token As String = HSR.RandomHash2
'	'Request.GetSession.SetAttribute(Main.PREFIX & "csrf_token", csrf_token)
'	' Append csrf_token into page header. Comment this line to check
'	'strMain = WebApiUtils.BuildCsrfToken(strMain, csrf_token)
'	#End Region
'	
'	strMain = WebApiUtils.BuildTag(strMain, "HELP", "") ' Hide API icon
'	strMain = WebApiUtils.BuildHtml(strMain, Main.app.ctx)
'	strMain = WebApiUtils.BuildScript(strMain, $"<script src="${Main.app.ServerUrl}/assets/scripts/help.js"></script>"$)
'	WebApiUtils.ReturnHtml(strMain, Response)
'End Sub

Sub Div As MiniHtml
	Return CreateTag("div")
End Sub

Sub Button As MiniHtml
	Return CreateTag("button")
End Sub

Sub Anchor As MiniHtml
	Return CreateTag("a")
End Sub

Sub Icon As MiniHtml
	Return CreateTag("i")
End Sub

Sub Input As MiniHtml
	Return CreateTag("input")
End Sub

Sub Meta As MiniHtml
	Return CreateTag("meta")
End Sub

Sub Span As MiniHtml
	Return CreateTag("span")
End Sub

Sub CreateTag (Name As String) As MiniHtml
	Dim tag1 As MiniHtml
	tag1.Initialize(Name)
	Return tag1
End Sub

Private Sub ShowHelpPage
	#If Debug
	ReadHandlers ' Read from source (optional) - comment hashtags are required
	BuildMethods ' Build page programatically
	'Dim strMain As String = WebApiUtils.ReadTextFile("help.html")
	'Dim Contents As String = GenerateHtml
	Dim strMain As String = GenerateHtml
	'strMain = WebApiUtils.BuildDocView(strMain, Contents)
	strMain = WebApiUtils.BuildTag(strMain, "HELP", "") ' Hide API icon
	strMain = WebApiUtils.BuildHtml(strMain, Main.app.ctx)
	'strMain = WebApiUtils.BuildScript(strMain, $"<script src="${Main.app.ServerUrl}/assets/scripts/help.js"></script>"$)	
	'WebApiUtils.WriteTextFile("help.html", strMain)
	File.WriteString(File.DirApp, "help.html", strMain)
	'File.WriteString(Main.App.staticfiles.Folder, "help.html", strMain)
	#Else
	Dim strMain As String = File.ReadString(File.DirApp, "help.html")
	'Dim strMain As String = File.ReadString(Main.App.staticfiles.Folder, "help.html")
	#End If
	WebApiUtils.ReturnHtml(strMain, Response)
End Sub

Private Sub GenerateHtml As String 'ignore
	Dim html1 As MiniHtml = CreateTag("html")
	html1.lang("en")
	html1.multiline
	Dim head1 As MiniHtml = CreateTag("head").up(html1)
	head1.multiline
	Dim meta1 As MiniHtml = Meta.up(head1)
	meta1.attr("http-equiv", "content-type")
	meta1.attr("content", "text/html; charset=utf-8")
	Dim meta2 As MiniHtml = Meta.up(head1)
	meta2.attr("name", "viewport")
	meta2.attr("content", "width=device-width, initial-scale=1")
	Dim meta3 As MiniHtml = Meta.up(head1)
	meta3.attr("name", "csrf-token")
	Dim meta4 As MiniHtml = Meta.up(head1)
	meta4.attr("name", "description")
	Dim meta5 As MiniHtml = Meta.up(head1)
	meta5.attr("name", "author")
	Dim title1 As MiniHtml = CreateTag("title").up(head1)
	title1.text("API Documentation")
	Dim link1 As MiniHtml = CreateTag("link").up(head1)
	link1.attr("rel", "icon")
	link1.attr("type", "image/png")
	#If Bundle
	link1.attr("href", "/assets/img/favicon.png")
	head1.cdn2("style", "/assets/css/bootstrap.min.css", "", "")
	head1.cdn2("style", "/assets/css/bootstrap-icons.min.css", "", "")
	#Else
	link1.attr("href", "$SERVER_URL$/assets/img/favicon.png")
	head1.cdn("style", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css", _
	"sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB")
	head1.cdn("style", "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css", "")
	#End If

	Dim css1 As MiniCss
	css1.Initialize(Me)
	'css1.IndentSize = 2
	css1.SetStartIndent("    ")
	
	Dim cb1 As MiniCssBuilder
	cb1.Initialize(css1)
	' Using builder pattern (fluent syntax)
    cb1.Rule(".accordion")
	cb1.Property("--bs-accordion-border-width", "none")
    
	cb1.Rule(".accordion-button:focus")
	cb1.Property("box-shadow", "none")
	
	cb1.Rule(".accordion-body")
	cb1.Property("color", "white")
	'cb1.Property("background", "#393939")
	cb1.Property("background", "#636363")

	cb1.Rule(".accordion-button-green")
	cb1.ParseRaw("color: #fff;background: #16a34a;box-shadow: none;")
	
	cb1.ParseRawWithRules(".accordion-button-green:not(.collapsed)", _
	"color: #fff;background: #16a34a;")
	
	cb1.Rule(".accordion-button-purple")
	cb1.ParseRaw("color: #fff;background: #9333ea;box-shadow: none;")
	
	cb1.ParseRawWithRules(".accordion-button-purple:not(.collapsed)", _
	"color: #fff;background: #9333ea;")
	
	cb1.Rule(".accordion-button-blue")
	cb1.ParseRaw("color: #fff;background: #2563eb;box-shadow: none;")
	
	cb1.ParseRawWithRules(".accordion-button-blue:not(.collapsed)", _
	"color: #fff;background: #2563eb;")
	
	cb1.Rule(".accordion-button-red")
	cb1.ParseRaw("color: #fff;background: #dc2626;box-shadow: none;")
	
	cb1.ParseRawWithRules(".accordion-button-red:not(.collapsed)", _
	"color: #fff;background: #dc2626;")
	
	cb1.ParseRawWithRules(".accordion-button::after", _
	$"background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='white' class='bi bi-plus' viewBox='0 0 16 16'%3E%3Cpath d='M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z'/%3E%3C/svg%3E");
    transition: all 0.5s;"$)
	
	cb1.ParseRawWithRules(".accordion-button:not(.collapsed)::after", _
	$"background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='white' class='bi bi-dash' viewBox='0 0 16 16'%3E%3Cpath d='M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z'/%3E%3C/svg%3E");"$)

	cb1.Rule(".submit-button")
	cb1.Property("background-color", "#ccc")
	
	cb1.Rule(".submit-button-green")
	cb1.Property("background-color", "#16a34a")
	cb1.Property("border-color", "#14532d")

	cb1.Rule(".badge-green")
	cb1.Property("background-color", "#bbf7d0")

	cb1.Rule(".badge-purple")
	cb1.Property("background-color", "#e9d5ff")

	cb1.Rule(".badge-blue")
	cb1.Property("background-color", "#bfdbfe")

	cb1.Rule(".badge-red")
	cb1.Property("background-color", "#fecaca")
	
	cb1.Rule(".yellow")
	cb1.Property("background-color", "#f7d600 !important")
	
	cb1.Rule(".pill-yellow")
	cb1.Property("background-color", "#fde047")
	
	cb1.Rule(".pill-yellow-text")
	cb1.Property("color", "#854d0e")
	
	'cb1.ParseRawWithRules(".navbar-toggler-icon .custom-toggler-icon", _
	'$"background-image: url("data:image/svg+xml;charset=utf8,%3Csvg viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='rgba(0,0,0,0.9)' stroke-width='2' stroke-linecap='round' stroke-miterlimit='10' d='M4 8h24M4 16h24M4 24h24'/%3E%3C/svg%3E");"$)
	
	Dim sty1 As MiniHtml = CreateTag("style").up(head1)
	sty1.text(css1.GenerateCSS)
	'sty1.multiline
	'Log(sty1.build)
	
	Dim body1 As MiniHtml = CreateTag("body").up(html1)
	body1.cls("bg-dark text-light")
	body1.multiline
	
	'Dim nav1 As MiniHtml = CreateTag("nav").up(body1).cls("navbar navbar-light navbar-expand-lg sticky-top bg-info")
	'Dim div1 As MiniHtml = Div.up(nav1).cls("container-fluid")
	'Dim a1 As MiniHtml = CreateTag("a").up(div1)
	'a1.cls("navbar-brand me-0 me-lg-2 pt-2")
	'a1.attr("href", "#")
	'Dim i1 As MiniHtml = CreateTag("i").up(a1)
	'i1.cls("bi bi-infinity h3")
	'Dim a2 As MiniHtml = CreateTag("a").up(div1)
	'a2.cls("navbar-brand")
	'a2.attr("href", "$SERVER_URL$")
	'a2.text("$APP_TRADEMARK$")
	'Dim toggler1 As MiniHtml = Button.up(div1)
	'toggler1.cls("navbar-toggler d-md-block d-lg-none collapsed")
	'toggler1.attr("type", "button")
	'toggler1.attr("data-bs-toggle", "collapse")
	'toggler1.attr("data-bs-target", "#navbarCollapse")
	'toggler1.sty("border: none")
	'Dim span1 As MiniHtml = Span.up(toggler1)
	'span1.cls("navbar-toggler-icon")
	
	Dim nav1 As MiniHtml = CreateTag("nav").up(body1)
	nav1.cls("navbar navbar-light navbar-expand-lg sticky-top py-1")
	nav1.sty("background-color: yellow")
	nav1.multiline
	
	Dim div1 As MiniHtml = Div.up(nav1)
	div1.cls("container-fluid")
	
	Dim a1 As MiniHtml = Anchor.up(div1)
	a1.cls("navbar-brand me-0 me-lg-2")
	a1.attr("href", "#")
	Dim i1 As MiniHtml = Icon.up(a1)
	i1.cls("bi bi-gear h3 ms-3")
	Dim a2 As MiniHtml = Anchor.up(div1)
	a2.cls("navbar-brand font-weight-bold")
	a2.attr("href", "#")
	a2.text("API Documentation")
	
	Dim toggler1 As MiniHtml = Button.up(div1)
	toggler1.cls("navbar-toggler d-md-block d-lg-none collapsed")
	toggler1.attr("type", "button")
	toggler1.attr("data-bs-toggle", "collapse")
	toggler1.attr("data-bs-target", "#navbarCollapse")
	toggler1.sty("border: none")
	Dim span1 As MiniHtml = Span.up(toggler1)
	span1.cls("navbar-toggler-icon")
	
	
'	Dim button1 As MiniHtml = Button.up(div1)
'	button1.cls("navbar-toggler d-md-block d-lg-none collapsed")
'	button1.attr("type", "button")
'	button1.attr("data-toggle", "collapse")
'	button1.attr("data-target", "#navbarCollapse")
'	button1.sty("border: none")
'	button1.FormatAttributes = True
'	button1.multiline
'	Dim span1 As MiniHtml = Span.up(button1)
'	span1.cls("navbar-toggler-icon")
	
	Dim div2 As MiniHtml = Div.up(div1)
	div2.cls("collapse navbar-collapse")
	div2.attr("id", "navbarCollapse")
	div2.multiline
	Dim ul1 As MiniHtml = CreateTag("ul").up(div2)
	ul1.cls("navbar-nav navbar-brand ms-auto mb-md-0")
	ul1.multiline
	'ul1.text("@HELP@")
	
	'Dim list0 As MiniHtml = CreateTag("li").up(ul1)
	'list0.cls("nav-item d-block d-lg-block")
	'Dim a0 As MiniHtml = CreateTag("a").up(list0)
	'a0.attr("href", "/files")
	'a0.cls("nav-link text-dark ms-3 p-0")
	'a0.text("Files")
	'Dim i0 As MiniHtml = CreateTag("i").up(a0)
	'i0.cls("bi bi-files mr-2")
	
	Dim li1 As MiniHtml = CreateTag("li").up(ul1)
	li1.cls("nav-item d-none d-sm-none d-md-block")
	li1.multiline
	Dim a3 As MiniHtml = Anchor.up(li1)
	a3.attr("href", "https://paypal.me/aeric80/")
	a3.attr("target", "_blank")
	Dim img1 As MiniHtml = CreateTag("img").up(a3)
	img1.attr("src", "/assets/img/coffee.png")
	'img1.cls("ms-2 mt-1")
	img1.cls("my-1")
	img1.sty("height: 36px")
	
	Dim li2 As MiniHtml = CreateTag("li").up(ul1)
	li2.cls("nav-item d-block d-lg-block")
	Dim a5 As MiniHtml = Anchor.up(li2)
	a5.text("Home")
	a5.attr("href", "/")
	a5.cls("nav-link text-dark float-end")
	Dim i2 As MiniHtml = Icon.up(a5)
	i2.cls("bi bi-house me-2")
	i2.attr("title", "Home")
	
	Dim div2 As MiniHtml = Div.up(body1)
	div2.cls("text-center font-weight-bold d-block d-sm-block d-md-none")
	div2.sty("background-color: whitesmoke")
	div2.multiline
	Dim a4 As MiniHtml = Anchor.up(div2)
	a4.attr("href", "https://paypal.me/aeric80/")
	a4.attr("target", "_blank")
	Dim img2 As MiniHtml = CreateTag("img").up(a4)
	img2.attr("src", "/assets/img/sponsor.png")
	img2.cls("mx-2")
	img2.sty("width: 174px")
	
	Dim div3 As MiniHtml = Div.up(body1)
	div3.cls("content m-3")
	div3.multiline
	Dim div4 As MiniHtml = Div.up(div3)
	div4.cls("p-2")
	div4.multiline
	Dim div5 As MiniHtml = Div.up(div4)
	div5.cls("row text-center text-light align-items-center justify-content-center")
	'div5.multiline
	
	'Dim div6 As MiniHtml = Div.up(div5)
	'div6.cls("mx-3")
	'div6.multiline
	'Dim img3 As MiniHtml = CreateTag("img").up(div6)
	'img3.attr("src", "$SERVER_URL$/assets/img/loading.webp")
	'img3.attr("width", "60px")
	'img3.attr("height", "60px")
	'Dim div7 As MiniHtml = Div.up(div5)
	'div7.multiline
	Dim h31 As MiniHtml = CreateTag("h3").up(div5)
	h31.cls("mb-0")
	h31.sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;")
	h31.text("$HOME_TITLE$")
	Dim span2 As MiniHtml = Span.up(div5)
	span2.cls("small")
	span2.text("Version: $VERSION$")
	'div4.text("@DOCVIEW@")
	
	For Each method As Map In AllMethods ' Avoid duplicate groups
		AllGroups.Put(method.Get("Group"), "unused")
	Next
	'Dim SB As StringBuilder
	'SB.Initialize
	For Each GroupName As String In AllGroups.Keys
		'SB.Append(GenerateHeaderByGroup(GroupName))
		Dim AcordionGroup As MiniHtml = GenerateHeaderByGroup(GroupName)
		AcordionGroup.up(div4)
		
		Dim div1 As MiniHtml = Div.up(AcordionGroup)
		div1.cls("accordion")
		'div1.attr("id", $"accordion${section.ElementId}"$) '"accordionPanelsStayOpenExample"
		div1.multiline
		For Each method As Map In AllMethods
			If method.Get("Group") = GroupName Then
				If method.ContainsKey("Hide") = False Then ' Skip Hidden sub
					'SB.Append(GenerateDocItem(method))
					'GenerateDocItem(method)
					Dim section As VerbSection = GenerateVerbSection(method)
					GenerateAccordion(section).up(div1)
				End If
			End If
		Next
	Next
	'div4.text(SB.ToString)
	
	Dim div8 As MiniHtml = Div.up(body1)
	div8.cls("bottom")
	Dim footer1 As MiniHtml = CreateTag("footer").up(body1)
	footer1.cls("footer footer-dark bg-secondary pl-4 pt-2 pb-2")
	footer1.multiline
	Dim div9 As MiniHtml = Div.up(footer1)
	div9.cls("footer small text-secondark text-center d-md-block")
	div9.sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;")
	div9.multiline
	Dim caption1 As MiniHtml = CreateTag("caption").up(div9)
	caption1.multiline
	caption1.text("$APP_COPYRIGHT$")
	CreateTag("br").up(caption1)
	caption1.text("Pakai with")
	Dim span3 As MiniHtml = Span.up(caption1)
	span3.sty("color: red")
	span3.text("❤")
	caption1.text("in B4X")
	#If Bundle
	body1.cdn2("script", "/assets/js/bootstrap.min.js", "", "")
	body1.cdn2("script", "/assets/js/htmx.min.js", "", "")
	#Else
	body1.cdn("script", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js", _
	"sha384-G/EV+4j2dNv+tEPo3++6LCgdCROaejBqfUeNjuKAiuXbjrxilcCdDz6ZAVfHWe1Y")
	body1.cdn("script", "https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js", _
	"sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz")
	#End If

	Dim script1 As String = AddEventListener("htmx:configRequest", "btn")
	'Log(script1)
	CreateTag("script").up(body1).text(script1.SubString2(0, script1.LastIndexOf(CRLF))).multiline
	
	Dim doc As MiniHtml
	doc.Initialize("")
	doc.Write("<!DOCTYPE html>")
	doc.Write(html1.build)
	Return doc.ToString
End Sub

Private Sub FindMethod (MethodName As String) As Int
	For i = 0 To AllMethods.Size - 1
		Dim Method As Map = AllMethods.Get(i)
		If Method.Get("Method") = MethodName Then
			'Log(Method.Get("Method"))
			Return i
		End If
	Next
	Return -1
End Sub

Private Sub RetrieveMethod (GroupName As String, MethodLine As String) As Map
	Dim index As Int = FindMethod(ExtractMethod(MethodLine))
	If index > -1 Then
		Return AllMethods.Get(index)
	Else
		Return CreateMethodProperties(GroupName, MethodLine)
	End If
End Sub

' Use this sub if you are calling BuildMethods after calling ReadHandlers in Debug to override method properties
' Order in list is preserved
Private Sub ReplaceMethod (Method As Map)
	' Replacement will failed if the Method name cannot be found
	Dim index As Int = FindMethod(Method.Get("Method"))
	If index > -1 Then
		AllMethods.RemoveAt(index)
		AllMethods.InsertAt(index, Method)
	Else
		AllMethods.Add(Method)
	End If
End Sub

Private Sub RemoveMethodAndReAdd (Method As Map)
	Dim index As Int = FindMethod(Method.Get("Method"))
	If index > -1 Then
		AllMethods.RemoveAt(index)
	End If
	AllMethods.Add(Method) ' Add at the end of list
End Sub

Private Sub BuildMethods 'ignore
	Dim Method As Map = RetrieveMethod("Categories", "GetCategories")
	Method.Put("Desc", "List All Categories")
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Categories", "GetCategoryById (id As Int)")
	Method.Put("Desc", "Read one Category by id")
	Method.Put("Elements", $"["{id}"]"$)
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Categories", "CreateNewCategory '#POST")
	Method.Put("Desc", "Add new Category")
	Dim FormatMap As Map = CreateMap("category_name": "category_name")
	Method.Put("Format", FormatMap.As(JSON).ToString)
	Method.Put("Body", FormatMap.As(JSON).ToString)
	ReplaceMethod(Method)

	Dim Method As Map = RetrieveMethod("Categories", "UpdateCategoryById (id As Int) '#PUT")
	Method.Put("Desc", "Update Category by id")
	Method.Put("Elements", $"["{id}"]"$)	
	Dim FormatMap As Map = CreateMap("category_name": "category_name")
	Method.Put("Format", FormatMap.As(JSON).ToString)
	Method.Put("Body", FormatMap.As(JSON).ToString)
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Categories", "DeleteCategoryById (id As Int)")
	Method.Put("Desc", "Delete Category by id")
	Method.Put("Elements", $"["{id}"]"$)
	'Method.Put("Authenticate", "token")
	RemoveMethodAndReAdd(Method)
	
	Dim Method As Map = RetrieveMethod("Products", "GetProducts")
	Method.Put("Desc", "Read all Products")
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Products", "GetProductById (id As Int)")
	Method.Put("Desc", "Read one Product by id")
	Method.Put("Elements", $"["{id}"]"$)
	ReplaceMethod(Method)
	
	Dim Method As Map = CreateMethodProperties("Products", "PostProduct")
	Method.Put("Desc", "Add new Product")
	Dim Format As String = $"{
  "category_id": 1,
  "product_code": "CODE",
  "product_name": "ProductName",
  "product_price": 0
}"$
	Dim Body As String = $"{
  "category_id": 1,
  "product_code": "",
  "product_name": "",
  "product_price": 0
}"$
	Method.Put("Format", Format)
	Method.Put("Body", Body)
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Products", "PutProductById (id As Int)")
	Method.Put("Desc", "Update Product by id")
	Dim Format As String = $"{
  "category_id": 1,
  "product_code": "CODE",
  "product_name": "ProductName",
  "product_price": 10
}"$
	Dim Body As String = $"{
  "category_id": 1,
  "product_code": "",
  "product_name": "",
  "product_price": 0
}"$
	Method.Put("Format", Format)
	Method.Put("Body", Body)
	Method.Put("Elements", $"["{id}"]"$)
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Products", "DeleteProductById (id As Int)")
	Method.Put("Desc", "Delete Product by id")
	Method.Put("Elements", $"["{id}"]"$)
	ReplaceMethod(Method)
	
	
	Dim Method As Map = RetrieveMethod("Find", "GetAllProducts")
	Method.Put("Desc", "Get all Products (with Category name)")
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Find", "GetProductsByCategoryId")
	Method.Put("Desc", "Filter Products (with Category Id)")
	ReplaceMethod(Method)
	
	Dim Method As Map = RetrieveMethod("Find", "SearchByKeywords ' #post")
	'Dim BodyMap As Map = CreateMap("keywords": "search words")
	'Method.Put("Body", BodyMap.As(JSON).ToString)
	Dim FormatMap As Map = CreateMap("keyword": "text")
	Dim BodytMap As Map = CreateMap("keyword": "")
	Method.Put("Format", FormatMap.As(JSON).ToString)
	Method.Put("Body", BodytMap.As(JSON).ToString)
	
	Method.Put("Desc", "Filter Products (with Category name)")
	Dim Expected As StringBuilder
	Expected.Initialize
	Expected.Append("200 Success")
	Expected.Append("<br/>400 Bad Request")
	Expected.Append("<br/>404 Not found")
	Expected.Append("<br/>422 Error execute query")
	Method.Put("Expected", Expected.ToString)
	ReplaceMethod(Method)
End Sub

Private Sub ReadHandlers 'ignore
	Dim verbs() As String = Array As String("GET", "POST", "PUT", "DELETE")
	For Each Handler As String In Handlers
		Dim Methods As List
		Methods.Initialize
		Dim Group As String = Handler.Replace("Handler", "").Replace("Api", "").Replace("Web", "").Replace("Auth", "")
		Dim lines As List = File.ReadList(File.DirApp.Replace("\Objects", ""), Handler & ".bas")
		For Each line As String In lines
			If line.StartsWith("'") Or line.StartsWith("#") Then Continue
			Dim index As Int = line.toLowerCase.IndexOf("sub ")
			If index > -1 Then
				Dim MethodLine As String = line.SubString(index).Replace("Sub ", "").Trim
				For Each verb As String In verbs
					If MethodLine.ToUpperCase.StartsWith(verb) Or MethodLine.ToUpperCase.Contains("#" & verb) Then
						'RemoveComment(MethodLine)
						Dim Method As Map = CreateMethodProperties(Group, MethodLine)
						Methods.Add(Method)
						AllMethods.Add(Method)
					End If
				Next
			Else
				If line.Contains("'") And line.Contains("#") Then
					' Detect commented hashtags inside Handler
					ParseHashtags(line, Methods)
				End If
			End If
		Next
		'' Retain this part for debugging purpose
		'#If DEBUG
		'For Each m As Map In Methods
		'	Log(" ")
		'	Log("[" & m.Get("Verb") & "]")
		'	Log("Method: " & m.Get("Method"))
		'	'Dim MM(2) As String
		'	'MM = Regex.Split(" As ", m.Get("Method")) ' Ignore return type
		'	'Log("Sub Name: " & MM(0).Trim)
		'	Log("Params: " & m.Get("Params"))
		'	Log("Hide: " & m.Get("Hide"))
		'	Log("Plural: " & m.Get("Plural"))
		'	Log("Elements: " & m.Get("Elements"))
		'	Log("Version: " & m.Get("Version"))
		'	Log("Format: " & m.Get("Format"))
		'	Log("Desc: " & m.Get("Desc"))
		'Next
		'#End If
	Next
End Sub

Private Sub ParseHashtags (lineContent As String, methodList As List)
	' =====================================================================
	' Detect commented hashtags inside Handler
	' =====================================================================
	' CAUTION: Do not use commented hashtag keyword inside non-verb subs!
	' =====================================================================
	' Supported hashtag keywords: (case-insensitive)
	' #name (formerly #plural)
	' #version
	' #desc
	' #body
	' #elements
	' #format  (formerly #defaultformat)
	' #upload
	' #authenticate
	'
	' Single keywords:
	' #hide
	' #noapi
	Dim HashTags1() As String = Array As String("Hide", "Noapi")
	Dim HashTags2() As String = Array As String("Version", "Desc", "Elements", "Body", "Group", "Upload", "Authenticate", "Format")
	
	For Each Tag As String In HashTags1
		If lineContent.ToLowerCase.IndexOf("#" & Tag.ToLowerCase) > -1 Then
			Dim lastMethod As Map = methodList.Get(methodList.Size - 1)
			lastMethod.Put(Tag, True)
		End If
	Next
	For Each Tag As String In HashTags2
		If lineContent.ToLowerCase.IndexOf("#" & Tag.ToLowerCase) > -1 Then
			Dim str() As String = Regex.Split("=", lineContent)
			'If str.Length = 2 Then
			'	Dim lastMethod As Map = methodList.Get(methodList.Size - 1)
			'	lastMethod.Put(Tag, str(1).Trim)
			'End If
			If str.Length > 1 Then ' bug Desc contains equal sign
				Dim lastMethod As Map = methodList.Get(methodList.Size - 1)
				lastMethod.Put(Tag, lineContent.SubString(lineContent.IndexOf("=") + 1).Trim)
			End If
		End If
	Next
End Sub

Private Sub RemoveComment (Line As String) As String
	' Clean up comment on the right of a sub
	If Line.Contains("'") Then
		Line = Line.SubString2(0, Line.IndexOf("'"))
	End If
	Return Line
End Sub

Private Sub RemoveReturnType (Line As String) As String
	' Clean up As type on the right of a sub
	If Line.ToLowerCase.Contains(" as ") Then
		Dim index As Int = Line.ToLowerCase.IndexOf(" as ")
		Line = Line.SubString2(0, index)
	End If
	Return Line
End Sub

Private Sub CreateMethodProperties (groupName As String, methodLine As String) As Map
	Dim methodProps As Map
	methodProps.Initialize
	methodProps.Put("Group", groupName)
	methodProps.Put("Method", ExtractMethod(methodLine))
	methodProps.Put("Desc", methodProps.Get("Method"))
	methodProps.Put("Verb", ExtractVerb(methodLine))
	methodProps.Put("Params", ExtractParams(methodLine))
	methodProps.Put("Format", "&nbsp;")
	methodProps.Put("Body", "")
	methodProps.Put("Noapi", False)
	methodProps.Put("Format", "")
	Return methodProps
End Sub

Private Sub ExtractMethod (methodLine As String) As String
	' Take the method name only without arguments
	methodLine = RemoveComment(methodLine)
	methodLine = RemoveReturnType(methodLine)
	Dim index As Int = methodLine.IndexOf("(")
	If index > -1 Then
		Return methodLine.SubString2(0, index).Trim
	Else
		Return methodLine.Trim
	End If
End Sub

Private Sub ExtractVerb (methodLine As String) As String
	' Determine the HTTP verb based on the method name
	Dim MethodVerb As String
	If methodLine.ToUpperCase.StartsWith("GET") Then
		MethodVerb = "GET"
	Else If methodLine.ToUpperCase.StartsWith("POST") Then
		MethodVerb = "POST"
	Else If methodLine.ToUpperCase.StartsWith("PUT") Then
		MethodVerb = "PUT"
	Else If methodLine.ToUpperCase.StartsWith("DELETE") Then
		MethodVerb = "DELETE"
	End If
	' Override if #hashtag comment exists
	Select True
		Case methodLine.ToUpperCase.Contains("#GET")
			MethodVerb = "GET"
		Case methodLine.ToUpperCase.Contains("#POST")
			MethodVerb = "POST"
		Case methodLine.ToUpperCase.Contains("#PUT")
			MethodVerb = "PUT"
		Case methodLine.ToUpperCase.Contains("#DELETE")
			MethodVerb = "DELETE"
	End Select
	Return MethodVerb
End Sub

Private Sub ExtractParams (methodLine As String) As String
	' Extract method parameters if any
	Dim indexBegin As Int = methodLine.IndexOf("(")
	'Dim indexEnd As Int = methodLine.LastIndexOf(")") ' comment can contains close parentheses
	Dim indexEnd As Int = methodLine.IndexOf(")")
	Dim params As StringBuilder
	params.Initialize
	If indexBegin > -1 Then
		Dim args As String = methodLine.SubString2(indexBegin + 1, indexEnd)
		Dim prm() As String = Regex.Split(",", args)
		For i = 0 To prm.Length - 1
			If i > 0 Then params.Append(CRLF)
			Dim pm() As String = Regex.Split(" As ", prm(i))
			params.Append(pm(0).Trim).Append(" [").Append(pm(1).Trim).Append("]")
		Next
	Else
		params.Append("Not required")
	End If
	Return params.ToString
End Sub

Private Sub GenerateLink (ApiVersion As String, Handler As String, Elements As List) As String
	Dim Link As String = "$SERVER_URL$/" & Main.Api.Name
	If Link.EndsWith("/") = False Then Link = Link & "/"
	If ApiVersion.EqualsIgnoreCase("null") = False Then
		If Main.Api.Versioning Then Link = Link & ApiVersion
		If Link.EndsWith("/") = False Then Link = Link & "/"
	End If
	Link = Link & Handler.ToLowerCase
	If Elements.IsInitialized Then
		For i = 0 To Elements.Size - 1
			Link = Link & "/" & Elements.Get(i)
		Next
	End If
	Return Link
End Sub

Private Sub GenerateNoApiLink (Handler As String, Elements As List) As String
	Dim Link As String = "$SERVER_URL$/" & Handler.ToLowerCase
	If Elements.IsInitialized Then
		For i = 0 To Elements.Size - 1
			Link = Link & "/" & Elements.Get(i)
		Next
	End If
	Return Link
End Sub

'Private Sub GenerateVerbSection2 (section As VerbSection) As String
'	Select section.FileUpload
'		Case "Image", "PDF"
'			Dim strBodyInput As String = $"<p><strong>File:</strong> <label for="file1${section.ElementId}">Choose a file:</label><input type="file" id="file1${section.ElementId}" class="pb-3" name="file1"></p>"$
'		Case Else
'			Dim strBodySample As String = $"<p><strong>Format:</strong> <span class="form-control" style="background-color: #636363; color: white; height: fit-content; vertical-align: text-top; font-size: small">${section.Format}</span></p>"$
'			Dim strBodyInput As String = $"<p><strong>Body:</strong> <textarea id="body${section.ElementId}" rows="6" class="form-control data-body" style="background-color: #363636; color: white; font-size: small">${section.Body}</textarea></p>"$
'	End Select
'	Return $"
'        <!--<button class="collapsible collapsible-background-${section.Color}"><span style="width: 60px" class="badge badge-${section.Color} text-dark py-1 mr-1">${section.Verb}</span>-->
'        <button class="collapsible collapsible-background-${section.Color}" data-bs-toggle="collapse"><span style="width: 60px" class="badge badge-${section.Color} text-dark py-1 mr-1">${section.Verb}</span>
'		${IIf(section.Authenticate.EqualsIgnoreCase("Basic") Or _
'			section.Authenticate.EqualsIgnoreCase("ApiKey") Or _
'			section.Authenticate.EqualsIgnoreCase("Token"), _
'			$"<span style="width: 50px" class="badge rounded-pill pill-yellow pill-yellow-text px-2 py-1">${WebApiUtils.ProperCase(section.Authenticate)}</span>"$, "")}<span class="ms-1">${section.Description}</span>
'		</button>
'        <div class="details mb-1">
'            <div class="row">
'                <div class="col-md-3 p-3">
'                    <p><strong>Parameters</strong><br/>
'                    <label class="col control-label border rounded" style="padding-top: 5px; padding-bottom: 5px; font-size: small; white-space: pre-wrap;">${section.Params}</label></p>
'                    ${IIf(section.Verb.EqualsIgnoreCase("POST") Or section.Verb.EqualsIgnoreCase("PUT"), strBodySample, "")}
'                    <div class="mt-3"><strong>Status Code</strong><br/>
'                    ${section.Expected}</div>
'                </div>
'	            <div class="col-md-3 p-3">
'					<form method="${section.Verb}">
'					<p><strong>Path</strong><br/>
'	                <input${IIf(section.InputDisabled, " disabled", "")} id="path${section.ElementId}" class="form-control data-path text-light" style="background-color: ${section.DisabledBackground}; font-size: small" value="${section.Link & IIf(section.Raw, "?format=json", "")}"></p>
'					${IIf(section.Verb.EqualsIgnoreCase("POST") Or section.Verb.EqualsIgnoreCase("PUT"), strBodyInput, $""$)}
'					<button id="btn${section.ElementId}" class="${IIf(section.FileUpload.EqualsIgnoreCase("Image") Or section.FileUpload.EqualsIgnoreCase("PDF"), $"file"$, $"${section.Verb.ToLowerCase}"$)}${IIf(section.Authenticate.ToUpperCase = "BASIC" Or section.Authenticate.ToUpperCase = "TOKEN", " " & section.Authenticate.ToLowerCase, "")} button submit-button-${section.Color} text-white col-md-6 col-lg-4 p-2 float-right" style="cursor: pointer; padding-bottom: 60px"><strong>Submit</strong></button>
'	            	</form>
'				</div>
'                <div class="col-md-6 p-3">
'                    <p><strong>Response</strong><br/>
'                    <textarea rows="10" id="response${section.ElementId}" class="form-control" style="background-color: #363636; color: white; font-size: small"></textarea></p>
'                    <div id="alert${section.ElementId}" class="alert text-light" role="alert" style="display: block"></div>
'                </div>
'            </div>
'        </div>"$
'End Sub

Private Sub GenerateVerbSection (Props As Map) As VerbSection
	Dim section As VerbSection
	section.Initialize
	section.Verb = Props.Get("Verb")
	section.Color = GetColorForVerb(section.Verb)
	section.ElementId = Props.Get("Method")
	section.Noapi = Props.Get("Noapi")
	Dim Elements As List
	If Props.ContainsKey("Elements") Then
		Elements = Props.Get("Elements").As(JSON).ToList
	End If
	If section.Noapi Then
		section.Link = GenerateNoApiLink(Props.Get("Group"), Elements)
	Else
		section.Link = GenerateLink(Props.Get("Version"), Props.Get("Group"), Elements)
	End If
	section.Authenticate = Props.Get("Authenticate")
	section.Description = Props.Get("Desc")
	section.Params = Props.Get("Params")
	section.Format = Props.Get("Format")
	section.Format = section.Format.Replace(CRLF, "<br>")	' convert to html
	section.Format = section.Format.Replace("  ", "&nbsp;")	' convert to html
	section.Body = Props.Get("Body")
	'section.Body = section.Body.Replace(CRLF, "<br>")		' convert to html
	'section.Body = section.Body.Replace("  ", "&nbsp;")	' convert to html
	section.Expected = IIf(Props.ContainsKey("Expected"), Props.Get("Expected"), GetExpectedResponse(section.Verb))
	If section.Params.EqualsIgnoreCase("Not required") Then
		section.InputDisabled = True
		section.DisabledBackground = "#696969"
	Else
		section.DisabledBackground = "#363636"
	End If
	Return section
End Sub

Private Sub UseAuthenticate (Name As String) As Boolean
	Dim DbArray() As String = Array As String("Basic", "ApiKey", "Token")
	Return DbArray.As(List).IndexOf(Name) > -1
End Sub

Private Sub GenerateAccordion (section As VerbSection) As MiniHtml
	Dim div1 As MiniHtml = Div
	div1.cls("accordion-item")
	div1.multiline
	GenerateAccordionHead(section).up(div1)
	GenerateAccordionBody(section).up(div1)
	Return div1
End Sub

Private Sub GenerateAccordionHead (section As VerbSection) As MiniHtml
	Dim h21 As MiniHtml = CreateTag("h2")
	h21.cls("accordion-header")
	h21.attr("id", $"${section.ElementId}-heading"$) '"panelsStayOpen-headingOne"
	h21.multiline
	Dim button1 As MiniHtml = Button.up(h21)
	button1.cls("accordion-button accordion-button-" & section.Color & " bg-opacity-75 py-2 collapsed")
	button1.attr("type", "button")
	button1.attr("data-bs-toggle", "collapse")
	button1.attr("data-bs-target", $"#${section.ElementId}-collapse"$) '"#panelsStayOpen-collapseOne"
	button1.attr("aria-controls", $"${section.ElementId}-collapse"$) '"panelsStayOpen-collapseOne"
	button1.FormatAttributes = True
	button1.multiline
	Dim span1 As MiniHtml = Span.up(button1)
	span1.sty("width: 60px")
	span1.cls($"badge badge-${section.Color} text-secondary py-1 me-2"$)
	span1.text(section.Verb)
	Dim strAuthenticate As String = WebApiUtils.ProperCase(section.Authenticate)
	If UseAuthenticate(strAuthenticate) Then
		Dim span2 As MiniHtml = Span.up(button1)
		span2.sty("width: 50px")
		span2.cls($"badge rounded-pill pill-yellow pill-yellow-text px-2 py-1 me-1"$)
		span2.text(strAuthenticate)
	End If
	button1.text(section.Description)
	Return h21
End Sub

Private Sub GenerateAccordionBody (section As VerbSection) As MiniHtml
	Dim div1 As MiniHtml = Div
	div1.attr("id", $"${section.ElementId}-collapse"$) '"panelsStayOpen-collapseOne"
	div1.cls("accordion-collapse collapse")
	div1.attr("aria-labelledby", $"${section.ElementId}-heading"$) '"panelsStayOpen-headingOne"
	div1.multiline
	Dim div2 As MiniHtml = Div.up(div1)
	div2.cls("accordion-body")
	div2.multiline

	Dim div3 As MiniHtml = Div.up(div2)
	div3.cls("details mb-1")
	'div3.sty("max-height: 325px;")
	div3.multiline
	
	Dim div4 As MiniHtml = Div.up(div3)
	div4.cls("row")
	div4.multiline
	
	Dim div5 As MiniHtml = Div.up(div4)
	div5.cls("col-md-3 p-3")
	div5.multiline
	Dim p1 As MiniHtml = CreateTag("p").up(div5)
	p1.multiline
	Dim strong1 As MiniHtml = CreateTag("strong").up(p1)
	strong1.text("Parameters")
	CreateTag("br").up(p1)
	Dim label1 As MiniHtml = CreateTag("span").up(p1)
	'label1.cls("col control-label border rounded")
	'label1.sty("padding-top: 5px; padding-bottom: 5px; font-size: small; white-space: pre-wrap;")
	label1.cls("form-control")
	label1.sty("background-color: #636363; color: white; height: fit-content; vertical-align: text-top; font-size: small")
	'label1.text("Not required")
	label1.text(section.Params)

'	Dim div1 As MiniHtml = Div
'	div1.cls("details mb-1")
'	div1.multiline
'	Dim div2 As MiniHtml = Div.up(div1)
'	div2.cls("row")
'	div2.multiline
'	Dim div3 As MiniHtml = Div.up(div2)
'	div3.cls("col-md-3 p-3")
'	div3.multiline
'	Dim p1 As MiniHtml = CreateTag("p").up(div3)
'	p1.multiline
'	Dim strong1 As MiniHtml = CreateTag("strong").up(p1)
'	strong1.text("Parameters")
'	Dim br1 As MiniHtml = CreateTag("br").up(p1)
'	Dim label1 As MiniHtml = CreateTag("label").up(p1)
'	label1.cls("col control-label border rounded")
'	label1.sty("padding-top: 5px; padding-bottom: 5px; font-size: small; white-space: pre-wrap;")
'	label1.text("Not required")

	If section.Verb = "POST" Or section.Verb = "PUT" Then
		Dim p2 As MiniHtml = CreateTag("p").up(div5)
		p2.multiline
		Dim strong2 As MiniHtml = CreateTag("strong").up(p2)
		strong2.text("Format:")
		Dim span1 As MiniHtml = CreateTag("span").up(p2)
		span1.cls("form-control")
		span1.sty("background-color: #636363; color: white; height: fit-content; vertical-align: text-top; font-size: small")
		span1.multiline
		span1.text(section.Format)
	End If
	
	'Dim div4 As MiniHtml = Div.up(div3)
	'div4.cls("mt-3")
	'div4.multiline
	'Dim strong3 As MiniHtml = CreateTag("strong").up(div4)
	'strong3.text("Status Code")
	'Dim br4 As MiniHtml = CreateTag("br").up(div4)
	'div4.text("201 Created")
	'Dim br5 As MiniHtml = CreateTag("br").up(div4)
	'div4.text("400 Bad Request")
	'Dim br6 As MiniHtml = CreateTag("br").up(div4)
	'div4.text("404 Not found")
	'Dim br7 As MiniHtml = CreateTag("br").up(div4)
	'div4.text("405 Method not allowed")
	'Dim br8 As MiniHtml = CreateTag("br").up(div4)
	'div4.text("422 Error execute query")

	Dim div6 As MiniHtml = Div.up(div5)
	div6.cls("mt-3")
	div6.multiline
	Dim strong2 As MiniHtml = CreateTag("strong").up(div6)
	strong2.text("Status Code")
	CreateTag("br").up(div6) ' TODO
	div6.text("200 Success")
	CreateTag("br").up(div6)
	div6.text("400 Bad Request")
	'CreateTag("br").up(div6)
	'div6.text("404 Not found")
	'CreateTag("br").up(div6)
	'div6.text("405 Method not allowed")
	'CreateTag("br").up(div6)
	'div6.text("422 Error execute query")
	
	Dim div7 As MiniHtml = Div.up(div4)
	div7.cls("col-md-3 p-3")
	div7.multiline
	'Dim form1 As MiniHtml = CreateTag("form").up(div7)
	'form1.attr("id", "form1")
	'form1.attr("method", "POST")
	'form1.multiline
	'Dim p3 As MiniHtml = CreateTag("p").up(form1)
	Dim p3 As MiniHtml = CreateTag("p").up(div7)
	p3.multiline
	Dim strong4 As MiniHtml = CreateTag("strong").up(p3)
	strong4.text("Path")
	CreateTag("br").up(p3)
	'Dim input1 As MiniHtml = Input.up(p3)
	'input1.attr("id", "pathCreateNewCategory")
	'input1.cls("form-control data-path text-light")
	'input1.sty("background-color: #696969; font-size: small")
	'input1.attr("value", "http://127.0.0.1:8080/api/categories")
	'input1.FormatAttributes = True
	'input1.multiline
	Dim input1 As MiniHtml = Input.up(p3)
	input1.attr("id", $"${section.ElementId}-path"$)
	'input1.cls("path")
	input1.cls("path form-control data-path text-light")
	input1.sty("background-color: #696969; font-size: small")
	input1.attr("value", IIf(section.Raw, section.Link & "?format=json", section.Link))
	'input1.attr("onkeyup", $"document.getElementById('btn${section.ElementId}').setAttribute('hx-get', this.value)"$)
	If section.InputDisabled Then input1.disabled
	input1.FormatAttributes = True
	input1.multiline
	
	If section.Verb = "POST" Or section.Verb = "PUT" Then
		'Dim p4 As MiniHtml = CreateTag("p").up(form1)
		Dim p4 As MiniHtml = CreateTag("p").up(div7)
		p4.multiline
		Dim strong5 As MiniHtml = CreateTag("strong").up(p4)
		strong5.text("Body:")
		Dim textarea1 As MiniHtml = CreateTag("textarea").up(p4)
		textarea1.attr("id", $"body${section.ElementId}"$)
		textarea1.attr("rows", "6")
		textarea1.cls("form-control data-body")
		textarea1.sty("background-color: #363636; color: white; font-size: small")
		textarea1.FormatAttributes = True
		textarea1.multiline
		textarea1.text(section.Body)
	End If
	
	'Dim button1 As MiniHtml = Button.up(form1)
	'button1.attr("id", $"btn${section.ElementId}"$)
	'button1.cls("post button submit-button-" & section.Color & " text-white col-md-6 col-lg-4 p-2 float-right")
	'button1.sty("cursor: pointer; padding-bottom: 60px")
	'Dim strong6 As MiniHtml = CreateTag("strong").up(button1)
	'strong6.text("Submit")

	'Dim button1 As MiniHtml = Button.up(form1)
	Dim button1 As MiniHtml = Button.up(div7)
	button1.attr("id", $"btn${section.ElementId}"$)
	button1.cls("btn submit-button-" & section.Color & " text-white col-md-6 col-lg-4 p-2 float-end")
	button1.sty("cursor: pointer; padding-bottom: 60px")
	'button1.attr("hx-get", "/api/categories")
	'button1.attr("hx-get", IIf(section.Raw, section.Link & "?format=json", section.Link))
	button1.attr("hx-get", "dynamic")
	button1.attr("hx-swap", "innerHTML")
	'button1.attr("hx-push-url", "click")
	'button1.attr("hx-headers", $"{"Authorization": "Bearer YOUR_API_TOKEN", "Accept": "application/json"}"$)
	button1.attr("hx-target", $"#response${section.ElementId}"$)
	'button1.attr("hx-push-url", "click")
	'button1.attr("hx-include", $"[name='path${section.ElementId}']"$)
	button1.attr("hx-on::click", $"this.setAttribute('hx-get', encodeURIComponent(htmx.process(htmx.find('#path${section.ElementId}').value)))"$)
	button1.attr("hx-trigger", "click")
	button1.FormatAttributes = True
	Dim strong4 As MiniHtml = CreateTag("strong").up(button1)
	strong4.text("Submit")

	Dim div6 As MiniHtml = Div.up(div4)
	div6.cls("col-md-6 p-3")
	div6.multiline
	Dim p5 As MiniHtml = CreateTag("p").up(div6)
	p5.multiline
	Dim strong7 As MiniHtml = CreateTag("strong").up(p5)
	strong7.text("Response")
	CreateTag("br").up(p5)
	Dim textarea2 As MiniHtml = CreateTag("textarea").up(p5)
	textarea2.attr("rows", "10")
	textarea2.attr("id", $"response${section.ElementId}"$)
	textarea2.cls("form-control")
	textarea2.sty("background-color: #363636; color: white; font-size: small")
	textarea2.FormatAttributes = True
	textarea2.multiline
	Dim div7 As MiniHtml = Div.up(div6)
	div7.attr("id", $"alert${section.ElementId}"$)
	div7.cls("alert text-light")
	div7.attr("role", "alert")
	div7.sty("display: none")
	div7.FormatAttributes = True
	div7.multiline
	
	
	'Dim div7 As MiniHtml = Div.up(div4)
	'div7.cls("col-md-3 p-3")
	'div7.multiline
	'Dim form1 As MiniHtml = CreateTag("form").up(div7)
	'form1.attr("id", "form1")
	''form1.attr("method", section.Verb.ToUpperCase)
	'form1.multiline
	'Dim p2 As MiniHtml = CreateTag("p").up(form1)
	'p2.multiline
	'Dim strong3 As MiniHtml = CreateTag("strong").up(p2)
	'strong3.text("Path")
	'CreateTag("br").up(p2)
	
	'Dim input1 As MiniHtml = Input.up(p2)
	'input1.attr("id", $"path${section.ElementId}"$)
	'input1.cls("form-control data-path text-light")
	'input1.sty("background-color: #696969; font-size: small")
	'input1.attr("value", IIf(section.Raw, section.Link & "?format=json", section.Link))
	'input1.FormatAttributes = True
	'input1.multiline
	
	'Dim button1 As MiniHtml = Button.up(form1)
	''button1.attr("id", $"btn${section.ElementId}"$)
	'button1.cls("get button submit-button-" & section.Color & " text-white col-md-6 col-lg-4 p-2 float-right")
	'button1.sty("cursor: pointer; padding-bottom: 60px")
	''button1.attr("hx-get", "/api/categories")
	''button1.attr("hx-get", IIf(section.Raw, section.Link & "?format=json", section.Link))
	'button1.attr("hx-get", "")
	'button1.attr("hx-swap", "innerHTML")
	''button1.attr("hx-push-url", "click")
	''button1.attr("hx-headers", $"{"Authorization": "Bearer YOUR_API_TOKEN", "Accept": "application/json"}"$)
	'button1.attr("hx-target", $"#response${section.ElementId}"$)
	''button1.attr("hx-push-url", "click")
	''button1.attr("hx-include", $"[name='path${section.ElementId}']"$)
	'button1.attr("hx-on::click", $"this.setAttribute('hx-get', document.getElementById('path${section.ElementId}').val)"$)
	''button1.attr("hx-trigger", "click")
	'button1.FormatAttributes = True
	'Dim strong4 As MiniHtml = CreateTag("strong").up(button1)
	'strong4.text("Submit")
	'Dim div8 As MiniHtml = Div.up(div4)
	'div8.cls("col-md-6 p-3")
	'div8.multiline
	'Dim p3 As MiniHtml = CreateTag("p").up(div8)
	'p3.multiline
	'Dim strong5 As MiniHtml = CreateTag("strong").up(p3)
	'strong5.text("Response")
	'CreateTag("br").up(p3)
	'Dim textarea1 As MiniHtml = CreateTag("textarea").up(p3)
	'textarea1.attr("rows", "10")
	'textarea1.attr("id", $"response${section.ElementId}"$)
	'textarea1.cls("form-control")
	'textarea1.sty("background-color: #363636; color: white; font-size: small")
	'textarea1.FormatAttributes = True
	'textarea1.multiline
	'Dim div9 As MiniHtml = Div.up(div8)
	'div9.attr("id", $"alert${section.ElementId}"$)
	'div9.cls("alert text-light")
	'div9.attr("role", "alert")
	'div9.sty("display: block")
	'div9.FormatAttributes = True
	'div9.multiline
	Return div1
End Sub

Private Sub GenerateHeaderByGroup (Group As String) As MiniHtml 'String
'	Return $"
'		<div class="row mt-3">
'            <div class="col-md-12">
'                <h6 class="text-uppercase text-primary"><strong>${Group}</strong></h6>
'            </div>
'		</div>"$
	Dim div1 As MiniHtml = Div
	div1.cls("row mt-3")
	div1.multiline
	Dim div2 As MiniHtml = Div.up(div1)
	div2.cls("col-md-12")
	div2.multiline
	Dim h61 As MiniHtml = CreateTag("h6").up(div2)
	h61.cls("text-uppercase text-primary")
	Dim strong1 As MiniHtml = CreateTag("strong").up(h61)
	strong1.text(Group)
	Return div1
End Sub

'Private Sub GenerateDocItem (Props As Map) As MiniHtml 'String
	
'	Return GenerateAccordion(section)
	
'	Return $"<div class="accordion" id="accordionPanelsStayOpenExample">
'  <div class="accordion-item bg-secondary text-white">
'    <h2 class="accordion-header" id="panelsStayOpen-headingOne">
'      <button class="accordion-button text-white bg-success bg-opacity-75 py-2 collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseOne" aria-controls="panelsStayOpen-collapseOne">
'        Accordion Item #1
'      </button>
'    </h2>
'    <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse" aria-labelledby="panelsStayOpen-headingOne">
'      <div class="accordion-body">
'        <strong>This is the first item's accordion body.</strong> It is shown by default, until the collapse plugin adds the appropriate classes that we use to style each element. These classes control the overall appearance, as well as the showing and hiding via CSS transitions. You can modify any of this with custom CSS or overriding our default variables. It's also worth noting that just about any HTML can go within the <code>.accordion-body</code>, though the transition does limit overflow.
'      </div>
'    </div>
'  </div>
'</div>"$
'End Sub

Private Sub GetColorForVerb (verb As String) As String
	' https://tailwindcss.com/docs/customizing-colors
	Select verb
		Case "GET"
			Return "green"
		Case "POST"
			Return "purple"
		Case "PUT"
			Return "blue"
		Case "DELETE"
			Return "red"
		Case Else
			Return ""
	End Select
End Sub

Private Sub GetExpectedResponse (verb As String) As String
	Dim Expected As StringBuilder
	Expected.Initialize
	Select verb
		Case "POST"
			Expected.Append("201 Created")
		Case Else
			Expected.Append("200 Success")
	End Select
	Expected.Append("<br/>400 Bad Request")
	Expected.Append("<br/>404 Not found")
	Expected.Append("<br/>405 Method not allowed")
	Expected.Append("<br/>422 Error execute query")
	Return Expected.ToString
End Sub

' output: <code>document.addEventListener('eventName', (event) => {...})</code>
Private Sub AddEventListener (eventName As String, buttonClass As String) As String
	Dim script1 As MiniJs
	script1.Initialize
	script1.IncreaseIndent
	script1.AddLine("")
	script1.AddLine("document.addEventListener('" & eventName & "', (event) => {")
	script1.IncreaseIndent
	script1.DeclareVariable("btn", "event.detail.elt", True)
	script1.AddLine("")
	script1.AddComment("Only apply to buttons with our specific class")
	script1.StartIf("btn.classList.contains('" & buttonClass & "')")
	script1.AddLine("")
	script1.AddComment("Find the parent container for THIS specific button")
	script1.DeclareVariable("container", $"btn.closest('.accordion-collapse')"$, True)
	script1.AddLine("")
	script1.AddComment("Grab values from inputs INSIDE this container only")
	script1.DeclareVariable("urlValue", $"container.querySelector('.path').value"$, True)
	'script1.DeclareVariable("urlValue", "document.getElementById('path'+id).value", True)
	'script1.DeclareVariable("tokenValue", "document.getElementById('api-token').value", True)
	script1.AddLine("")
	script1.AddComment("Override the URL")
	'script1 = script1.StartCondition("urlValue")
	script1.StartIf("urlValue")
	script1.AddLine("event.detail.path = urlValue;")
	script1 = script1.EndCondition
	'script1.AddConditionalCall("urlValue", "event.detail.path = urlValue;")
	'script1.AddLine("")
	'script1.AddComment("2. Inject the Authentication Header")
	'script1.StartCondition("tokenValue")
	'script1.AddLine("event.detail.path = urlValue;")
	'script1.EndCondition
	script1.EndIf
	script1.DecreaseIndent
	script1.AddLine("})")
	Return script1.Generate2
End Sub