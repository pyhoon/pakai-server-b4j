B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
'MiniHtml Helper
'Version: 3.30
Sub Process_Globals
	Type AlertInfo (Message As String, Status As String)
	Type ToastInfo (Entity As String, Action As String, Message As String, Status As String)
End Sub

'Create MiniHTML object by name
Sub CMH (Name As String = "", multiline As Boolean = False) As MiniHtml
	Dim tn As MiniHtml
	tn.Initialize(Name)
	If tn.Mode = "uniline" Or tn.Mode = "multiline" Then
		tn.multilineIf(multiline)
	End If
	Return tn
End Sub

Sub CreateMiniJs As MiniJs
	Dim s As MiniJs
	s.Initialize
	Return s
End Sub

Sub Anchor (multiline As Boolean = True) As MiniHtml
	Return CMH("a", multiline)
End Sub

Sub Button (multiline As Boolean = True) As MiniHtml
	Return CMH("button", multiline)
End Sub

Sub Div (multiline As Boolean = True) As MiniHtml
	Return CMH("div", multiline)
End Sub

Sub Span (multiline As Boolean = False, LineFeed As Boolean = True, Indentation As Boolean = True) As MiniHtml
	Dim ic As MiniHtml = CMH("span", multiline)
	ic.LineFeed = LineFeed
	ic.Indentation = Indentation
	Return ic
End Sub

Sub Br As MiniHtml
	Return CMH("br", False)
End Sub

Sub Nav (multiline As Boolean = True) As MiniHtml
	Return CMH("nav", multiline)
End Sub

Sub Form (multiline As Boolean = True) As MiniHtml
	Return CMH("form", multiline)
End Sub

Sub H3 As MiniHtml
	Return CMH("h3")
End Sub

Sub H5 As MiniHtml
	Return CMH("h5")
End Sub

Sub P As MiniHtml
	Return CMH("p")
End Sub

Sub Html As MiniHtml
	Return CMH("html").lang("en")
End Sub

Sub Head (multiline As Boolean = True) As MiniHtml
	Return CMH("head", multiline)
End Sub

Sub Title As MiniHtml
	Return CMH("title")
End Sub

Sub Meta As MiniHtml
	Return CMH("meta")
End Sub

Sub Link (rel As String = "stylesheet", typeof As String = "") As MiniHtml
	Return CMH("link").attrIfValue("rel", rel).attrIfValue("type", typeof)
End Sub

Sub Script As MiniHtml
	Return CMH("script")
End Sub

Sub Body As MiniHtml
	Return CMH("body")
End Sub

Sub Icon (multiline As Boolean = False, LineFeed As Boolean = True, Indentation As Boolean = True) As MiniHtml
	Dim ic As MiniHtml = CMH("i", multiline)
	ic.LineFeed = LineFeed
	ic.Indentation = Indentation
	Return ic
End Sub

Sub Input As MiniHtml
	Return CMH("input")
End Sub

Sub Label As MiniHtml
	Return CMH("label")
End Sub

Sub Caption (multiline As Boolean = False) As MiniHtml
	Return CMH("caption", multiline)
End Sub


Sub Footer (multiline As Boolean = True) As MiniHtml
	Return CMH("footer", multiline)
End Sub

Sub Table (multiline As Boolean = True) As MiniHtml
	Return CMH("table", multiline)
End Sub

Sub Tbody (multiline As Boolean = True) As MiniHtml
	Return CMH("tbody", multiline)
End Sub

Sub Td As MiniHtml
	Return CMH("td")
End Sub

Sub Th As MiniHtml
	Return CMH("th")
End Sub

Sub Thead As MiniHtml
	Return CMH("thead")
End Sub

Sub Tr As MiniHtml
	Return CMH("tr")
End Sub

Sub Ul (multiline As Boolean = True) As MiniHtml
	Return CMH("ul", multiline)
End Sub

Sub Li (multiline As Boolean = True) As MiniHtml
	Return CMH("li", multiline)
End Sub

Sub SelectTag (multiline As Boolean = True) As MiniHtml
	Return CMH("select", multiline)
End Sub

Sub Option As MiniHtml
	Return CMH("option")
End Sub

' ============================
'  Bootstrap Layout Helpers
' ============================

Sub ContainerFluid As MiniHtml
	Return Div.cls("container-fluid")
End Sub

Sub Row As MiniHtml
	Return Div.cls("row")
End Sub

Sub Col (cols As String) As MiniHtml
	Return Div.cls("col-" & cols)
End Sub

Sub HiddenInput (id As String, name As String, value As String) As MiniHtml
	Return Input.attr("type", "hidden").attrsIfValues(CreateMap("id": id, "name": name, "value": value))
End Sub

Sub RequiredLabel (text As String, forId As String) As MiniHtml
	Return Label.attrIfvalue("for", forId).text(text).down(Span).cls("text-danger").text("*").Parent
