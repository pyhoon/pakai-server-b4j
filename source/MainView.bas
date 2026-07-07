B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Main View
' Version 6.99
Sub Class_Globals
	Private mModal As MiniHtml
	Private mToast As MiniHtml
	Private mContent As MiniHtml
	Private mSubContent As MiniHtml
End Sub

Public Sub Initialize

End Sub

Public Sub LoadContent (Tag1 As MiniHtml)
	mContent = Tag1
End Sub

Public Sub LoadSubContent (Tag1 As MiniHtml)
	mSubContent = Tag1
End Sub

Public Sub LoadModal (Tag1 As MiniHtml)
	mModal = Tag1
End Sub

Public Sub LoadToast (Tag1 As MiniHtml)
	mToast = Tag1
End Sub

Public Sub Render As MiniHtml
	Dim page1 As MiniHtml = MH.Html
	PageHeader.up(page1)
	PageBody.up(page1)
	Dim body1 As MiniHtml = page1.ChildByName("body")
	BodyFooter.up(body1)
	'Local assets
	'body1.cdn("script", "$SERVER_URL$/assets/js/bootstrap.min.js")
	'body1.cdn("script", "$SERVER_URL$/assets/js/htmx.min.js")
	body1.cdn2("script", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js", _
	"sha384-G/EV+4j2dNv+tEPo3++6LCgdCROaejBqfUeNjuKAiuXbjrxilcCdDz6ZAVfHWe1Y", "anonymous")
	body1.cdn2("script", "https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js", _
	"sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz", "anonymous")
	body1.cdn("script", "$SERVER_URL$/assets/js/app.js")
	Return page1
End Sub

Private Sub PageHeader As MiniHtml
	Dim head1 As MiniHtml = MH.Head
	MH.Meta.up(head1).attr("http-equiv", "content-type" ).attr("content", "text/html; charset=utf-8")
	MH.Meta.up(head1).attr("name", "viewport").attr("content", "width=device-width, initial-scale=1")
	MH.Meta.up(head1).attr("name", "description").attr("content", "Created using Pakai framework")
	MH.Meta.up(head1).attr("name", "author").attr("content", "Aeric Poon")
	Dim title1 As MiniHtml = MH.Title.up(head1)
    title1.text("$APP_TITLE$")
	Dim link1 As MiniHtml = MH.Link.up(head1)
	link1.attr("rel", "icon")
	link1.attr("type", "image/png")
	link1.attr("href", "$SERVER_URL$/assets/img/favicon.png")
	'Local assets
	'head1.cdn("style", "$SERVER_URL$/assets/css/bootstrap.min.css")
	'head1.cdn("style", "$SERVER_URL$/assets/css/bootstrap-icons.min.css")
	head1.cdn2("style", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css", _
	"sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB", "anonymous")
	head1.cdn("style", "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css")	
	head1.cdn("style", "$SERVER_URL$/assets/css/main.css?v=$VERSION$")
	Return head1
End Sub

Private Sub PageBody As MiniHtml
	Dim body1 As MiniHtml = MH.Body
	body1.cls("bg-white")
	If mToast.IsInitialized Then mToast.up(body1)
	Dim nav1 As MiniHtml = MH.Nav.up(body1)
	nav1.cls("navbar navbar-light navbar-expand-lg sticky-top bg-info py-1")
	Dim div1 As MiniHtml = MH.Div.up(nav1)
	div1.cls("container-fluid")
	Dim a1 As MiniHtml = MH.Anchor.up(div1)
	a1.cls("navbar-brand me-0 me-lg-2 pt-2")
	a1.attr("href", "#")
	MH.Icon.up(a1).cls("bi bi-infinity h3")
	Dim a2 As MiniHtml = MH.Anchor.up(div1)
	a2.cls("navbar-brand")
	a2.attr("href", "$SERVER_URL$")
	a2.text("$APP_TRADEMARK$")
	Dim toggler1 As MiniHtml = MH.Button.cls("navbar-toggler d-md-block d-lg-none collapsed").up(div1)
	toggler1.attr("type", "button")
	toggler1.attr("data-bs-toggle", "collapse")
	toggler1.attr("data-bs-target", "#navbarCollapse")
	toggler1.sty("border: none")
	MH.Span.up(toggler1).cls("navbar-toggler-icon")
	Dim collapse1 As MiniHtml = MH.Div.up(div1)
	collapse1.cls("collapse navbar-collapse")
	collapse1.attr("id", "navbarCollapse")
	Dim navbar1 As MiniHtml = MH.Ul.up(collapse1)
	navbar1.cls("navbar-nav navbar-brand ms-auto mb-md-0")
	
	Dim navitem1 As MiniHtml = MH.Li.up(navbar1)
	navitem1.cls("nav-item d-block d-lg-none")
	navitem1.Id = "nav-item"
	Dim a1 As MiniHtml = MH.Anchor.up(navitem1)
	a1.cls("nav-link float-end")
	a1.attr("href", "https://paypal.me/aeric80/")
	a1.attr("target", "_blank")
	Dim img1 As MiniHtml = MH.Img.up(a1)
	img1.attr("src", "/assets/img/coffee.png")
	img1.cls("my-1")
	img1.sty("height: 36px")
	
	Dim sponsor As MiniHtml = MH.Div.up(body1)
	sponsor.cls("text-center font-weight-bold d-none d-lg-block")
	sponsor.sty("background-color: whitesmoke")
	Dim a2 As MiniHtml = MH.Anchor.up(sponsor)
	a2.attr("href", "https://paypal.me/aeric80/")
	a2.attr("target", "_blank")
	Dim img2 As MiniHtml = MH.Img.up(a2)
	img2.attr("src", "/assets/img/sponsor.png")
	img2.cls("mx-2")
	img2.sty("width: 174px")
	Dim content1 As MiniHtml = MH.Div.up(body1).cls("content m-3")
	Dim padding2 As MiniHtml = MH.Div.up(content1).cls("p-2")
	'BodyHeading.up(padding2)
	
	If Initialized(mContent) Then mContent.up(padding2)
	If Initialized(mSubContent) Then mSubContent.up(padding2)
	If Initialized(mModal) Then mModal.up(body1)
	MH.Div.up(body1).cls("bottom")
	Return body1
End Sub

Private Sub BodyFooter As MiniHtml
	Dim footer1 As MiniHtml = MH.Footer
	footer1.cls("footer mt-auto py-3 bg-body-tertiary border-top")
	Dim small1 As MiniHtml = MH.Div.up(footer1)
	small1.cls("footer small text-center d-md-block")
	small1.sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif")
	Dim caption1 As MiniHtml = MH.Caption.up(small1)
	caption1.text("$APP_COPYRIGHT$")
	MH.Br.up(caption1)
	caption1.text("Made with ")
	Dim span1 As MiniHtml = MH.Span.up(caption1)
	span1.sty("color: red")
	MH.Icon.up(span1).cls("bi bi-heart")
	caption1.text(" in B4X")
	Return footer1
End Sub

Private Sub BodyHeading As MiniHtml 'ignore
	Dim row1 As MiniHtml = MH.Div
	row1.cls("row text-center align-items-center justify-content-center")
	Dim div1 As MiniHtml = MH.Div.up(row1)
	Dim h31 As MiniHtml = MH.H3.up(div1)
	h31.cls("mb-0")
	h31.sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif")
	h31.text("$HOME_TITLE$")
	MH.Span.up(div1).cls("small").text("Version: $VERSION$")
End Sub