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
Public Sub CMH (Name As String) As MiniHtml
	Dim tn As MiniHtml
	tn.Initialize(Name)
	Return tn
End Sub

Public Sub CreateMiniJs As MiniJs
	Dim s As MiniJs
	s.Initialize
	Return s
End Sub

Public Sub Anchor As MiniHtml
	Return CMH("a")
End Sub

Public Sub Button As MiniHtml
	Return CMH("button")
End Sub

Public Sub Div As MiniHtml
	Return CMH("div")
End Sub

Public Sub Span As MiniHtml
	Return CMH("span")
End Sub

Public Sub Br As MiniHtml
	Return CMH("br")
End Sub

Public Sub Nav As MiniHtml
	Return CMH("nav")
End Sub

Public Sub Form As MiniHtml
	Return CMH("form")
End Sub

Public Sub H3 As MiniHtml
	Return CMH("h3")
End Sub

Public Sub H5 As MiniHtml
	Return CMH("h5")
End Sub

Public Sub P As MiniHtml
	Return CMH("p")
End Sub

Public Sub Html As MiniHtml
	Return CMH("html").lang("en")
End Sub

Public Sub Head As MiniHtml
	Return CMH("head")
End Sub

Public Sub Title As MiniHtml
	Return CMH("title")
End Sub

Public Sub Meta As MiniHtml
	Return CMH("meta")
End Sub

Public Sub Link As MiniHtml
	Return CMH("link")
End Sub

Public Sub Script As MiniHtml
	Return CMH("script")
End Sub

Public Sub Body As MiniHtml
	Return CMH("body")
End Sub

Public Sub Icon As MiniHtml
	Return CMH("i")
End Sub

Public Sub Input As MiniHtml
	Return CMH("input")
End Sub

Public Sub Label As MiniHtml
	Return CMH("label")
End Sub

Public Sub Caption As MiniHtml
	Return CMH("caption")
End Sub

Public Sub Footer As MiniHtml
	Return CMH("footer")
End Sub

Public Sub Table As MiniHtml
	Return CMH("table")
End Sub

Public Sub Tbody As MiniHtml
	Return CMH("tbody")
End Sub

Public Sub Td As MiniHtml
	Return CMH("td")
End Sub

Public Sub Th As MiniHtml
	Return CMH("th")
End Sub

Public Sub Thead As MiniHtml
	Return CMH("thead")
End Sub

Public Sub Tr As MiniHtml
	Return CMH("tr")
End Sub

Public Sub Ul As MiniHtml
	Return CMH("ul")
End Sub

Public Sub Li As MiniHtml
	Return CMH("li")
End Sub

Public Sub SelectTag As MiniHtml
	Return CMH("select")
End Sub

Public Sub Option As MiniHtml
	Return CMH("option")
End Sub

' ============================
'  Bootstrap Layout Helpers
' ============================

Public Sub ContainerFluid As MiniHtml
	Return Div.cls("container-fluid")
End Sub

Public Sub Row As MiniHtml
	Return Div.cls("row")
End Sub

Public Sub Col (cols As String) As MiniHtml
	Return Div.cls("col-" & cols)
End Sub

Public Sub HiddenInput (id As String, name As String, value As String) As MiniHtml
	Return Input.attr("type", "hidden").attrsIfValues(CreateMap("id": id, "name": name, "value": value))
End Sub

Public Sub RequiredLabel (text As String, forId As String) As MiniHtml
	Return Label.attrIfvalue("for", forId).text(text).down(Span).cls("text-danger").text("*").Parent
End Sub

Public Sub RequiredTextInput (id As String, name As String, value As String) As MiniHtml
	Return Input.attr("type", "text").cls("form-control").attrsIfValues(CreateMap("id": id, "name": name, "value": value)).required
End Sub

Public Sub RequiredDropdown (id As String, name As String) As MiniHtml
	Return SelectTag.cls("form-select").attrsIfValues(CreateMap("id": id, "name": name)).required
End Sub

' ============================
'  HTMX Helpers
' ============================

Public Sub HxGet (href As String, target As String, swap As String, trigger As String) As MiniHtml
	Return Anchor.attr("hx-get", href).attrsIfValues(CreateMap("hx-target": target, "hx-swap": swap, "hx-trigger": trigger))
End Sub

