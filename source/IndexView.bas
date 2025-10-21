B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Public Sub ReturnView As String
	Dim doc As Document
	doc.Initialize
	'doc.AppendDocType
	'Dim html1 As Tag = Html.lang("en")
	'html1.add(PageHeader)
	'html1.add(PageBody)
	'Dim body1 As Tag = html1.ChildByTagName("body")
	'body1.add(BodyFooter)
	'body1.script("$SERVER_URL$/assets/js/jquery.min.js")
	'body1.script("$SERVER_URL$/assets/scripts/help.js")
	'doc.Append(html1.build)
	'doc.Indents = 3
	doc.Append(Html.comment(" Content Begin ").Build)
	doc.Append(Html.comment(" Content End ").Build)
	Return doc.ToString
End Sub

Public Sub ReturnTags As List
	Dim Tags As List
	Tags.Initialize
	'Dim doc1 As Document
	'doc1.Initialize
	'doc1.Indents = 3
	'doc1.Append(Html.comment(" Content Begin ").Build)
	'doc1.Append(Html.comment(" Content End ").Build)	
	Tags.Add(Html.comment(" Content Begin "))
	
	Dim content1 As Tag = Div.cls("row mt-3")
	Dim col12 As Tag = content1.add(Div.cls("col-md-12"))
	
	Dim form1 As Tag = col12.add(Form.cls("form mb-3").id("search_form").action(""))
	Dim row1 As Tag = form1.add(Div.cls("row"))
	Dim col1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim input_group1 As Tag = col1.add(Div.cls("input-group input-group-sm"))
	input_group1.add(Div.cls("input-group-prepend")).add(Span.cls("input-group-text mt-2").id("inputGroup-sizing-sm").text("Search"))
	input_group1.add(Input.cls("form-control col-md-6 mt-2").typeOf("text").id("keyword").name("keyword"))
	input_group1.add(Button.cls("btn btn-danger btn-sm pl-3 pr-3 ml-3 mt-2").typeOf("button").id("btnsearch").text("Submit"))
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = col2.add(Div.cls("text-right mt-2"))
	div2.add(Anchor.href("$SERVER_URL$/categories").cls("btn btn-primary btn-sm mb-2").add2(Icon.cls("fa fa-bars")).text(" Show Category"))
	div2.add(Anchor.href("#new").cls("btn btn-success btn-sm mb-2 ml-2").data("toggle", "modal").add2(Icon.cls("fa fa-plus")).text(" New Product"))
	col12.add(Div.id("results").cls("table")).add(HtmlTable.cls("table table-bordered rounded small"))
	Tags.Add(content1)
	Tags.Add(Html.comment(" Content End "))
	Return Tags
End Sub

'Private Sub PageHeader As Tag
'	Dim html1 As Tag = Html.lang("en")
'	Dim header1 As Tag = html1.add(Head.init)
'	header1.add(Meta.attr("http-equiv", "content-type" ).attr("content", "text/html; charset=utf-8"))
'	header1.add(Meta.attr("name", "viewport").attr("content", "width=device-width, initial-scale=1"))
'	'header1.add(Meta.attr("name", "csrf-token").attr("content", ""))
'	header1.add(Meta.attr("name", "description").attr("content", ""))
'	header1.add(Meta.attr("name", "author").attr("content", ""))
'	header1.title("$APP_TITLE$")
'	header1.linkIcon("image/png", "$SERVER_URL$/assets/img/favicon.png")
'	header1.linkcss("$SERVER_URL$/assets/css/bootstrap.min.css")
'	header1.linkcss("$SERVER_URL$/assets/css/fontawesome.min.css")
'	header1.linkcss("$SERVER_URL$/assets/css/solid.min.css")
'	header1.linkcss("$SERVER_URL$/assets/css/main.css?v=$VERSION$")
'	'PageBody.up(html1)
'	Return html1
'End Sub