B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
Sub Class_Globals
	Private mPlaceholders As List
	Private mContent As Tag
	Private mModal As Tag
	Private mToast As Tag
End Sub

Public Sub Initialize
	mPlaceholders.Initialize
End Sub

Public Sub LoadView (Tag1 As Tag)
	mPlaceholders.Add(Tag1)
End Sub

Public Sub LoadView2 (Tags As List)
	mPlaceholders.Add(Tags)
End Sub

Public Sub LoadView3 (View1 As String)
	Dim parser As MiniHtmlParser
	parser.Initialize
	Dim root As HtmlNode = parser.Parse(View1)
	If root.IsInitialized Then
		Dim newTag As Tag = parser.ConvertToTag(root)
		mPlaceholders.Add(newTag)
	End If
End Sub

Public Sub LoadContent (Tag1 As Tag)
	mContent = Tag1
End Sub

Public Sub LoadModal (Tag1 As Tag)
	mModal = Tag1
End Sub

Public Sub LoadToast (Tag1 As Tag)
	mToast = Tag1
End Sub

Public Sub Render As Tag
	Dim page1 As Tag = Html.lang("en")
	page1.add(PageHeader)
	page1.add(PageBody)
	Dim body1 As Tag = page1.ChildByTagName("body")
	body1.add(BodyFooter)
	body1.cdnScript("https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js", _
	"sha384-G/EV+4j2dNv+tEPo3++6LCgdCROaejBqfUeNjuKAiuXbjrxilcCdDz6ZAVfHWe1Y")
	body1.cdnScript("https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js", _
	"sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz")
	body1.script("$SERVER_URL$/assets/js/main.js")
	Return page1
End Sub

Private Sub PageHeader As Tag
	Dim header1 As Tag = Head.init
	header1.add(Meta.attr("http-equiv", "content-type" ).attr("content", "text/html; charset=utf-8"))
	header1.add(Meta.attr("name", "viewport").attr("content", "width=device-width, initial-scale=1"))
	header1.add(Meta.attr("name", "description").attr("content", "Created using Pakai framework"))
	header1.add(Meta.attr("name", "author").attr("content", "Aeric Poon"))
	header1.title("$APP_TITLE$")
	header1.linkIcon("image/png", "$SERVER_URL$/assets/img/favicon.png")
	header1.cdnStyle("https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css", _
	"sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB")
	header1.linkcss("https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css")
	header1.linkcss("$SERVER_URL$/assets/css/main.css?v=$VERSION$")
	Return header1
End Sub

Private Sub PageBody As Tag
	Dim body1 As Tag = Body.cls("bg-white")
	If mToast.IsInitialized Then body1.add(mToast)
	Dim nav1 As Tag = body1.add(Nav.cls("navbar navbar-expand-lg sticky-top yellow"))
	Dim div1 As Tag = nav1.add(Div.cls("container-fluid"))
	
	'div1.add(Anchor.cls("navbar-brand me-0 me-lg-2 pt-2").hrefOf("#")).add(Icon.cls("ti ti-infinite").sty("font-size: 1.8em"))
	div1.add(Anchor.cls("navbar-brand me-0 me-lg-2 pt-2").hrefOf("#")).add(Icon.cls("bi bi-infinity").sty("font-size: 1.8em"))
	div1.add(Anchor.cls("navbar-brand d-none d-md-block").hrefOf("$SERVER_URL$").text("$APP_TRADEMARK$"))
	
	Dim toggler1 As Tag = div1.add(Button.cls("navbar-toggler d-none d-lg-none d-md-block collapsed"))
	toggler1.typeOf("button") _
	.data("bs-toggle", "collapse") _
	.data("bs-target", "#navbarCollapse") _
	.sty("border: none") _
	.add(Span.cls("navbar-toggler-icon"))
	
	Dim collapse1 As Tag = div1.add(Div.cls("collapse navbar-collapse").id("navbarCollapse"))
	Dim ulist1 As Tag = collapse1.add(Ul.cls("navbar-nav navbar-brand ms-auto mb-md-0"))
	Dim list1 As Tag = ulist1.add(Li.cls("nav-item d-none d-md-block"))
	
	Dim anchor1 As Tag = list1.add(Anchor.href("https://paypal.me/aeric80/").targetOf("_blank"))
	anchor1.add(Img.src("/assets/img/coffee.png").cls("ml-2 mt-1").sty("height: 40px"))
	
	Dim sponsor As Tag = Div.cls("text-center font-weight-bold d-block d-sm-block d-md-none").up(body1)
	sponsor.sty("background-color: whitesmoke")
	Dim anchor2 As Tag = sponsor.add(Anchor.href("https://paypal.me/aeric80/").targetOf("_blank"))
	anchor2.add(Img.src("/assets/img/sponsor.png").cls("mx-2").sty("width: 174px"))
	
	Dim content1 As Tag = body1.add(Div.cls("content m-3"))
	Dim padding2 As Tag = content1.add(Div.cls("p-2"))
	Dim row1 As Tag = padding2.add(Div.cls("row text-center align-items-center justify-content-center"))
	'row1.add(Div.cls("mx-3")) _
	'.add(Img.src("$SERVER_URL$/assets/img/loading.webp").width("60px").height("60px"))
	Dim div1 As Tag = row1.add(Div.init)
	div1.add(H3.cls("mb-0").sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif")) _
	.text("$HOME_TITLE$")
	div1.add(Span.cls("small").text("Version: $VERSION$"))

	If mContent.IsInitialized Then padding2.add(mContent)
	If mModal.IsInitialized Then body1.add(mModal)
	
	body1.add(Div.cls("bottom"))
	Return body1
End Sub

Private Sub BodyFooter As Tag
	Dim footer1 As Tag = Footer.cls("footer mt-auto py-3 bg-body-tertiary border-top")
	Dim small1 As Tag = footer1.add(Div.cls("footer small text-center d-md-block") _
	.sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"))
	Dim caption1 As Tag = small1.add(Caption.text("$APP_COPYRIGHT$").add2(Br.init))
	caption1.text("Pakai ")
	Dim span1 As Tag = Span.sty("color: red").up(caption1)
	'span1.add(Icon.cls("ti ti-heart"))
	span1.add(Icon.cls("bi bi-heart"))
	caption1.text(" B4X")
	Return footer1
End Sub