End Sub

Sub RequiredTextInput (id As String, name As String, value As String) As MiniHtml
	Return Input.attr("type", "text").cls("form-control").attrsIfValues(CreateMap("id": id, "name": name, "value": value)).required
End Sub

Sub RequiredDropdown (id As String, name As String) As MiniHtml
	Return SelectTag.cls("form-select").attrsIfValues(CreateMap("id": id, "name": name)).required
End Sub

Sub TextInputGroup (id As String, name As String, value As String, label_text As String) As MiniHtml
	Return FormGroup.add(RequiredLabel(label_text, id)).add(RequiredTextInput(id, name, value))
End Sub

Sub DropdownGroup (id As String, name As String, label_text As String) As MiniHtml
	Return FormGroup.add(RequiredLabel(label_text, id)).add(RequiredDropdown(id, name))
End Sub

' ============================
'  HTMX Helpers
' ============================

Sub HxGet (href As String, target As String, swap As String, trigger As String) As MiniHtml
	Return Anchor.attr("hx-get", href).attrsIfValues(CreateMap("hx-target": target, "hx-swap": swap, "hx-trigger": trigger))
End Sub

Sub ContainerHxGet (id As String, href As String, trigger As String, text As String) As MiniHtml
	Return Div.attr("id", id).attr("hx-get", href).attr("hx-trigger", trigger).text(text)
End Sub

Sub FormHxPost (href As String, target As String) As MiniHtml
	Return FormHx("post", href, target)
End Sub

Sub FormHxPut (href As String, target As String) As MiniHtml
	Return FormHx("put", href, target)
End Sub

Sub FormHxDelete (href As String, target As String) As MiniHtml
	Return FormHx("delete", href, target)
End Sub

Sub FormHx (verb As String, href As String, target As String) As MiniHtml
	Return Form.attr("hx-"& verb, href).attr("hx-target", target).attr("hx-swap", "innerHTML")
End Sub

' ============================
'  Navigation Helpers
' ============================

'Navbar with "container-fluid" class div, 2 "navbar-brand" class anchors and an icon class
Sub NavbarExpand (cls As String, expand As String, brand_icon_cls As String, brand_text As String) As MiniHtml
	Return Nav.cls("navbar navbar-expand-" & expand).clsIf(cls <> "", cls).down(ContainerFluid).down(Anchor).cls("navbar-brand").attr("href", "#").down(Icon).cls(brand_icon_cls).Parent.Parent.down(Anchor(False)).cls("navbar-brand").attr("href", "$SERVER_URL$").text(brand_text).Parent.Parent
End Sub

Sub NavbarToggler As MiniHtml
	Return Button.cls("navbar-toggler d-md-block d-lg-none collapsed").attr("type", "button").attr("data-bs-toggle", "collapse").attr("data-bs-target", "#navbarCollapse").sty("border: none").down(Span(False)).cls("navbar-toggler-icon").Parent
End Sub

Sub NavbarCollapse As MiniHtml
	Return Div.cls("collapse navbar-collapse").attr("id", "navbarCollapse").down(Ul).cls("navbar-nav navbar-brand ms-auto mb-md-0").Parent
End Sub

Sub NavLinkItem (text As String, href As String, icon_cls As String, icon_title As String) As MiniHtml
	Return Li.cls("nav-item d-block d-lg-block").down(Anchor).attr("href", href).cls("nav-link float-end").multiline.down(Icon).cls(icon_cls).attr("title", icon_title).Parent.multiline.text(text).Parent
End Sub

' (deprecated)
Sub AnchorIcon (cls As String, href As String, title_text As String, icon_class As String) As MiniHtml
	Return HxGet(href, "#modal-content", "", "click").cls(cls).attr("data-bs-target", "#modal-container").attr("data-bs-toggle", "modal").sty("text-decoration: none").down(Icon).cls(icon_class).attr("title", title_text).Parent
End Sub

Sub ButtonClose As MiniHtml
	Return Button.attr("type", "button").cls("btn-close").attr("data-bs-dismiss", "modal")
End Sub

Sub ButtonAdd (text As String, cls As String, hx_get As String, hx_target As String, hx_trigger As String, data_bs_target As String, data_bs_toggle As String) As MiniHtml
	Return Button.cls(cls).attr("hx-get", hx_get).attr("hx-target", hx_target).attr("hx-trigger", hx_trigger).attr("data-bs-target", data_bs_target).attr("data-bs-toggle", data_bs_toggle).down(Icon).cls("bi bi-plus-lg me-2").Parent.text(text)
End Sub

Sub ButtonSubmit (text As String, cls As String) As MiniHtml
	Return Button.attr("type", "submit").cls(cls).text(text)
End Sub

Sub ButtonCancel (text As String, cls As String) As MiniHtml
	Return Button.attr("type", "button").cls(cls).attr("data-bs-dismiss", "modal").text(text)
