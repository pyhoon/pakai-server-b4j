B4J=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=10.3
@EndOfDesignText@
'JavaScript Code Module
'Version 5.50
Sub Process_Globals
	Private Api	As ApiSettings
	Private XmlRoot As String = "root"
	Private XmlElement As String = "item"
	Private ContentType As String
	Private Verbose As Boolean
	Private Const RESPONSE_ELEMENT_MESSAGE 	As String = "m"
	Private Const RESPONSE_ELEMENT_CODE 	As String = "a"
	Private Const RESPONSE_ELEMENT_STATUS 	As String = "s"
	Private Const RESPONSE_ELEMENT_TYPE 	As String = "t" 'ignore
	Private Const RESPONSE_ELEMENT_ERROR 	As String = "e"
	Private Const RESPONSE_ELEMENT_RESULT 	As String = "r"
End Sub

' Generate JS files from code to save some file size
Public Sub CreateJSFiles
	Dim skip As Boolean
	Dim StaticFilesFolder As String = Main.App.staticfiles.Folder
	Dim Parent As String = File.Combine(StaticFilesFolder, "assets")
	Dim DirName As String = File.Combine(Parent, "scripts")
	If File.Exists(DirName, "") = False Then
		File.MakeDir(Parent, "scripts")
	Else
	#If Release
	skip = True ' skip overwriting files in release if scripts folder exists
	#End If
	End If
	If skip = False Then
		Api = Main.App.api
		Verbose = Api.VerboseMode
		ContentType = Api.ContentType
		GenerateJSFileForHelp(DirName, "help.js")
		GenerateJSFileForSearch(DirName, "search.js")
		GenerateJSFileForCategory(DirName, "category.js")
	End If
End Sub

Private Sub AlertScript (AlertMessage As String, SuccessCode As Int, SubmitForm As Boolean) As String
	If Verbose = False Then
		If SubmitForm Then ' indent
			Return $"alert("${AlertMessage}")
          location.reload()"$
		Else
			Return $"alert("${AlertMessage}")
      location.reload()"$
		End If
	End If
	Select ContentType
		Case WebApiUtils.MIME_TYPE_XML
			Return $"const root = $(response).find("${XmlRoot}")
          const code = $(root).children("${RESPONSE_ELEMENT_CODE}").text()
          const error = $(root).children("${RESPONSE_ELEMENT_ERROR}").text()
          if (code == ${SuccessCode}) {
            alert("${AlertMessage}")
            location.reload()
          }
          else {
            alert(code + " " + error)
          }"$
		Case Else
			If SubmitForm Then ' indent
				Return $"const code = response.${RESPONSE_ELEMENT_CODE}
          const error = response.${RESPONSE_ELEMENT_ERROR}
          if (code == ${SuccessCode}) {
            alert("${AlertMessage}")
            location.reload()
          }
          else {
            alert(code + " " + error)
          }"$
			Else
				Return $"const code = response.${RESPONSE_ELEMENT_CODE}
      const error = response.${RESPONSE_ELEMENT_ERROR}
      if (code == ${SuccessCode}) {
        alert("${AlertMessage}")
        location.reload()
      }
      else {
        alert(code + " " + error)
      }"$
			End If
	End Select
End Sub

Private Sub HelpResponsePart (Verb As String) As String
	Dim script As String
	Select Verb
		Case "post"
			script = $"type: "${Verb}",
        data: $("#body" + id).val(),
        dataType: "${dataType}",
        headers: headers,
        success: function (response, textStatus, xhr) {
          showFadeAlertSuccess(id, xhr, textStatus, response)
          ${AccessTokenPart}
        },"$
		Case "put"
			script = $"type: "${Verb}",
        data: $("#body" + id).val(),
        dataType: "${dataType}",
        headers: headers,
        success: function (response, textStatus, xhr) {
          showFadeAlertSuccess(id, xhr, textStatus, response)
        },"$
		Case Else
			script = $"type: "${Verb}",
        dataType: "${dataType}",
        headers: headers,
        success: function (response, textStatus, xhr) {
          showFadeAlertSuccess(id, xhr, textStatus, response)
        },"$
	End Select
	Return script
