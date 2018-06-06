socket = io.connect 'http://localhost:8000'

socket.emit 'dimensions', width: screen.width, height: screen.height

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

navigator.mediaDevices.getUserMedia video: true, audio: false
    .then (stream) ->
        video = document.getElementsByTagName('video')[0]
        video.srcObject = stream
