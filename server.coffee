#!/usr/bin/env coffee

{exec, spawn} = require 'child_process'
fs            = require 'fs'
http          = require 'http'
async         = require 'async'
im            = require 'imagemagick'
mime          = require 'mime'


logo = null
if process.argv.length > 2
    path = "#{__dirname}/tmp/logo.png"
    im.convert [process.argv[2], '-resize', '300x300>', path], (err) ->
        throw err if err
        logo = path


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

console.log 'Listening on port 8000...'
app.listen 8000


dimensions =
    width: 1440
    height: 900

thumbnail = (path, callback) ->
    dest = path.replace '/photos/', '/thumbnails/'
    opts = Object.assign {}, dimensions, srcPath: path, dstPath: dest
    im.resize opts, (err) -> callback err, dest


montage = (paths, dest, callback) ->
    proc = spawn 'montage', [paths..., '-geometry', '890x590>+5+5', dest], stdio: 'inherit'
    proc.on 'close', (code) ->
        if code != 0 then return callback new Error 'Montage failed'
        callback null, dest


compose = (path, logo, dest, callback) ->
    callback null, path unless logo
    proc = spawn 'composite', ['-geometry', '+1490+890', logo, path, dest], stdio: 'inherit'
    proc.on 'close', (code) ->
        if code != 0 then return callback new Error 'Composite failed'
        callback null, path


print = (paths, logo) ->
    now = new Date()
    date = new Date(now - now.getTimezoneOffset() * 60000).toISOString().replace(/\..*?$/, '')
    dest = "#{__dirname}/prints/#{date}.jpg"
    montage paths, dest, (err) ->
        return if err
        compose dest, logo, dest, (err) ->
            return if err
            exec "lpr -o landscape #{dest}"


# Set up socket interface
running = false
io = require('socket.io').listen app
io.sockets.on 'connection', (socket) ->

    socket.on 'dimensions', ({ width, height }) ->
        console.log "Setting thumbnail dimensions to #{width}x#{height}"
        dimensions.width = width
        dimensions.height = height

    socket.on 'photo', ->
        console.log 'Photo requested'
        if running
            console.log 'Already taking pictures, skipping'
            return
        running = true
        exec "gphoto2 --frames=4 --interval=1 --capture-image-and-download --filename='#{__dirname}/photos/%Y-%m-%dT%H:%M:%S.jpg'", (err, stdout, stderr) ->
            running = false
            if err?
                console.error err
                return socket.emit 'fail'
            lines = stdout.match /^Saving file as .*$/gm
            paths = (l.replace /^Saving file as /, '' for l in lines)
            async.map paths, thumbnail, (err, thumbs) ->
                if err?
                    console.error err
                    return socket.emit 'fail'
                socket.emit 'done', (t.replace __dirname, '' for t in thumbs)
            print paths, logo


# Open the browser
exec 'open http://localhost:8000'
