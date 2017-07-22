#!/usr/bin/env coffee

{exec} = require 'child_process'
fs     = require 'fs'
http   = require 'http'
async  = require 'async'
im     = require 'imagemagick'
mime   = require 'mime'


# Serve index.html
app = http.createServer (request, response) ->
    url = if request.url == '/' then '/index.html' else request.url
    mimetype = mime.lookup url
    fs.readFile __dirname + url, (err, data) ->
        if err
            response.writeHead 404
            return response.end 'Not found'

        response.writeHead 200, { 'Content-Type': mimetype }
        response.end data

app.listen 8000


thumbnail = (path, callback) ->
    dest = path.replace '/photos/', '/thumbnails/'
    im.resize
        srcPath: path
        dstPath: dest
        width: 1440
        height: 900
    , (err) ->
        if err?
            callback err
        else
            callback null, dest


# Set up socket interface
running = false
io = require('socket.io').listen app
io.sockets.on 'connection', (socket) ->
    socket.on 'photo', ->
        console.log 'PHOTO'
        if running
            return
        running = true
        exec "gphoto2 --frames=4 --interval=1 --capture-image-and-download --filename='#{__dirname}/photos/%Y-%m-%dT%H:%M:%S.jpg'", (err, stdout, stderr) ->
            running = false
            if err?
                return socket.emit 'fail'
            lines = stdout.match /^Saving file as .*$/gm
            paths = (l.replace /^Saving file as /, '' for l in lines)
            async.map paths, thumbnail, (err, thumbs) ->
                if err?
                    return socket.emit 'fail'
                socket.emit 'done', (t.replace __dirname, '' for t in thumbs)
