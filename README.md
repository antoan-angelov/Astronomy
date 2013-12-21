Solar System Model
=========

Project was for the National Olympiad in Information Technologies 2013 in Bulgaria, finished in 5th place. 

Solar System Model is a 3D model of our Solar System for educational purposes. Every celestial body comes with a lesson and a test after each lesson.

Lessons, tests and celestial body info (tilts, sizes, rotation speeds, etc.) are defined as XML files in the assets folder. They are then read by the projector file and practically the whole Solar System implementation is manipulated by these XML files.

All 3D objects are realized with the help of Away3D, which takes advantage of Flash Player 11's GPU acceleration.

Here is a demo:

[linkname](http://www.youtube.com/watch?v=Av2rO8j9--A)

## Structure ##

A quick rundown of the main directory:

- **Astronomy.exe**: final version, requires the assets folder to be in the same directory
- **assets**: images, css and xml files which are used for planet textures and formatting the lessons
- **site**: source of complementary static site
- **libs**: the two libraries I use, Away3D for 3D modelling and Tweener for smooth animations
- **com**: the source code