End Sub

Private Sub AccessTokenPart As String
	' Becareful of "if" -> "If"
	Return $"// Access Token
          let access_token = ""
          ${IIf(dataType = "xml", _
          $"const result = ${IIf(Verbose, $"$(response).children("${RESPONSE_ELEMENT_RESULT}")"$, $"response"$)}
          access_token = $(result).find("token").text()"$, _
          $"const result = ${IIf(Verbose, $"response.${RESPONSE_ELEMENT_RESULT}"$, $"response"$)}"$)}
          if (result.length > 0) {
            if ("access_token" in result[0]) {
              access_token = result[0]["access_token"]
             }
           }
          if (access_token.length > 0) {
            localStorage.setItem("access_token", access_token)
            console.log("access token stored!")
          }
          //else {
          //  console.log("access token not found")	
          //}"$
End Sub

' For jQuery Ajax
Private Sub dataType As String
	Select ContentType
		Case WebApiUtils.MIME_TYPE_XML
			Return "xml"
		Case WebApiUtils.MIME_TYPE_JSON
			Return "json"
		Case Else
			Return ""
	End Select
End Sub

Private Sub script01 As String
	Return $"// Button click event for all verbs
$(".get, .post, .put, .delete").click(function (e) {
  e.preventDefault()
  const element = $(this)
  const id = element.attr("id").substring(3)
  makeApiRequest(id)
})"$
End Sub

Private Sub script02 As String
	Return $"// Function to set options
function setOptions(id) {
  const element = $("#btn" + id)
  const headers = setHeaders(element)
  switch (true) {
    case element.hasClass("get"):
      return {
        ${HelpResponsePart("get")}
        error: function (xhr, textStatus, errorThrown) {
          showFadeAlertError(id, xhr, errorThrown)
        }
      }
      break
    case element.hasClass("post"):
      return {
        ${HelpResponsePart("post")}
        error: function (xhr, textStatus, errorThrown) {
          showFadeAlertError(id, xhr, errorThrown)
        }
      }
      break
    case element.hasClass("put"):
      return {
        ${HelpResponsePart("put")}
        error: function (xhr, textStatus, errorThrown) {
          showFadeAlertError(id, xhr, errorThrown)
        }
      }
      break
    case element.hasClass("delete"):
      return {
        ${HelpResponsePart("delete")}
        error: function (xhr, textStatus, errorThrown) {
          showFadeAlertError(id, xhr, errorThrown)
        }
      }
      break
    default: // unsupported verbs
      return {}
  }
}"$
End Sub

Private Sub script03 As String
	Return $"// Function to return headers base on button class
function setHeaders(element) {
  switch (true) {
    case element.hasClass("basic"):
      return {
        "Accept": "application/json",
        "Authorization": "Basic " + btoa(localStorage.getItem("client_id") + ":" + localStorage.getItem("client_secret"))
      }
      break
    case element.hasClass("token"):
      return {
        "Accept": "application/json",
        "Authorization": "Bearer " + localStorage.getItem("access_token")
      }
      break
    default:
      return {
        "Accept": "application/json"
      }
  }
}"$
End Sub

Private Sub script04 As String
	Return $"// Function to make API call using Ajax
function makeApiRequest(id) {
  const url = $("#path" + id).val()
  const options = setOptions(id)
  $.ajax(url, options)
}"$
End Sub

