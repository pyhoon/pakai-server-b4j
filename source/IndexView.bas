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

Public Sub ReturnTags As List
	Dim Tags As List
	Tags.Initialize
	Tags.Add(Html.comment2(" Content Begin "))
	Dim content1 As Tag = Div.cls("row mt-3")
	Dim col12 As Tag = content1.add(Div.cls("col-md-12"))
	Dim form1 As Tag = col12.add(Form.cls("form mb-3").id("search_form").action(""))
	Dim row1 As Tag = form1.add(Div.cls("row"))
	
	Dim col1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim input_group1 As Tag = col1.add(Div.cls("input-group mb-3"))
	input_group1.add(Label.forId("keyword").cls("input-group-text mt-2").text("Search"))
	input_group1.add(Input.cls("form-control col-md-6 mt-2").typeOf("text").id("keyword").name("keyword"))
	input_group1.add(Button.cls("btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2").typeOf("button").id("btnsearch").text("Submit"))
	
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = col2.add(Div.cls("float-end mt-2"))
	div2.add(Anchor.href("$SERVER_URL$/categories").cls("btn btn-primary me-2").add2(Icon.cls("ti ti-menu me-2")).text("Show Category"))
	div2.add(Anchor.href("#new").cls("btn btn-success").data("toggle", "modal").add2(Icon.cls("ti ti-plus me-2")).text("New Product"))
	col12.add(Div.id("results").cls("table")).add(HtmlTable.cls("table table-bordered rounded-3"))
	Tags.Add(content1)
	
	Dim github As Tag = Div.cls("text-center mb-3")
	github.add(Anchor.href("https://github.com/pyhoon/pakai-server-b4j").cls("text-primary mr-1") _
	.attr("aria-label", "github").title("GitHub").targetOf("_blank")) _
	.add(Svg.aria("hidden", "true").width("24").height("24").attr("version", "1.1").attr("viewBox", "0 0 16 16")) _
	.add(Html.create("path").attr("fill-rule", "evenodd").attr("d", "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"))
	github.add(Anchor.href("https://github.com/pyhoon/pakai-server-b4j").sty("text-decoration: none").targetOf("_blank")) _
	.add(Span.sty("vertical-align: middle").text("Visit my GitHub repository"))
	Tags.Add(github)
	Tags.Add(Html.comment2(" Content End "))
	Tags.Add(Html.comment2(" Modal Begin "))
	Tags.Add(ModalProductAdd)
	Tags.Add(ModalProductEdit)
	Tags.Add(ModalProductDelete)
	Tags.Add(Html.comment2(" Modal End "))
	Return Tags
End Sub

Private Sub ModalProductAdd As Tag
	Dim modal1 As Tag = Div.cls("modal fade").id("new").attr2(CreateMap("tabindex": "-1", "role": "dialog", "aria-labelledby": "newModalLabel", "aria-hidden": "true"))
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").attr("role", "document").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim formAdd As Tag = Form.id("add_form").up(modalContent)
	Dim modalHeader As Tag = Div.cls("modal-header").up(formAdd)
	Dim modalBody As Tag = Div.cls("modal-body").up(formAdd)
	Dim modalFooter As Tag = Div.cls("modal-footer").up(formAdd)
	modalHeader.add(H5.cls("modal-title").text("New Product"))
	Dim buttonMap As Map = CreateMap("data-dismiss": "modal", "aria-hidden": "true")
	modalHeader.add(Button.typeOf("button").cls("close").attr2(buttonMap).text("&times;"))
	
	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Category ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Dropdown.id("category1").name("category_id").cls("form-control").attr3("required")) _
	.add(Option.attr("value", "").attr("disabled", "").text("Select Category"))

	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Code ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Input.typeOf("text").id("code").name("category_code").cls("form-control").attr3("required"))

	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Name ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Input.typeOf("text").id("name").name("category_name").cls("form-control").attr3("required"))

	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Price ")) _
	.sib(Input.typeOf("text").id("price").name("category_price").cls("form-control"))

	modalFooter.add(Button.typeOf("submit").cls("btn btn-success").id("add").text("Create"))
	Dim InputMap As Map = CreateMap("data-dismiss": "modal", "value": "Cancel")
	modalFooter.add(Input.typeOf("button").cls("btn btn-default").attr2(InputMap))
	Return modal1
