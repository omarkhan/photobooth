socket = io.connect 'http://localhost:8000'

running = false
div = document.getElementById 'main'

window.onkeypress = (evt) ->
    if running
        return
    running = true
    socket.emit 'photo'

socket.on 'done', (response) ->
    running = false
    div.innerHTML = ("<img src=\"file://#{img}\"/>" for img in response).join '\n'

socket.on 'fail', ->
    running = false
    div.textContent = 'Something went wrong, sorry! Try again'