Private Sub script05 As String
	Select ContentType
		Case WebApiUtils.MIME_TYPE_XML
			If Verbose Then
				Return $"function showFadeAlertSuccess (id, xhr, textStatus, response) {
  const root = $(response).find("${XmlRoot}")
  const status = $(root).children("${RESPONSE_ELEMENT_STATUS}").text()
  const code = $(root).children("${RESPONSE_ELEMENT_CODE}").text()
  const error = $(root).children("${RESPONSE_ELEMENT_ERROR}").text()
  const message = $(root).children("${RESPONSE_ELEMENT_MESSAGE}").text()
  const content = xhr.responseText
  if (status == "ok" || status == "success") {
    $("#alert" + id).fadeOut("fast", function () {
      $("#response" + id).val(content)
      $("#alert" + id).html(code + " " + message)
      $("#alert" + id).removeClass("bg-danger")
      $("#alert" + id).addClass("bg-success")
      $("#alert" + id).fadeIn()
    })
  }
  else {
    $("#alert" + id).fadeOut("fast", function () {
      $("#response" + id).val(content)
      $("#alert" + id).html(code + " " + error)
      $("#alert" + id).removeClass("bg-success")
      $("#alert" + id).addClass("bg-danger")
      $("#alert" + id).fadeIn()
    })
  }
}"$
			Else
				Return $"function showFadeAlertSuccess (id, xhr, textStatus, response) {
  const code = xhr.status
  const message = textStatus
  const content = xhr.responseText
  $("#alert" + id).fadeOut("fast", function () {
    $("#response" + id).val(content)
    $("#alert" + id).html(code + " " + message)
    $("#alert" + id).removeClass("bg-danger")
    $("#alert" + id).addClass("bg-success")
    $("#alert" + id).fadeIn()
  })
}"$
			End If
		Case Else
			If Verbose Then
				Return $"function showFadeAlertSuccess (id, xhr, textStatus, response) {
  const code = response.${RESPONSE_ELEMENT_CODE}
  const error = response.${RESPONSE_ELEMENT_ERROR}
  const message = response.${RESPONSE_ELEMENT_MESSAGE}
  const status = response.${RESPONSE_ELEMENT_STATUS}
  const content = JSON.stringify(response, undefined, 2)
  if (status == "ok" || status == "success") {
    $("#alert" + id).fadeOut("fast", function () {
      $("#response" + id).val(content)
      $("#alert" + id).html(code + " " + message)
      $("#alert" + id).removeClass("bg-danger")
      $("#alert" + id).addClass("bg-success")
      $("#alert" + id).fadeIn()
    })
  }
  else {
    $("#alert" + id).fadeOut("fast", function () {
      $("#response" + id).val(content)
      $("#alert" + id).html(code + " " + error)
      $("#alert" + id).removeClass("bg-success")
      $("#alert" + id).addClass("bg-danger")
      $("#alert" + id).fadeIn()
    })
  }
}"$
			Else
				Return $"function showFadeAlertSuccess (id, xhr, textStatus, response) {
  const code = xhr.status
  const message = textStatus
  const content = xhr.responseText	
  $("#alert" + id).fadeOut("fast", function () {
    $("#response" + id).val(content)
    $("#alert" + id).html(code + " " + message)
    $("#alert" + id).removeClass("bg-danger")
    $("#alert" + id).addClass("bg-success")
    $("#alert" + id).fadeIn()
  })
}"$
			End If
	End Select
End Sub

Private Sub script06 As String
	Return $"function showFadeAlertError (id, xhr, errorThrown) {
  const code = xhr.status
  const error = errorThrown
  const content = xhr.responseText
  $("#alert" + id).fadeOut("fast", function () {
    $("#response" + id).val(content)
    $("#alert" + id).html(code + " " + error)
    $("#alert" + id).removeClass("bg-success")
    $("#alert" + id).addClass("bg-danger")
    $("#alert" + id).fadeIn()
  })
}"$
End Sub

