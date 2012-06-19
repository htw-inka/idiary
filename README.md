iDiary
======

Software base for interactive diaries and ebooks for mobile devices
-------------------------------------------------------------------

'iDiary' is a [cocos2d](http://cocos2d-iphone.org)-based software framework/base for creating interactive multimedia diaries or ebooks. It runs on the Apple iOS platform and has so far been tested on iPad 1 and 2.
The software was created for interactive diaries used in workshops in the [Jewish Museum Berlin](http://www.jmberlin.de).

Features
--------
* E-Book look & feel
* built-in 3D page swipe animation
* diverse multimedia objects on the book's pages:
 * images and text
 * movable objects
 * integration of video, audio and animations
 * physical objects (using [Box2D](http://box2d.org/))
* built-in classes for action & reflex games, quizzes, etc.
* fast OpenGL based rendering (done by underlying framework 'Cocos2D')

Prerequisites
-------------

This software requires 'XCode' to compile and run. The XCode project file can be found under `src/iDiary2.xcodeproj`. It already contains the sources of the [cocos2d-framework](http://cocos2d-iphone.org) of version 1.0.1 and is ready to compile.


Usage
-----

The software package contains an "example diary" consisting of 8 pages that show usage cases and how to implement them using the specific classes in 'idiary'. Details on the software architecture are described in the github wiki.

License
-------

This software is released under BSD 2-clause license which is contained in the file `LICENSE`.

