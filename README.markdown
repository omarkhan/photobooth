Khanival Photobooth
===================

This is my attempt to hack together a photo booth for my brother's wedding using
an old netbook and a DSLR.

To use, position the netbook at chest height and somehow balance the camera just
above the netbook's webcam. Plug the camera into the netbook via usb, fire up
`server.coffee` and point chrome at `localhost:8000`. When someone presses a
key, the camera takes 4 pictures, which are thumbnailed using imagemagick and
displayed on the screen for the amusement of everyone present.

### You will need:

- A webkit based browser (it could probably be tweaked to work in any modern
  browser now, but back when I wrote it only webkit had the necessary apis)
- gphoto2 `sudo apt-get install gphoto2` or `brew install gphoto2`
- ImageMagick `sudo apt-get install imagemagick` or `brew install imagemagick`
- Dependencies from npm `npm install`

### Running

This should do it:

```
npm start
open http://localhost:8000/
```