Private Sub script07 As String
	' Escape $ inside smart string literals
	' https://www.b4x.com/android/forum/threads/solved-how-to-escape-a-string-with-the-characters-within.121322/#post-758437
	Return $"$.ajax({
    type: "get",
    dataType: "${dataType}",
    url: "/${Api.Name}/categories",
    success: function (response, status, xhr) {
      let data = []
      ${IIf(ContentType = WebApiUtils.MIME_TYPE_XML, _
      $"// XML format
      const root = $(response).find("${XmlRoot}")
      ${IIf(Verbose, _
	  $"const result = $(root).children("${RESPONSE_ELEMENT_RESULT}")"$, _
	  $"const result = $(root)"$)}
      const $items = $(result).children("${XmlElement}")
      $items.each(function () {
        const $item = $(this)
        data.push({
          id: $item.children("id").text(),
          category_name: $item.children("category_name").text()
        })
      })"$, _
      $"// JSON format
      ${IIf(Verbose, $"data = response.${RESPONSE_ELEMENT_STATUS} === "ok" ? response.${RESPONSE_ELEMENT_RESULT} : []"$, $"data = response"$)}"$)}
      let tblHead = ""
      let tblBody = ""
      if (data.length) {
        tblHead = `
  <thead class="bg-light">
    <th style="text-align: right; width: 50px">#</th>
    <th>Name</th>
    <th style="text-align: center; width: 90px">Actions</th>
  </thead>`
        tblBody = `
  <tbody>`
        $.each(data, function (i, item) {
          const id = item.id || ""
          const name = item.category_name || ""
          //console.log(id, category_name)
          tblBody += `
    <tr>
      <td class="align-middle" style="text-align: right">${"$"}{id}</td>
      <td class="align-middle">${"$"}{name}</td>
      <td>
        <a href="#edit" class="text-primary mx-2" data-toggle="modal">
          <i class="edit fa fa-pen" data-toggle="tooltip"
          data-id="${"$"}{id}" data-name="${"$"}{name}" title="Edit"></i></a>
        <a href="#delete" class="text-danger mx-2" data-toggle="modal">
          <i class="delete fa fa-trash" data-toggle="tooltip"
          data-id="${"$"}{id}" data-name="${"$"}{name}" title="Delete"></i></a>
      </td>
    </tr>`
        })
        tblBody += `
  </tbody>`
      }
      else {
        tblBody = `
  <tbody>
    <tr>
      <td class="text-center">No results</td>
    </tr>
  </tbody>`
      }
      $("#results table").html(tblHead + tblBody)
    },
    error: function (xhr, ajaxOptions, errorThrown) {
      $(".alert").html("Error: " + errorThrown).fadeIn()
    }
  })"$
End Sub

Private Sub script08 As String
	Return $"$(document).on("click", ".edit", function (e) {
  const id = $(this).attr("data-id")
  const name = $(this).attr("data-name")
  $("#id1").val(id)
  $("#name1").val(name)
})"$
End Sub

Private Sub script09 As String
	Return $"$(document).on("click", ".delete", function (e) {
  const id = $(this).attr("data-id")
  const name = $(this).attr("data-name")
  $("#id2").val(id)
  $("#name2").text(name)
})"$
End Sub

Private Sub script10 As String
	Return $"$(document).on("click", "#add", function (e) {
  const form = $("#add_form")
  form.validate({
    rules: {
      name: {
        required: true
      },
      action: "required"
    },
    messages: {
      name: {
        required: "Please enter Category Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      ${IIf(dataType = "xml", _
	  $"const data = convertFormToXML(form[0])"$, _
	  $"const data = JSON.stringify(convertFormToJSON(form), undefined, 2)"$)}
      $.ajax({
        type: "post",
        data: data,
        dataType: "${dataType}",
        url: "/${Api.Name}/categories",
        success: function (response) {
          $("#new").modal("hide")
          ${AlertScript("New category added !", 201, True)}
        },
        error: function (xhr, ajaxOptions, errorThrown) {
          alert(errorThrown)
        }
      })
    }
  })
})"$
End Sub

