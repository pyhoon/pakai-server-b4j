B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
Sub Class_Globals
	'Private mView As String
	Private mPlaceholders As List
End Sub

Public Sub Initialize
	mPlaceholders.Initialize
End Sub

Public Sub AddPlaceholder (Tag1 As Tag)
	'mView = View
	mPlaceholders.Add(Tag1)
End Sub

Public Sub AddPlaceholder2 (Tags As List)
	mPlaceholders.Add(Tags)
End Sub

Public Sub AddPlaceholder3 (View1 As String)
	Dim parser As MiniHtmlParser
	parser.Initialize
	'parser.ShowParserLogs = True
	Dim root As HtmlNode = parser.Parse(View1)
	If root.IsInitialized Then
		Dim newTag As Tag = parser.ConvertToTag(root)
		mPlaceholders.Add(newTag)
	End If
End Sub

Public Sub ReturnTag As Tag
	Dim page1 As Tag = Html.lang("en")
	page1.add(PageHeader)
	page1.add(PageBody)
	Dim body1 As Tag = page1.ChildByTagName("body")
	body1.add(BodyFooter)
	body1.script("$SERVER_URL$/assets/js/jquery.min.js")
	body1.script("$SERVER_URL$/assets/js/jquery.validate.min.js")
	body1.script("$SERVER_URL$/assets/js/bootstrap.bundle.min.js")
	Return page1
End Sub

Public Sub ReturnView As String
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(ReturnTag.build)
	Return doc.ToString
End Sub

Private Sub PageHeader As Tag
	Dim header1 As Tag = Head.init
	header1.add(Meta.attr("http-equiv", "content-type" ).attr("content", "text/html; charset=utf-8"))
	header1.add(Meta.attr("name", "viewport").attr("content", "width=device-width, initial-scale=1"))
	'header1.add(Meta.attr("name", "csrf-token").attr("content", ""))
	header1.add(Meta.attr("name", "description").attr("content", ""))
	header1.add(Meta.attr("name", "author").attr("content", ""))
	header1.title("$APP_TITLE$")
	header1.linkIcon("image/png", "$SERVER_URL$/assets/img/favicon.png")
	header1.linkcss("$SERVER_URL$/assets/css/bootstrap.min.css")
	header1.linkcss("$SERVER_URL$/assets/css/fontawesome.min.css")
	header1.linkcss("$SERVER_URL$/assets/css/solid.min.css")
	header1.linkcss("$SERVER_URL$/assets/css/main.css?v=$VERSION$")
	Return header1
End Sub

Private Sub PageBody As Tag
	Dim body1 As Tag = Body.cls("bg-white")
	Dim nav1 As Tag = body1.add(Nav.cls("navbar navbar-expand-lg fixed-top navbar-dark yellow pt-1 pb-1"))
	nav1.add(Anchor.cls("text-dark h4 mt-2 mr-2").hrefOf("#")).add(Icon.cls("fas fa-cloud ml-3"))
	nav1.add(Anchor.cls("navbar-brand font-weight-bold text-dark").hrefOf("$SERVER_URL$").text("$APP_TRADEMARK$"))
	Dim toggler1 As Tag = nav1.add(Button.cls("navbar-toggler custom-toggler"))
	toggler1.typeOf("button") _
	.attr("data-toggle", "collapse") _
	.attr("data-target", "#navbarCollapse") _
	.sty("border: none") _
	.add(Span.cls("navbar-toggler-icon"))
	Dim collapse1 As Tag = nav1.add(Div.cls("collapse navbar-collapse").id("navbarCollapse"))
	Dim Ult1 As Tag = collapse1.add(Ul.cls("navbar-nav ml-auto"))
	If Main.Api.EnableHelp Then
		Dim Lit1 As Tag = Ult1.add(Li.cls("nav-item mt-1 ml-3"))
		Dim Anchor1 As Tag = Lit1.add(Anchor.cls("nav-link font-weight-bold text-dark mr-3"))
		Anchor1.hrefOf($"${Main.App.ServerUrl}/help"$)
		Anchor1.add(Icon.cls("fas fa-cog mr-2").attr("title", "API"))
		Anchor1.text("API")
	End If	
	Dim Lit2 As Tag = Ult1.add(Li.cls("nav-item font-weight-bold d-none d-sm-none d-md-block"))
	Dim Anchor2 As Tag = Lit2.add(Anchor.href("https://paypal.me/aeric80/").targetOf("_blank"))
	Anchor2.add(Img.src("/assets/img/coffee.png").cls("ml-2 mt-1").sty("height: 40px"))
	Dim sponsor As Tag = Div.cls("text-center font-weight-bold d-block d-sm-block d-md-none").up(body1)
	sponsor.sty("background-color: whitesmoke")
	Dim Anchor3 As Tag = sponsor.add(Anchor.href("https://paypal.me/aeric80/").targetOf("_blank"))
	Anchor3.add(Img.src("/assets/img/sponsor.png").cls("mx-2").sty("width: 174px"))
	
	Dim content1 As Tag = body1.add(Div.cls("content m-3"))
	Dim padding2 As Tag = content1.add(Div.cls("p-2"))
	Dim row1 As Tag = padding2.add(Div.cls("row text-center align-items-center justify-content-center"))
	'row1.add(Div.cls("mx-3")) _
	'.add(Img.src("$SERVER_URL$/assets/img/loading.webp").width("60px").height("60px"))
	Dim div1 As Tag = row1.add(Div.init)
	div1.add(H3.cls("mb-0").sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif")) _
	.text("$HOME_TITLE$")
	div1.add(Span.cls("small").text("Version: $VERSION$"))

	'Dim newTag As Tag = mPlaceholders.Get(0)
	'For Each child As Tag In newTag.Children
	'	padding2.add(child) ' DocView
	'Next
	
	Dim newTags As List = mPlaceholders.Get(0)
	For Each newTag As Tag In newTags
		padding2.add(newTag) ' DocView
	Next
	
	body1.add(Div.cls("bottom"))
	Return body1
End Sub

Private Sub BodyFooter As Tag
	Dim footer1 As Tag = Footer.cls("footer footer-dark bg-secondary pl-4 pt-2 pb-2")
	Dim small1 As Tag = footer1.add(Div.cls("footer small text-white text-center d-md-block") _
	.sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"))
	Dim caption1 As Tag = small1.add(Caption.text("$APP_COPYRIGHT$").add2(Br.init))
	caption1.text("Pakai with ").add2(Span.sty("color: red").text("❤")).text(" in B4X")
	Return footer1
End Sub