End Sub

Sub ButtonSearch (text As String, cls As String, hx_post As String, hx_target As String) As MiniHtml
	Return Button.cls(cls).text(text).attr("hx-post", hx_post).attr("hx-target", hx_target).attr("hx-swap", "innerHTML")
End Sub

Sub InputSearch (cls As String, id As String, name As String) As MiniHtml
	Return Input.attr("type", "text").cls(cls).attr("id", id).attr("name", name)
End Sub

Sub TextLabel (text As String, cls As String, forId As String) As MiniHtml
	Return Label.attr("for", forId).cls(cls).text(text)
End Sub

Sub FormGroup As MiniHtml
	Return Div.cls("form-group")
End Sub

Sub InputGroup As MiniHtml
	Return Div.cls("input-group mb-3")
End Sub

Sub ContainerModal As MiniHtml
	Return Div.attr("id", "modal-container").cls("modal fade").attr("tabindex", "-1").attr("aria-hidden", "true").down(Div).cls("modal-dialog modal-dialog-centered").down(Div(False)).cls("modal-content").attr("id", "modal-content").Parent.Parent
End Sub

Sub ContainerToast As MiniHtml
	Return Div.cls("position-fixed end-0 p-3").sty("z-index: 2000").sty("bottom: 0%").down(Div).attr("id", "toast-container").cls("toast align-items-center text-bg-success border-0").attr("role", "alert").down(Div).cls("d-flex").down(Div.uniline).cls("toast-body").attr("id", "toast-body").text("Operation successful!").Parent.down(ButtonClose.uniline).cls("btn-close-white me-2 m-auto").attr("data-bs-dismiss", "toast").Parent.Parent.Parent
End Sub

Sub ModalHeader (text As String) As MiniHtml
	Return Div.cls("modal-header").down(H5).cls("modal-title").text(text).Parent.down(ButtonClose).Parent
End Sub

Sub ModalBody As MiniHtml
	Return Div.cls("modal-body")
End Sub

Sub ModalMessage As MiniHtml
	Return Div.attr("id", "modal-messages")
End Sub

Sub ModalFooter (Submit_text As String, Cancel_text As String, Submit_class As String, Cancel_class As String) As MiniHtml
	Dim div1 As MiniHtml = Div.cls("modal-footer")
	ButtonSubmit(Submit_text, "btn btn-" & Submit_class & " px-3").up(div1)
	ButtonCancel(Cancel_text, "btn btn-" & Cancel_class & " px-3").up(div1)
	Return div1
End Sub

Sub OptionDisabled (text As String) As MiniHtml
	Return Option.text(text).attr("value", "").disabled
End Sub

Sub OptionSelected (text As String, value As String, selected As Boolean) As MiniHtml
	Return Option.text(text).attr("value", value).selectedIf(selected)
End Sub

Sub ResponsiveHeader As MiniHtml
	Return Head.down(Meta).attr("charset", "utf-8").Parent.down(Meta).attr("name", "viewport").attr("content", "width=device-width, initial-scale=1").Parent
End Sub

Sub CopyrightFooter As MiniHtml
	Return Footer.cls("footer mt-auto py-3 bg-body-tertiary border-top").down _
	(Div).cls("footer small text-center d-md-block").sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif").wrapAttributes.down _
	(Caption(True)).text("$APP_COPYRIGHT$").down(Br).Parent.text("Made with ").down _
	(Span(True)).sty("color: red").down(Icon).cls("bi bi-heart").Parent.Parent.text(" in B4X").Parent.Parent
End Sub

' ============================
' Custom Components
' ============================

Sub Alert (info As AlertInfo) As String
	Return Div.cls("alert alert-" & info.Status).text(info.Message).build
End Sub

Sub Toast (id As String, table1 As MiniHtml, info As ToastInfo) As String
	Return Div.attr("id", id).attr("hx-swap-oob", "true").add(table1).build & CRLF & CreateCustomEventScript(info).Generate
End Sub

Sub CreateCustomEventScript (info As ToastInfo) As MiniJs
	Dim s As MiniJs = CreateMiniJs
	s.AddCustomEventDispatch("entity:changed", CreateMap("entity": info.Entity, "action": info.Action, "message": info.Message, "status": info.Status))
	Return s
End Sub

Sub CreateAlertInfo (Message As String, Status As String) As AlertInfo
	Dim t1 As AlertInfo
	t1.Initialize
	t1.Message = Message
	t1.Status = Status
	Return t1
End Sub

Sub CreateToastInfo (Entity As String, Action As String, Message As String, Status As String) As ToastInfo
	Dim t1 As ToastInfo
	t1.Initialize
	t1.Entity = Entity
	t1.Action = Action
	t1.Message = Message
	t1.Status = Status
	Return t1
End Sub