Private Sub script11 As String
	Return $"$(document).on("click", "#update", function (e) {
  const form = $("#update_form")
  form.validate({
    rules: {
      name: {
        required: true
      },
      action: "required"
    },
    messages: {
      name: {
        required: "Please enter Category Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      ${IIf(dataType = "xml", _
	  $"const data = convertFormToXML(form[0])"$, _
	  $"const data = JSON.stringify(convertFormToJSON(form), undefined, 2)"$)}
      $.ajax({
        type: "put",
        data: data,
        dataType: "${dataType}",
        url: "/${Api.Name}/categories/" + $("#id1").val(),
        success: function (response) {
          $("#edit").modal("hide")
          ${AlertScript("Category updated successfully !", 200, True)}
        },
        error: function (xhr, ajaxOptions, errorThrown) {
          alert(errorThrown)
        }
      })
    }
  })
})"$
End Sub

Private Sub script12 As String
	Return $"$(document).on("click", "#remove", function (e) {
  $.ajax({
    type: "delete",
    dataType: "${dataType}",
    url: "/${Api.Name}/categories/" + $("#id2").val(),
    success: function (response) {
      $("#delete").modal("hide")
      ${AlertScript("Category deleted successfully !", 200, False)}
    },
    error: function (xhr, ajaxOptions, errorThrown) {
      alert(errorThrown)
    }
  })
})"$
End Sub

Private Sub script13 As String
	Select dataType
		Case "xml"
			Return $"function convertFormToXML(form) {
  const formData = new FormData(form)
  let xml = `<root>\n`
  for (const [name, value] of formData.entries()) {
    xml += `  <${"$"}{name}>${"$"}{escapeXml(value)}</${"$"}{name}>\n`
  }
  xml += `</root>`
  return xml
}

// Utility function to escape special XML characters
function escapeXml(unsafe) {
  return unsafe.replace(/[<>&'"]/g, function (c) {
    switch (c) {
      case "<": return "&lt;"
      case ">": return "&gt;"
      case "&": return "&amp;"
      case "'": return "&apos;"
      case '"': return "&quot;"
    }
  })
}"$
	Case Else
		Return $"function convertFormToJSON(form) {
  const array = $(form).serializeArray() // Encodes the set of form elements as an array of names and values.
  const json = {}
  $.each(array, function () {
    json[this.name] = this.value || ""
  })
  return json
}"$
	End Select
End Sub

Private Sub script14 As String
	Return $"dataType: "${dataType}",
    url: "/${Api.Name}/find",
    success: function (response, status, xhr) {
      ${IIf(ContentType = WebApiUtils.MIME_TYPE_XML, _
      $"// XML format
	  let rows = []
      const root = $(response).find("${XmlRoot}")
      ${IIf(Verbose, _
      $"const result = $(root).children("${RESPONSE_ELEMENT_RESULT}")"$, _
      $"const result = $(root)"$)}
      const $items = $(result).children("${XmlElement}")
      $items.each(function () {
        const $item = $(this)
        rows.push({
          id: $item.find("id").text(),
          code: $item.find("code").text(),
          name: $item.find("name").text(),
          catid: $item.find("catid").text(),
          category: $item.find("category").text(),
          price: $item.find("price").text()
        })
      })"$, _
      $"// JSON format
      ${IIf(Verbose, _
	  $"const rows = response.${RESPONSE_ELEMENT_STATUS} === "ok" ? response.${RESPONSE_ELEMENT_RESULT} : []"$, _
	  $"const rows = response"$)}"$)}
	  renderTable(rows)
    },
    error: function (xhr, ajaxOptions, errorThrown) {
      $(".alert").html("Error: " + errorThrown).fadeIn()
    }"$
End Sub

Private Sub script15 (functionName As String) As String
	Select functionName
		Case "getFind"
			Return $"function getFind() {
  $.ajax({
    type: "get",
    ${script14}
  })
}"$
		Case "callFindApi"
			Return $"function callFindApi(data) {
  $.ajax({
    type: "post",
    data: data,
    ${script14}
  })
}"$
		Case Else
			Return ""
	End Select
End Sub

