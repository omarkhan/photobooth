#!/usr/bin/env coffee

{exec} = require 'child_process'
fs     = require 'fs'
http   = require 'http'


# Serve index.html
app = http.createServer (request, response) ->
    url = if request.url == '/' then '/index.html' else request.url
    fs.readFile __dirname + url, (err, data) ->
        if err
            response.writeHead 404
            return response.end 'Not found'

        response.writeHead 200
        response.end data

app.listen 8000


# Set up socket interface
running = false
io = require('socket.io').listen app
io.sockets.on 'connection', (socket) ->
    socket.on 'photo', ->
        if running
            return
        running = true
        exec "gphoto2 --frames=4 --interval=1 --capture-image-and-download --filename='#{__dirname}/photos/%Y-%m-%dT%H:%M:%S.jpg'", (err, stdout, stderr) ->
            running = false
            if err?
                return socket.emit 'fail'
            lines = stdout.match /^Saving file as .*$/gm
            photos = (l.replace /^Saving file as /, '' for l in lines)
            socket.emit 'done', photos
