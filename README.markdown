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
- CoffeeScript `npm install -g coffee-script`
- gphoto2 `sudo apt-get install gphoto2`
- Other things from npm `npm install`
