B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
' MiniHtml Helper
' Version 6.93
Sub Process_Globals

End Sub

Public Sub CreateTag (Name As String) As MiniHtml
	Dim tag1 As MiniHtml
	tag1.Initialize(Name)
	Return tag1
End Sub

Public Sub Anchor As MiniHtml
	Return CreateTag("a")
End Sub

Public Sub Button As MiniHtml
	Return CreateTag("button")
End Sub

Public Sub Div As MiniHtml
	Return CreateTag("div")
End Sub

Public Sub Span As MiniHtml
	Return CreateTag("span")
End Sub

Public Sub Strong As MiniHtml
	Return CreateTag("strong")
End Sub

Public Sub Br As MiniHtml
	Return CreateTag("br")
End Sub

Public Sub Nav As MiniHtml
	Return CreateTag("nav")
End Sub

Public Sub Form As MiniHtml
	Return CreateTag("form")
End Sub

Public Sub H1 As MiniHtml
	Return CreateTag("h1")
End Sub

Public Sub H2 As MiniHtml
	Return CreateTag("h2")
End Sub

Public Sub H3 As MiniHtml
	Return CreateTag("h3")
End Sub

Public Sub H5 As MiniHtml
	Return CreateTag("h5")
End Sub

Public Sub H6 As MiniHtml
	Return CreateTag("h6")
End Sub

Public Sub P As MiniHtml
	Return CreateTag("p")
End Sub

Public Sub Html As MiniHtml
	Return CreateTag("html").lang("en")
End Sub

Public Sub Head As MiniHtml
	Return CreateTag("head")
End Sub

Public Sub Title As MiniHtml
	Return CreateTag("title")
End Sub

Public Sub Script As MiniHtml
	Return CreateTag("script")
End Sub

Public Sub Style As MiniHtml
	Return CreateTag("style")
End Sub

Public Sub Meta As MiniHtml
	Return CreateTag("meta")
End Sub

Public Sub Link As MiniHtml
	Return CreateTag("link")
End Sub

Public Sub Body As MiniHtml
	Return CreateTag("body")
End Sub

Public Sub Icon As MiniHtml
	Return CreateTag("i")
End Sub

Public Sub Img As MiniHtml
	Return CreateTag("img")
End Sub

Public Sub Svg As MiniHtml
	Return CreateTag("svg")
End Sub

Public Sub Path As MiniHtml
	Return CreateTag("path")
End Sub

Public Sub Input As MiniHtml
	Return CreateTag("input")
End Sub

Public Sub Label As MiniHtml
	Return CreateTag("label")
End Sub

Public Sub Caption As MiniHtml
	Return CreateTag("caption")
End Sub

Public Sub Footer As MiniHtml
	Return CreateTag("footer")
End Sub

Public Sub Table As MiniHtml
	Return CreateTag("table")
End Sub

Public Sub Tbody As MiniHtml
	Return CreateTag("tbody")
End Sub

Public Sub Td As MiniHtml
	Return CreateTag("td")
End Sub

Public Sub Th As MiniHtml
	Return CreateTag("th")
End Sub

Public Sub Thead As MiniHtml
	Return CreateTag("thead")
End Sub

Public Sub Tr As MiniHtml
	Return CreateTag("tr")
End Sub

Public Sub Ul As MiniHtml
	Return CreateTag("ul")
End Sub

Public Sub Li As MiniHtml
	Return CreateTag("li")
End Sub

Public Sub SelectTag As MiniHtml
	Return CreateTag("select")
End Sub

Public Sub Option As MiniHtml
	Return CreateTag("option")
End Sub

Public Sub Textarea As MiniHtml
	Return CreateTag("textarea")
End Sub

' ====================
'  Custom Components
' ====================
Public Sub Alert (info As AlertInfo) As String
	Dim div1 As MiniHtml = Div
	div1.cls("alert alert-" & info.Status)
	div1.text(info.Message)
	Return div1.build
End Sub

