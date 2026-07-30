B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.5
@EndOfDesignText@
'MiniHtml Cache
'Version: 3.30
Sub Process_Globals

End Sub

Public Sub ExistInCache (ctx As Map, Key As String) As Boolean
	Return ctx.ContainsKey(Key)
End Sub

Public Sub WriteToCache (ctx As Map, Key As String, Value As Object)
	ctx.Put(Key, Value)
End Sub

Public Sub ReadFromCache (ctx As Map, Key As String) As Object
	Dim val As Object = ctx.Get(Key)
	If val Is MiniHtml Then
		Return val.As(MiniHtml)
	Else If GetType(val) = "[B" Then
		Return ConvertFromBytes(val)
	Else
		Return val
	End If
End Sub

Public Sub ConvertFromBytes (Buffer() As Byte) As MiniHtml
	Dim s As String = BytesToString(Buffer, 0, Buffer.Length, "UTF-8")
	Dim m As MiniHtml
	m.Initialize("")
	Return m.Parse(s)
End Sub