pindestino
==========

Pindestino is a linux distribution/image for Raspberry Pi, built on top of Raspbian.

At boot, Pindestino will:

1. Start any Node.js application that is on your USB stick.
2. Start Iceweasel in fullscreen, kiosk mode style.
3. Direct Iceweasel to http://127.0.0.1/ (that is your Node.js app).
 
More features:
* Pindestino mounts your SD card and your USB stick as read-only, so the Raspberry can be unplugged without a proper shutdown.
* Put Iceweasel/Firefox extensions on your USB stick, and those will be auto installed before Iceweasel starts.


Download image file
--------------------

The SD card image is ~3 gigabytes.

* [Torrent download](https://github.com/klandestino/pindestino/raw/master/releases/pindestino_version_1.img.torrent).


Build image
-----------

make must run as root, since the build will loopback mount the image:

	# sudo make


Booting image in qemu
---------------------

	# qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 rootfstype=ext4 ro" -drive file=pindestino.img,index=1,readonly,media=disk


Write image to SD card
----------------------

Something like: (Make sure /dev/mmcblk0 is the correct device!)

	# sudo dd bs=4M if=pindestino.img of=/dev/mmcblk0
	# sudo sync


Prepare your USB stick
----------------------

At boot, Pindestino will search for a USB device with the files app/package.json and app/pindestino.conf. Both those files must exist. It will then change directory (cd) into the app directory, and execute npm start.

Any node js application depenencies must be in the app/node_modules directory. NOTE: Binary modules must be of the Raspberry Pi architecture.

Your node.js application must listen at port 80. Otherwise, X11 and Iceweasel will not start.

You can put Firefox/Iceweasel extensions on your USB stick, and those will be installed before Iceweasel starts. Just create a directory called app/xpi on the USB stick, and put your .xpi file(s) there.


app/pindestino.conf
-------------------

The app/pindestino.conf should be on your USB stick, and it will set some configuration for your pindestino. It should be in YAML format. It could also be completely empty, however the file must exist.

To enable Wifi and set network name and password:

	wifi:
		network: MYWIFI
		passwork: secret

To mount your USB stick in read-write mode:

	usb: rw

To run a bootscript (before "npm start"). Note that it is relative to the USB stick's app directory. 

	bootscript: ./autostart.sh

To disable kiosk mode (full screen browser):

	kiosk: false

Don't start the browser (nor X11) at boot:

	browser: false

Don't start the node.js app at boot - just a browser:

	nodeapp: false


How to build your binary npm dependencies using Pindestino
----------------------------------------------------------

Your app directory on your USB stick need all npm dependencies installed before booting. Binary dependencies must be compiled for the Raspberry Pi architecture. This is how you could do that:

1. Put your node app on the USB stick and define all your dependencies in package.json.
2. Add "usb: rw" in your app/pindestino.conf to make the USB stick writable.
3. Add "bootscript: ./install.sh" to your app/pindestino.conf, to run that bash script before Pindestino runs "npm start".
4. Create a app/install.sh file on your USB stick, and paste this into it: rm -Rf node_modules; HOME="$(pwd)" NODE_JS_HOME="/opt/nodejs" PATH="$PATH:$NODE_JS_HOME/bin" npm install
5. Now boot Pindestino with this USB stick. It will install your dependencies and compile your binary dependencien to the Raspberry Pi architecture.
6. Now your dependencies are on the USB stick. You can now remove "usb: rw" and "bootscript: ./install.sh" from your app/pindestino.conf and delete the app/install.sh file.
7. Viola!

Also note: Some modules require symlinks to work on your USB stick. The FAT file system does not support symlinks, so you might have to format your USB stick to some linux filesystem, for example ext3.


Q & A
------

### Where is some debug info / boot messages?

Press ctrl+alt+f2 for tty2, where that stuff is.

### What is the username and password?

Username is "pi". Password is "raspberry".

### How do I get cable ethernet connection?

Remove the "wifi" section from your app/pindestino.conf on the USB stick, and reboot. Then Pindestino will try to DHCP over the cable (eth0).

### Why is everything so slow?

Because Raspberry Pi is a slow computer.

### How long does it take to start up Pindestino?

Depends a bit on your site, SD card performance, and more, but about 2 minutes and 30 seconds is probably normal duration from power on until the web app loaded in Iceweasel.

### Are you overclocking?

Yes, a very slight overclocking.

### Is it built on top of soft-float or hard-float Raspbian?

Hard-float.

### How do I change the resolution?

We hardcoded 720p into Pindestino. In the future, we would like the resolution to be configurable in the USB stick's app/pindestino.conf. However, you can change it, editing the config.txt on the SD card. See any Raspbian tutorial for more info.

TODO for future releases
-------------------------

* Screen resolution should be configurable in the USB stick's app/pindestino.conf.
* Tor support (anonymous internet access).
* More networking config (like static IPs, routing yada yada, etc).
* Start a default node.js server with documentation if no USB stick is found within XX seconds.
* Support for open/non-wpa2 wifi networks.

