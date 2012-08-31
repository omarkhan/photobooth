socket = io.connect 'http://localhost:8000'

running = false
photoDiv = document.getElementById 'photo'

showPhotos = (photos) ->
    if photos.length
        console.log 'SHOWING PHOTO'
        img = photos[0]
        photoDiv.style.display = 'block'
        photoDiv.innerHTML = "<img src=\"#{img}\"/>"
        setTimeout ->
            showPhotos photos[1..]
        , 5000
    else
        photoDiv.style.display = 'none'

window.onkeypress = (evt) ->
    if running
        return
    running = true
    socket.emit 'photo'

socket.on 'done', (response) ->
    running = false
    showPhotos response

socket.on 'fail', ->
    running = false

onMedia = (stream) ->
    output = document.getElementsByTagName('video')[0]
    source = window.webkitURL.createObjectURL stream
    output.src = source

navigator.webkitGetUserMedia { video: true, audio: false }, onMedia, ->