Public Sub ContainerHxGet (id As String, href As String, trigger As String, text As String) As MiniHtml
	Return Div.attr("id", id).attr("hx-get", href).attr("hx-trigger", trigger).text(text)
End Sub

Public Sub FormHxPost (href As String, target As String) As MiniHtml
	Return FormHx("post", href, target)
End Sub

Public Sub FormHxPut (href As String, target As String) As MiniHtml
	Return FormHx("put", href, target)
End Sub

Public Sub FormHxDelete (href As String, target As String) As MiniHtml
	Return FormHx("delete", href, target)
End Sub

Public Sub FormHx (verb As String, href As String, target As String) As MiniHtml
	Return Form.attr("hx-"& verb, href).attr("hx-target", target).attr("hx-swap", "innerHTML")
End Sub

' ============================
'  Navigation Helpers
' ============================

'Navbar with "container-fluid" class div, 2 "navbar-brand" class anchors and an icon class
Public Sub NavbarExpand (cls As String, expand As String, brand_icon_cls As String, brand_text As String) As MiniHtml
	Return Nav.cls("navbar navbar-expand-" & expand).clsIf(cls <> "", cls).down(ContainerFluid).down(Anchor).cls("navbar-brand").attr("href", "#").down(Icon).cls(brand_icon_cls).Parent.Parent.down(Anchor).cls("navbar-brand").attr("href", "$SERVER_URL$").text(brand_text).Parent.Parent
End Sub

Public Sub NavbarToggler As MiniHtml
	Return Button.cls("navbar-toggler d-md-block d-lg-none collapsed").attr("type", "button").attr("data-bs-toggle", "collapse").attr("data-bs-target", "#navbarCollapse").sty("border: none").down(Span).cls("navbar-toggler-icon").Parent
End Sub

Public Sub NavbarCollapse As MiniHtml
	Return Div.cls("collapse navbar-collapse").attr("id", "navbarCollapse").down(Ul).cls("navbar-nav navbar-brand ms-auto mb-md-0").Parent
End Sub

Public Sub NavLinkItem (text As String, href As String, icon_cls As String, icon_title As String) As MiniHtml
	Return Li.cls("nav-item d-block d-lg-block").down(Anchor).attr("href", href).cls("nav-link float-end").multiline.down(Icon).cls(icon_cls).attr("title", icon_title).Parent.multiline.text(text).Parent
End Sub

' (deprecated)
Public Sub AnchorIcon (cls As String, href As String, title_text As String, icon_class As String) As MiniHtml
	Return HxGet(href, "#modal-content", "", "click").cls(cls).attr("data-bs-target", "#modal-container").attr("data-bs-toggle", "modal").down(Icon).cls(icon_class).attr("title", title_text).Parent
End Sub

Public Sub ButtonClose As MiniHtml
	Return Button.attr("type", "button").cls("btn-close").attr("data-bs-dismiss", "modal")
End Sub

Public Sub ButtonAdd (text As String, cls As String, hx_get As String, hx_target As String, hx_trigger As String, data_bs_target As String, data_bs_toggle As String) As MiniHtml
	Return Button.cls(cls).attr("hx-get", hx_get).attr("hx-target", hx_target).attr("hx-trigger", hx_trigger).attr("data-bs-target", data_bs_target).attr("data-bs-toggle", data_bs_toggle).down(Icon).cls("bi bi-plus-lg me-2").Parent.text(text)
End Sub

Public Sub ButtonSubmit (text As String, cls As String) As MiniHtml
	Return Button.attr("type", "submit").cls(cls).text(text)
End Sub

Public Sub ButtonCancel (text As String, cls As String) As MiniHtml
	Return Button.attr("type", "button").cls(cls).attr("data-bs-dismiss", "modal").text(text)
End Sub

Public Sub ButtonSearch (text As String, cls As String, hx_post As String, hx_target As String) As MiniHtml
	Return Button.cls(cls).text(text).attr("hx-post", hx_post).attr("hx-target", hx_target).attr("hx-swap", "innerHTML")
End Sub

Public Sub InputSearch (cls As String, id As String, name As String) As MiniHtml
	Return Input.attr("type", "text").cls(cls).attr("id", id).attr("name", name)
End Sub

