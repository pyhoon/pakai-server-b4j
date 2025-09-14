B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'Web Handler class
'Version 5.10
Sub Class_Globals
	Private App As EndsMeet
	Private Api As ApiSettings	
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private Method As String
	Private Elements() As String
End Sub

Public Sub Initialize
	App = Main.app
	Api = App.api
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 2) ' 2 For Web handler
	If App.MethodAvailable2(Method, "/categories", Me) = False Then
		WebApiUtils.ReturnHtml("<h1>405 Method Not Allowed</h1>", Response)
		Return
	End If
	If Elements.Length = 0 Then
		ReturnPage
		Return
	End If
	WebApiUtils.ReturnHtmlPageNotFound(Response)
End Sub

Private Sub ReturnPage
	Dim strScripts As String
	Dim strMain As String = WebApiUtils.ReadTextFile("main.html")
	Dim strView As String = WebApiUtils.ReadTextFile("category.html")
	strMain = WebApiUtils.BuildDocView(strMain, strView)
	strMain = WebApiUtils.BuildTag(strMain, "HELP", ReturnHelpElement)
	strMain = WebApiUtils.BuildHtml(strMain, App.ctx)
	strScripts = $"<script src="${App.ServerUrl}/assets/scripts/category.js"></script>"$
	strMain = WebApiUtils.BuildScript(strMain, strScripts)
	WebApiUtils.ReturnHTML(strMain, Response)
End Sub

Private Sub ReturnHelpElement As String
	If Api.EnableHelp = False Then
		Return ""
	End If
	Return $"${CRLF & TAB & TAB}<li class="nav-item mt-1 ml-3">
${TAB & TAB & TAB}<a class="nav-link font-weight-bold text-dark mr-3" href="${App.ServerUrl}/help"><i class="fas fa-cog mr-2" title="API"></i>API</a>
${TAB & TAB}</li>"$
End Sub