Private Sub script16 As String
	Return $"$(document).on("click", ".edit", function (e) {
  const id = $(this).attr("data-id")
  const code = $(this).attr("data-code")
  const name = $(this).attr("data-name")
  const category = $(this).attr("data-category")
  const price = $(this).attr("data-price").replace(",", "")
  $("#id1").val(id)
  $("#code1").val(code)
  $("#name1").val(name)
  $("#category2").val(category)
  $("#price1").val(price)
})"$
End Sub

Private Sub script17 As String
	Return $"$(document).on("click", ".delete", function (e) {
  const id = $(this).attr("data-id")
  const code = $(this).attr("data-code")
  const name = $(this).attr("data-name")
  $("#id2").val(id)
  $("#code_name").text("(" + code + ") " + name)
})"$

End Sub

Private Sub script18 As String
	Return $"$(document).on("click", "#add", function (e) {
  const form = $("#add_form")
  form.validate({
    rules: {
      product_code: {
        required: true,
        minlength: 3
      },
      product_name: {
        required: true
      },
      action: "required"
    },
    messages: {
      product_code: {
        required: "Please enter Product Code",
        minlength: "Value must be at least 3 characters"
      },
      product_name: {
        required: "Please enter Product Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      ${IIf(dataType = "xml", _
      $"const data = convertFormToXML(form[0])"$, _
      $"const data = JSON.stringify(convertFormToJSON(form), undefined, 2)"$)}
      $.ajax({
        type: "post",
        data: data,
        dataType: "${dataType}",
        url: "/${Api.Name}/products",
        success: function (response) {
          $("#new").modal("hide")
          ${AlertScript("New product added !", 201, True)}
        },
        error: function (xhr, ajaxOptions, errorThrown) {
          alert(errorThrown)
        }
      })
    }
  })
})"$
End Sub

Private Sub script19 As String
	Return $"$(document).on("click", "#update", function (e) {
  const form = $("#update_form")
  form.validate({
    rules: {
      product_code: {
        required: true,
        minlength: 3
      },
      product_name: {
        required: true
      },
      action: "required"
    },
    messages: {
      product_code: {
        required: "Please enter Product Code",
        minlength: "Value must be at least 3 characters"
      },
      product_name: {
        required: "Please enter Product Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      ${IIf(dataType = "xml", _
      $"const data = convertFormToXML(form[0])"$, _
      $"const data = JSON.stringify(convertFormToJSON(form), undefined, 2)"$)}
      $.ajax({
        type: "put",
        data: data,
        dataType: "${dataType}",
        url: "/${Api.Name}/products/" + $("#id1").val(),
        success: function (response) {
          $("#edit").modal("hide")
          ${AlertScript("Product updated successfully !", 200, True)}
        },
        error: function (xhr, ajaxOptions, errorThrown) {
          alert(errorThrown)
        }
      })
    }
  })
})"$
End Sub

Private Sub script20 As String
	Return $"$(document).on("click", "#remove", function (e) {
  $.ajax({
    type: "delete",
    dataType: "${dataType}",
    url: "/${Api.Name}/products/" + $("#id2").val(),
    success: function (response) {
      $("#delete").modal("hide")
      ${AlertScript("Product deleted successfully !", 200, False)}
    },
    error: function (xhr, ajaxOptions, errorThrown) {
      alert(errorThrown)
    }
  })
})"$
End Sub

