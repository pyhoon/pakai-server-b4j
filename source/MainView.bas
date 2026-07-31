B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Main View
' Version 6.99 rev2
Sub Class_Globals
	Private mModal, mToast, mContent, mSubContent As MiniHtml
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
	MH.CopyrightFooter.up(body1)
	'Local assets
	'body1.cdn("script", "$SERVER_URL$/assets/js/bootstrap.min.js")
	'body1.cdn("script", "$SERVER_URL$/assets/js/htmx.min.js")
	MH.Script.up(body1).attr("src", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js") _
	.integrity("sha384-G/EV+4j2dNv+tEPo3++6LCgdCROaejBqfUeNjuKAiuXbjrxilcCdDz6ZAVfHWe1Y").crossorigin("anonymous")
	MH.Script.up(body1).attr("src", "https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js") _
	.integrity("sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz").crossorigin("anonymous")
	MH.Script.up(body1).attr("src", "$SERVER_URL$/assets/js/app.js")
	Return page1
End Sub

Private Sub PageHeader As MiniHtml
	Dim head1 As MiniHtml = MH.ResponsiveHeader
	MH.Meta.up(head1).attr("name", "description").attr("content", "Created using Pakai framework")
	MH.Meta.up(head1).attr("name", "author").attr("content", "Aeric Poon")
	MH.Title.up(head1).text("$APP_TITLE$")
	MH.FavoriteIcon("image/png", "$SERVER_URL$/assets/img/favicon.png").up(head1)
	'Local assets
	'head1.cdn("style", "$SERVER_URL$/assets/css/bootstrap.min.css")
	'head1.cdn("style", "$SERVER_URL$/assets/css/bootstrap-icons.min.css")
	MH.Link.up(head1).attr("rel", "stylesheet").attr("href", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css") _
	.integrity("sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB").crossorigin("anonymous")
	MH.Link.up(head1).attr("rel", "stylesheet").attr("href", "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css")	
	MH.Link.up(head1).attr("rel", "stylesheet").attr("href", "$SERVER_URL$/assets/css/main.css?v=$VERSION$")
	Return head1
End Sub

Private Sub PageBody As MiniHtml
	Dim body1 As MiniHtml = MH.Body.cls("bg-white")
	If mToast.IsInitialized Then mToast.up(body1)
	Dim nav1 As MiniHtml = MH.NavbarExpand("navbar-light sticky-top bg-info py-1", "lg", "bi bi-infinity h3", "$APP_TRADEMARK$").up(body1)
	Dim div1 As MiniHtml = nav1.ChildByClass("container-fluid")
	MH.NavbarToggler.up(div1)
	MH.NavbarCollapse.up(div1)
	Dim collapse1 As MiniHtml = MH.NavbarCollapse.up(div1)
	Dim navbar1 As MiniHtml = collapse1.child(0)
	MH.NavLinkItemImage("https://paypal.me/aeric80/", "/assets/img/coffee.png", "").up(navbar1)
	Dim sponsor As MiniHtml = MH.SponsorLink.up(body1)
	Dim a1 As MiniHtml = sponsor.child(0)
	a1.child(0).sty("width: 174px")
	Dim content1 As MiniHtml = MH.Div.up(body1).cls("content m-3")
	Dim padding2 As MiniHtml = MH.Div.up(content1).cls("p-2")
	If Initialized(mContent) Then mContent.up(padding2)
	If Initialized(mSubContent) Then mSubContent.up(padding2)
	If Initialized(mModal) Then mModal.up(body1)
	MH.Div.up(body1).cls("bottom")
	Return body1
End Sub