Public Sub TextLabel (text As String, cls As String, forId As String) As MiniHtml
	Return Label.attr("for", forId).cls(cls).text(text)
End Sub

Public Sub FormGroup As MiniHtml
	Return Div.cls("form-group")
End Sub

Public Sub InputGroup As MiniHtml
	Return Div.cls("input-group mb-3")
End Sub

Public Sub ContainerModal As MiniHtml
	Return Div.attr("id", "modal-container").cls("modal fade").attr("tabindex", "-1").attr("aria-hidden", "true").down(Div.cls("modal-dialog modal-dialog-centered")).down(Div.cls("modal-content").attr("id", "modal-content")).Parent.Parent
End Sub

Public Sub ContainerToast As MiniHtml
	Return Div.cls("position-fixed end-0 p-3").sty("z-index: 2000").sty("bottom: 0%").down(Div.attr("id", "toast-container").cls("toast align-items-center text-bg-success border-0").attr("role", "alert")).down(Div.cls("d-flex")).down(Div.cls("toast-body").attr("id", "toast-body").text("Operation successful!")).Parent.down(ButtonClose.cls("btn-close-white me-2 m-auto").attr("data-bs-dismiss", "toast")).Parent.Parent.Parent
End Sub

Public Sub ModalHeader (text As String) As MiniHtml
	Return Div.cls("modal-header").down(H5).cls("modal-title").text(text).Parent.down(ButtonClose).Parent
End Sub

Public Sub ModalBody As MiniHtml
	Return Div.cls("modal-body")
End Sub

Public Sub ModalMessage As MiniHtml
	Return Div.attr("id", "modal-messages")
End Sub

Public Sub ModalFooter (Submit_text As String, Cancel_text As String, Submit_class As String, Cancel_class As String) As MiniHtml
	Dim div1 As MiniHtml = Div.cls("modal-footer")
	ButtonSubmit(Submit_text, "btn btn-" & Submit_class & " px-3").up(div1)
	ButtonCancel(Cancel_text, "btn btn-" & Cancel_class & " px-3").up(div1)
	Return div1
End Sub

Public Sub OptionDisabled (text As String) As MiniHtml
	Return Option.text(text).attr("value", "").disabled
End Sub

Public Sub OptionSelected (text As String, value As String, selected As Boolean) As MiniHtml
	Return Option.text(text).attr("value", value).selectedIf(selected)
End Sub

Public Sub ResponsiveHeader As MiniHtml
	Return Head.down(Meta).attr("charset", "utf-8").Parent.down(Meta).attr("name", "viewport").attr("content", "width=device-width, initial-scale=1").Parent
End Sub

Public Sub CopyrightFooter As MiniHtml
	Return Footer.cls("footer mt-auto py-3 bg-body-tertiary border-top").down(Div).cls("footer small text-center d-md-block").sty("font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif").down(Caption).text("$APP_COPYRIGHT$").down(Br).Parent.text("Made with ").down(Span).sty("color: red").down(Icon).cls("bi bi-heart").Parent.Parent.text(" in B4X").Parent.Parent
End Sub

' ============================
' Custom Components
' ============================

Public Sub Alert (info As AlertInfo) As String
	Return Div.cls("alert alert-" & info.Status).text(info.Message).build
End Sub

Public Sub Toast (id As String, table1 As MiniHtml, info As ToastInfo) As String
	Return Div.attr("id", id).attr("hx-swap-oob", "true").add(table1).build & CRLF & CreateCustomEventScript(info).Generate
End Sub

Public Sub CreateCustomEventScript (info As ToastInfo) As MiniJs
	Dim s As MiniJs = CreateMiniJs
	s.AddCustomEventDispatch("entity:changed", CreateMap("entity": info.Entity, "action": info.Action, "message": info.Message, "status": info.Status))
	Return s
End Sub

Public Sub CreateAlertInfo (Message As String, Status As String) As AlertInfo
	Dim t1 As AlertInfo
	t1.Initialize
	t1.Message = Message
	t1.Status = Status
	Return t1
End Sub

Public Sub CreateToastInfo (Entity As String, Action As String, Message As String, Status As String) As ToastInfo
	Dim t1 As ToastInfo
	t1.Initialize
	t1.Entity = Entity
	t1.Action = Action
	t1.Message = Message
	t1.Status = Status
	Return t1
End Sub