Private Sub script21 As String
	Return $"function populateCategories() {
  return $.ajax({
    type: "get",
    dataType: "${dataType}",
    url: "/${Api.Name}/categories",
    success: function (response) {
      const $category1 = $("#category1")
      const $category2 = $("#category2")
      $category1.empty()
      $category2.empty()
      let data = []
      ${IIf(ContentType = WebApiUtils.MIME_TYPE_XML, _
      $"const root = $(response).find("${XmlRoot}")
      ${IIf(Verbose, _
      $"const result = $(root).children("${RESPONSE_ELEMENT_RESULT}")"$, _
      $"const result = $(root)"$)}
      const $items = $(result).children("${XmlElement}")
      $items.each(function () {
        const $item = $(this)
        data.push({
          id: $item.children("id").text(),
          category_name: $item.children("category_name").text()
        })
      })"$, _
	  $"data = ${IIf(Verbose, $"response.${RESPONSE_ELEMENT_RESULT}"$, "response")}"$)}
      // Append to both dropdowns
      data.forEach(function (item) {
        const option = $("<option />").val(item.id).text(item.category_name)
        $category1.append(option.clone())
        $category2.append(option)
      })
    },
    error: function (xhr, ajaxOptions, errorThrown) {
      alert(errorThrown)
    }
  })
}"$
End Sub

Private Sub script22 As String
	Return $"function renderTable(rows) {
  let tblHead = ""
  let tblBody = ""

  if (rows.length) {
    tblHead = `
      <thead class="bg-light">
        <th style="text-align: right; width: 50px">#</th>
        <th>Code</th>
        <th>Name</th>
        <th>Category</th>
        <th style="text-align: right">Price</th>
        <th style="text-align: center; width: 90px">Actions</th>
      </thead>`
    tblBody = "<tbody>"

    rows.forEach(item => {
      const id = item.id || ""
      const code = item.code || ""
      const name = item.name || ""
      const catid = item.catid || ""
      const category = item.category || ""
      const price = item.price || ""
      tblBody += `
        <tr>
          <td class="align-middle" style="text-align: right">${"$"}{id}</td>
          <td class="align-middle">${"$"}{code}</td>
          <td class="align-middle">${"$"}{name}</td>
          <td class="align-middle">${"$"}{category}</td>
          <td class="align-middle" style="text-align: right">${"$"}{price}</td>
          <td>
            <a href="#edit" class="text-primary mx-2" data-toggle="modal">
              <i class="edit fa fa-pen"
                 data-id="${"$"}{id}" data-code="${"$"}{code}" data-category="${"$"}{catid}"
                 data-name="${"$"}{name}" data-price="${"$"}{price}" title="Edit"></i></a>
            <a href="#delete" class="text-danger mx-2" data-toggle="modal">
              <i class="delete fa fa-trash"
                 data-id="${"$"}{id}" data-code="${"$"}{code}" data-category="${"$"}{catid}"
                 data-name="${"$"}{name}" title="Delete"></i></a>
          </td>
        </tr>`
    })
    tblBody += "</tbody>"
  } else {
    tblBody = `
      <tbody>
        <tr>
          <td class="text-center" colspan="6">No results</td>
        </tr>
      </tbody>`
  }

  $("#results table").html(tblHead + tblBody)
}"$
End Sub

Public Sub GenerateJSFileForHelp (DirName As String, FileName As String)
	Dim Script As String = $"${script01}
${script02}
${script03}
${script04}
${script05}
${script06}"$
	File.WriteString(DirName, FileName, Script)
End Sub

Public Sub GenerateJSFileForCategory (DirName As String, FileName As String)
	Dim Script As String = $"$(document).ready(function () {
  ${script07}
})
${script08}
${script09}
${script10}
${script11}
${script12}
${script13}"$
	File.WriteString(DirName, FileName, Script)
End Sub

Public Sub GenerateJSFileForSearch (DirName As String, FileName As String)
	Dim Script As String = $"$(document).ready(function () {
  $.when(populateCategories())
    .done(function () {
      getFind()
    })
})
$("#btnsearch").click(function (e) {
  e.preventDefault()
  const form = $("#search_form")
  ${IIf(dataType = "xml", _
  $"const data = convertFormToXML(form[0])"$, _
  $"const data = JSON.stringify(convertFormToJSON(form), undefined, 2)"$)}
  callFindApi(data)
})
${script21}
${script22}
${script15("getFind")}
${script15("callFindApi")}
${script16}
${script17}
${script18}
${script19}
${script20}
${script13}"$
  File.WriteString(DirName, FileName, Script)
End Sub