Public Sub Toast (id As String, table1 As MiniHtml, info As ToastInfo) As String
	Dim div1 As MiniHtml = Div
	div1.attr("id", id)
	div1.attr("hx-swap-oob", "true")
	'CategoriesTableFilled(data).up(div1)
	table1.up(div1)
	Dim script1 As MiniJs
	script1.Initialize
	script1.AddCustomEventDispatch("entity:changed", _
	CreateMap( _
	"entity": info.Entity, _
	"action": info.Action, _
	"message": info.Message, _
	"status": info.Status))
	Return div1.build & CRLF & script1.Generate
End Sub

Public Sub NavLinkItem (text As String, href As String, icon_cls As String, icon_title As String) As MiniHtml
	Dim li1 As MiniHtml = Li
	li1.cls("nav-item d-block d-lg-block")
	Dim a1 As MiniHtml = Anchor.up(li1)
	a1.attr("href", href)
	a1.cls("nav-link float-end")
	a1.text(text)
	Dim i1 As MiniHtml = Icon.up(a1)
	i1.cls(icon_cls)
	i1.attr("title", icon_title)
	Return li1
End Sub

Public Sub AnchorIcon (cls As String, hx_get As String, title_text As String, icon_class As String) As MiniHtml
	Dim a1 As MiniHtml = Anchor
	a1.cls(cls)
	a1.attr("hx-get", hx_get)
	a1.attr("hx-target", "#modal-content")
	a1.attr("hx-trigger", "click")
	a1.attr("data-bs-target", "#modal-container")
	a1.attr("data-bs-toggle", "modal")
	Icon.up(a1).cls(icon_class)
	a1.attr("title", title_text)
	Return a1
End Sub

Public Sub ButtonClose As MiniHtml
	Dim button1 As MiniHtml = Button
	button1.attr("type", "button")
	button1.cls("btn-close")
	button1.attr("data-bs-dismiss", "modal")
	Return button1
End Sub

Public Sub ButtonAdd (text As String, cls As String, hx_get As String, hx_target As String, hx_trigger As String, data_bs_target As String, data_bs_toggle As String) As MiniHtml
	Dim button1 As MiniHtml = Button
	button1.cls(cls)
	button1.attr("hx-get", hx_get)
	button1.attr("hx-target", hx_target)
	button1.attr("hx-trigger", hx_trigger)
	button1.attr("data-bs-target", data_bs_target)
	button1.attr("data-bs-toggle", data_bs_toggle)
	Icon.up(button1).cls("bi bi-plus-lg me-2")
	button1.text(text)
	Return button1
End Sub

Public Sub ButtonSubmit (text As String, cls As String) As MiniHtml
	Dim button1 As MiniHtml = Button
	button1.attr("type", "submit")
	button1.cls(cls)
	button1.text(text)
	Return button1
End Sub

Public Sub ButtonCancel (text As String, cls As String) As MiniHtml
	Dim button1 As MiniHtml = Button
	button1.attr("type", "button")
	button1.cls(cls)
	button1.attr("data-bs-dismiss", "modal")
	button1.text(text)
	Return button1
End Sub

Public Sub FormGroup As MiniHtml
	Return Div.cls("form-group")
End Sub

Public Sub HiddenInput (name As String, value As String) As MiniHtml
	Dim input1 As MiniHtml = Input
	input1.attr("type", "hidden")
	input1.attr("name", name)
	If value <> "" Then input1.attr("value", value)
	Return input1
End Sub

Public Sub RequiredLabel (text As String, forId As String) As MiniHtml
	Dim label1 As MiniHtml = Label
	If forId <> "" Then label1.attr("for", forId)
	label1.text(text)
	Span.up(label1).cls("text-danger").text("*")
	Return label1
End Sub

Public Sub RequiredTextInput (id As String, name As String, value As String) As MiniHtml
	Dim input1 As MiniHtml = Input
	input1.attr("type", "text")
	input1.cls("form-control")
	input1.attr("id", id)
	input1.attr("name", name)
	If value <> "" Then input1.attr("value", value)
	input1.required
	Return input1
End Sub