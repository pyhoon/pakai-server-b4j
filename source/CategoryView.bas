B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
Sub Class_Globals
	Private DB As MiniORM
End Sub

Public Sub Initialize
	DB.Initialize(Main.DBType, Null)
End Sub

Public Sub Render As List
	Dim Tags As List
	Tags.Initialize
	Tags.Add(Html.comment2(" Content Begin "))
	Tags.Add(CategoryContent)
	Tags.Add(Html.comment2(" Content End "))
	Tags.Add(Html.comment2(" Modal Begin "))
	Tags.Add(ModalCategoryAdd)
	Tags.Add(ModalCategoryEdit)
	Tags.Add(ModalCategoryDelete)
	Tags.Add(Html.comment2(" Modal End "))
	Return Tags
End Sub

Private Sub CategoryContent As Tag
	Dim content1 As Tag = Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As Tag = Div.cls("col-md-12 col-lg-6").up(content1)
	Dim row1 As Tag = Form.cls("form mb-3").action("").up(col1).add(Div.cls("row"))
	Div.cls("col-md-6 col-lg-6 text-start").up(row1) _
    .add(H3.text("CATEGORY LIST"))
	Dim div1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = div1.add(Div.cls("text-end mt-2"))
	div2.add(Anchor.href("$SERVER_URL$").cls("btn btn-primary mb-2 me-2") _
	.add2(Icon.cls("ti ti-home me-2")).text("Home"))
	div2.add(Anchor.href("#new").cls("btn btn-success mb-2 ml-2") _
	.attr("data-bs-toggle", "modal") _
	.attr("data-bs-target", "#new") _
	.add2(Icon.cls("ti ti-plus me-2")).text("New Category"))
	Dim results As Tag = Div.id("results").cls("table").up(col1)
	Dim table1 As Tag = results.add(HtmlTable.cls("table table-bordered rounded small"))
	table1.hxGet("/categories/table").hxTrigger("load").hxSwap("outerHTML")
	table1.add(Tr.init).add(Td.cls("text-center").text("No results"))
	Return content1
End Sub

Private Sub ModalCategoryAdd As Tag
	Dim modal1 As Tag = Div.cls("modal fade").id("new").attr2(CreateMap("tabindex": "-1", "role": "dialog", "aria-labelledby": "newModalLabel", "aria-hidden": "true"))
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").attr("role", "document").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim formAdd As Tag = Form.id("add_form").up(modalContent)
	Dim modalHeader As Tag = Div.cls("modal-header").up(formAdd)
	Dim modalBody As Tag = Div.cls("modal-body").up(formAdd)
	Dim modalFooter As Tag = Div.cls("modal-footer").up(formAdd)
	modalHeader.add(H5.cls("modal-title fs-5").text("New Category"))
	Dim buttonMap As Map = CreateMap("data-bs-dismiss": "modal", "aria-label": "Close")
	modalHeader.add(Button.typeOf("button").cls("btn-close").attr2(buttonMap))
	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Name ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Input.typeOf("text").id("name").name("category_name").cls("form-control").attr3("required"))
	modalFooter.add(Button.typeOf("submit").cls("btn btn-success").id("add").text(" Create "))
	Dim InputMap As Map = CreateMap("data-bs-dismiss": "modal", "value": " Cancel ")
	modalFooter.add(Input.typeOf("button").cls("btn btn-default").attr2(InputMap))
	Return modal1
End Sub

Private Sub ModalCategoryEdit As Tag
	Dim modal1 As Tag = Div.cls("modal fade").id("edit").attr2(CreateMap("tabindex": "-1", "role": "dialog", "aria-labelledby": "editModalLabel", "aria-hidden": "true"))
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").attr("role", "document").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim formEdit As Tag = Form.id("update_form").up(modalContent)
	Dim modalHeader As Tag = Div.cls("modal-header").up(formEdit)
	Dim modalBody As Tag = Div.cls("modal-body").up(formEdit)
	Dim modalFooter As Tag = Div.cls("modal-footer").up(formEdit)
	modalHeader.add(H5.cls("modal-title").text("Edit Category"))
	Dim buttonMap As Map = CreateMap("data-bs-dismiss": "modal", "aria-label": "Close")
	modalHeader.add(Button.typeOf("button").cls("btn-close").attr2(buttonMap))
	modalBody.add(Input.typeOf("hidden").id("id1").name("id").cls("form-control"))
	modalBody.add(Div.cls("form-group")) _
	.add(Label.text("Name ")).add2(Span.cls("text-danger").text("*")) _
	.sib(Input.typeOf("text").id("name1").name("category_name").cls("form-control").attr3("required"))
	modalFooter.add(Button.typeOf("submit").cls("btn btn-primary").id("update").text("Update"))
	Dim ButtonAttribute2 As Map = CreateMap("data-bs-dismiss": "modal", "value": "Cancel")
	modalFooter.add(Input.typeOf("button").cls("btn btn-default").attr2(ButtonAttribute2))
	Return modal1
