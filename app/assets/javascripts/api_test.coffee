# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.dropdown-menu a').click () ->
    action_type = $(this).text()
    $("#request_action_type").html(action_type+' <span class="caret"></span>')

  $('.btn-add-key-value').click () ->
    next_key_value = $(".api-key").length + 1
    key_html = '<div class="form-group" style="margin-top:5px;">
                  <input class="form-control api-key" data-keyvalue="api-key'+next_key_value+'" placeholder="Key" type="text">
                </div>
                <label style="margin-top:5px;"> - </label>
                <div class="form-group" style="margin-top:5px;">
                  <input class="form-control api-key'+next_key_value+'-val" placeholder="Value" type="text">
                </div>'
    $(".form-api-key-list").append(key_html)

  $('.btn-send-request').click () ->
    url = $("#basic_host_url").text() +  $("#api_request_url").val()
    action_type = $("#request_action_type").text().trim()
    request_data = {}
    $('.api-key').each (index, key) ->
      request_key = $(key).val()
      dd = $(key).data("keyvalue")+"-val"
      request_value = $("."+$(key).data("keyvalue")+"-val").val()
      if request_key != ''
        request_data[request_key] = request_value
    $.ajax(
      type: action_type
      url: url
      data: request_data).done (resp) ->
        console.log resp
        $(".api-request-result-panel").text(JSON.stringify(resp))
