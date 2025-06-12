$(document).ready(function () {
  $.ajax({
    type: "get",
    dataType: "json",
    url: "/api/categories",
    success: function (response, status, xhr) {
      let data = []
      // JSON format
      data = response.s === "ok" ? response.r : []
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
      <td class="align-middle" style="text-align: right">${id}</td>
      <td class="align-middle">${name}</td>
      <td>
        <a href="#edit" class="text-primary mx-2" data-toggle="modal">
          <i class="edit fa fa-pen" data-toggle="tooltip"
          data-id="${id}" data-name="${name}" title="Edit"></i></a>
        <a href="#delete" class="text-danger mx-2" data-toggle="modal">
          <i class="delete fa fa-trash" data-toggle="tooltip"
          data-id="${id}" data-name="${name}" title="Delete"></i></a>
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
  })
})
$(document).on("click", ".edit", function (e) {
  const id = $(this).attr("data-id")
  const name = $(this).attr("data-name")
  $("#id1").val(id)
  $("#name1").val(name)
})
$(document).on("click", ".delete", function (e) {
  const id = $(this).attr("data-id")
  const name = $(this).attr("data-name")
  $("#id2").val(id)
  $("#name2").text(name)
})
$(document).on("click", "#add", function (e) {
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
      e.preventDefault()
      const data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "post",
        data: data,
        dataType: "json",
        url: "/api/categories",
        success: function (response) {
          $("#new").modal("hide")
          const code = response.a
          const error = response.e
          if (code == 201) {
            alert("New category added !")
            location.reload()
          }
          else {
            alert(code + " " + error)
          }
        },
        error: function (xhr, ajaxOptions, errorThrown) {
          alert(errorThrown)
        }
      })
    }
  })
})
$(document).on("click", "#update", function (e) {
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
      e.preventDefault()
      const data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "put",
        data: data,
        dataType: "json",
        url: "/api/categories/" + $("#id1").val(),
        success: function (response) {
          $("#edit").modal("hide")
          const code = response.a
          const error = response.e
          if (code == 200) {
            alert("Category updated successfully !")
            location.reload()
          }
          else {
            alert(code + " " + error)
          }
        },
        error: function (xhr, ajaxOptions, errorThrown) {
          alert(errorThrown)
        }
      })
    }
  })
})
$(document).on("click", "#remove", function (e) {
  $.ajax({
    type: "delete",
    dataType: "json",
    url: "/api/categories/" + $("#id2").val(),
    success: function (response) {
      $("#delete").modal("hide")
      const code = response.a
      const error = response.e
      if (code == 200) {
        alert("Category deleted successfully !")
        location.reload()
      }
      else {
        alert(code + " " + error)
      }
    },
    error: function (xhr, ajaxOptions, errorThrown) {
      alert(errorThrown)
    }
  })
})
function convertFormToJSON(form) {
  const array = $(form).serializeArray() // Encodes the set of form elements as an array of names and values.
  const json = {}
  $.each(array, function () {
    json[this.name] = this.value || ""
  })
  return json
}