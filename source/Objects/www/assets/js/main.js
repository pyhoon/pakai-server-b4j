/*!
 * Pakai Server Framework B4J Project Template v6.00alpha by @pyhoon (https://github.com/pyhoon/pakai-server-b4j)
 * Copyright (c) 2022-2025 Poon Yip Hoon (Aeric)
 * Licensed under MIT (https://github.com/pyhoon/pakai-server-b4j/blob/main/LICENSE)
 */
var csrf_token = $('meta[name="csrf-token"]').attr('content')
function csrfSafeMethod(method) {
  // these HTTP methods do not require CSRF protection
  return (/^(GET|HEAD|OPTIONS)$/.test(method))
}
$.ajaxSetup({
  beforeSend: function (xhr, settings) {
    if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
      xhr.setRequestHeader("x-csrf-token", csrf_token)
    }
  }
})