End Sub

Private Sub ModalProductEdit As Tag
	Dim modal1 As Tag = Div.cls("modal fade").id("edit").attr2(CreateMap("tabindex": "-1", "role": "dialog", "aria-labelledby": "editModalLabel", "aria-hidden": "true"))
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").attr("role", "document").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim formEdit As Tag = Form.id("update_form").up(modalContent)
	Dim modalHeader As Tag = Div.cls("modal-header").up(formEdit)
	Dim modalBody As Tag = Div.cls("modal-body").up(formEdit)
	Dim modalFooter As Tag = Div.cls("modal-footer").up(formEdit)
	modalHeader.add(H5.cls("modal-title").text("Edit Product"))
	Dim buttonMap As Map = CreateMap("data-dismiss": "modal", "aria-hidden": "true")
	modalHeader.add(Button.typeOf("button").cls("close").attr2(buttonMap).text("&times;"))
	
	modalBody.add(Input.typeOf("hidden").id("id1").name("id").cls("form-control"))

	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Category ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Dropdown.id("category2").name("category_id").cls("form-control").attr3("required")) _
	.add(Option.attr("value", "").attr("disabled", "").text("Select Category"))
		
	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Code ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Input.typeOf("text").id("code1").name("category_code").cls("form-control").attr3("required"))

	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Name ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Input.typeOf("text").id("name1").name("category_name").cls("form-control").attr3("required"))
	
	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Price ")) _
	.sib(Input.typeOf("text").id("price1").name("category_price").cls("form-control"))
	
	modalFooter.add(Button.typeOf("submit").cls("btn btn-primary").id("update").text("Update"))
	Dim ButtonAttribute2 As Map = CreateMap("data-dismiss": "modal", "value": "Cancel")
	modalFooter.add(Input.typeOf("button").cls("btn btn-default").attr2(ButtonAttribute2))
	Return modal1
End Sub

Private Sub ModalProductDelete As Tag
	Dim modal1 As Tag = Div.cls("modal fade").id("delete").attr2(CreateMap("tabindex": "-1", "role": "dialog", "aria-labelledby": "deleteModalLabel", "aria-hidden": "true"))
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").attr("role", "document").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim formDelete As Tag = Form.id("delete_form").up(modalContent)
	Dim modalHeader As Tag = Div.cls("modal-header").up(formDelete)
	Dim modalBody As Tag = Div.cls("modal-body").up(formDelete)
	Dim modalFooter As Tag = Div.cls("modal-footer").up(formDelete)
	modalHeader.add(H5.cls("modal-title").id("deleteModalLabel").text("Delete Product"))
	Dim buttonMap As Map = CreateMap("data-dismiss": "modal", "aria-hidden": "true")
	modalHeader.add(Button.typeOf("button").cls("close").attr2(buttonMap).text("&times;"))
	
	modalBody.add(Input.typeOf("hidden").id("id2").name("id").cls("form-control"))
	
	modalBody.add(Div.cls("form-group")) _
	.add(Paragraph.id("code_name")) _
	.sib(Paragraph.text("Are you sure you want to delete this Category?"))
	
	modalFooter.add(Button.typeOf("button").cls("btn btn-danger").id("remove").text("Delete"))
	Dim ButtonAttribute2 As Map = CreateMap("data-dismiss": "modal", "value": "Cancel")
	modalFooter.add(Input.typeOf("button").cls("btn btn-default").attr2(ButtonAttribute2))
	Return modal1
End Sub