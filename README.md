Solar System Model
=========

Project was for the National Olympiad in Information Technologies 2013 in Bulgaria, finished in 5th place. 

Solar System Model is a 3D model of our Solar System for educational purposes. Every celestial body comes with a lesson and a test after each lesson.

Lessons, tests and celestial body info (tilts, sizes, rotation speeds, etc.) are defined as XML files in the assets folder. They are then read by the projector file and practically the whole Solar System implementation is manipulated by these XML files.

All 3D objects are realized with the help of Away3D, which takes advantage of Flash Player 11's GPU acceleration.

# Structure #
A quick rundown of the main directory:

- **Astronomy.exe**: final version, requires the assets folder to be in the same directory
- **assets**: images, css and xml files which are used for planet textures and formatting the lessons
- **site**: source of complementary static site
- **libs**: the two libraries I use, Away3D for 3D modelling and Tweener for smooth animations
- **com**: the source code

# Minimum Requirements #
- Mid-range graphics card (will start in Software mode otherwise - will work with slow performance)
- 1024x768 monitor resolution
- Windows XP

# Libraries #
- **[Away3D](http://away3d.com/)** for 3D modelling 
- **[Tweener](https://code.google.com/p/tweener/)** for smooth animations

# Demo #
- [Video](http://www.youtube.com/watch?feature=player_embedded&v=Av2rO8j9--A)

# Developed By #
- Antoan Angelov - [antoan.angelov@gmail.com](mailto:antoan.angelov@gmail.com)

# Licence #

    The MIT License (MIT)
    
    Copyright (c) 2013 Antoan Angelov
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
