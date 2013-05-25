SensorContainer
===============
This repo contains the iOS container app for the <b>Interactive Web Application Framework</b> (https://github.com/ubc-magic/container)
This app couples with the jQuery plugin (https://github.com/jnwu/thingbroker-jquery-plugin) in the framework.

Main Functionalities
--------------------
The following functionalities are provided in this iOS application,
* Provides mobile web applications direct access to supported mobile resources
* Dynamic loading of mobile web application list from web application container
* Allow session-based interaction via QR codes

Significance
------------
The SensorContainer is a modified browser, where mobile resources are exposed via a specified URL format for event triggers.

Data from the mobile app is stored in the thingbroker, where a web app with the jQuery plugin attached can pull the data and engage in processing.

<p align="center">
  <img src="/Screenshot/diagram_a.png" />
</p>

Interface
---------
The app uses GHSideBarNav for listing all the supported apps in the framework, while the main viewing space is used for displaying the mobile web application.
<p align="center">
  <img src="/Screenshot/side_panel.png" />
</p>


Hyperlink Format
----------------
As stated, mobile resources are triggered via HTML links in mobile web applications.

<p align="center">
  <code>
    http://base_url/resource/data_id/method/param
  </code>
</p>


Supported Mobile Resources
--------------------------
<p align="center">
  <img src="/Screenshot/diagram_b.png" />
</p>

The following resources are shared and supported via the iOS application,
* Accelerometer
* Camera (with camera filters)
* Microphone (with voice-to-text feature)
* MP3 Songs
* Magnetometer
* GPS
* QR Scanner


Demo Web Apps
-------------
Three demo web apps (https://github.com/jnwu/SensorContainerApplications) have been created for this framework.

* <b>Slide Presentation</b>: Mobile users are able to view slides via touch and voice commands
<p align="center">
  <img src="/Screenshot/presentation.png" />
</p>
<br />
<br />
* <b>Music Player</b>: Mobile users are able to upload MP3 songs from iOS devices, and allow voice commands
<p align="center">
  <img src="/Screenshot/music.png" />
</p>
<br />
<br />
* <b>Driving Simulation</b>: Mobile users able to manipulate a 3D object via accelerometer and voice inputs
<p align="center">
  <img src="/Screenshot/driving_simulation.png" />
</p>


Third-Party Dependencies
-----------------------
The following third-party libraries have been integrated,
* RestKit: http://restkit.org/        
* FLACiOS: https://github.com/jhurt/FLACiOS
* zxing: https://github.com/zxing/zxing
* GHSideBarNav: https://github.com/gresrun/GHSidebarNav
* wav_to_flac: https://github.com/jhurt/wav_to_flac
* MBProgressHUD: https://github.com/jdg/MBProgressHUD