End Sub

Private Sub ModalCategoryDelete As Tag
	Dim modal1 As Tag = Div.cls("modal fade").id("delete").attr2(CreateMap("tabindex": "-1", "role": "dialog", "aria-labelledby": "deleteModalLabel", "aria-hidden": "true"))
	Dim modalDialog As Tag = Div.cls("modal-dialog modal-dialog-centered").attr("role", "document").up(modal1)
	Dim modalContent As Tag = Div.cls("modal-content").up(modalDialog)
	Dim formDelete As Tag = Form.id("delete_form").up(modalContent)
	Dim modalHeader As Tag = Div.cls("modal-header").up(formDelete)
	Dim modalBody As Tag = Div.cls("modal-body").up(formDelete)
	Dim modalFooter As Tag = Div.cls("modal-footer").up(formDelete)
	modalHeader.add(H5.cls("modal-title").id("deleteModalLabel").text("Delete Category"))
	Dim buttonMap As Map = CreateMap("data-bs-dismiss": "modal", "aria-label": "Close")
	modalHeader.add(Button.typeOf("button").cls("btn-close").attr2(buttonMap))
	modalBody.add(Input.typeOf("hidden").id("id2").name("id").cls("form-control"))
	modalBody.add(Div.cls("form-group")) _
	.add(Paragraph.id("name2")) _
	.sib(Paragraph.text("Are you sure you want to delete this Category?"))
	modalFooter.add(Button.typeOf("button").cls("btn btn-danger").id("remove").text("Delete"))
	Dim ButtonAttribute2 As Map = CreateMap("data-bs-dismiss": "modal", "value": "Cancel")
	modalFooter.add(Input.typeOf("button").cls("btn btn-default").attr2(ButtonAttribute2))
	Return modal1
End Sub

Public Sub RenderTable (Response As ServletResponse)
	Dim table1 As Tag = HtmlTable.cls("table table-bordered rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Name"))
	thead1.add(Th.sty("text-align: center; width: 90px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)
	
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	For Each row As Map In DB.Results2
		Dim tr1 As Tag = tbody1.add(Tr.init)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(row.Get("id")))
		tr1.add(Td.cls("align-middle").text(row.Get("name")))
		Dim td1 As Tag = tr1.add(Td.init)
		Dim anchor1 As Tag = td1.add(Anchor.href("#edit").cls("edit text-primary mx-2").data("bs-toggle", "modal"))
		Dim icon1 As Tag = anchor1.add(Icon.cls("ti ti-pencil").sty("font-weight: bold"))
		icon1.data("bs-toggle", "tooltip") _
		.data("bs-id", row.Get("id")) _
		.data("bs-name", row.Get("name")) _
		.attr("title", "Edit")
		
		Dim anchor2 As Tag = td1.add(Anchor.href("#delete").cls("delete text-danger mx-2").data("bs-toggle", "modal"))
		Dim icon2 As Tag = anchor2.add(Icon.cls("ti ti-trash").sty("font-weight: bold"))
		icon2.data("bs-toggle", "tooltip") _
		.data("bs-id", row.Get("id")) _
		.data("bs-name", row.Get("name")) _
		.attr("title", "Delete")
	Next
	DB.Close
	WebApiUtils.ReturnHtml(table1.Build, Response)
End Sub

Public Sub RenderDropdown (Response As ServletResponse)
	Dim option1 As Tag = Option.attr("selected", "").attr("disabled", "").text("Select Category")
	WebApiUtils.ReturnHtml(option1.Build, Response)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	For Each row As Map In DB.Results2
		Dim option1 As Tag = Option.valueOf(row.Get("id")).text(row.Get("name"))
		WebApiUtils.ReturnHtml(option1.Build, Response)
	Next
	DB.Close
End Sub