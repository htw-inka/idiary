iDiary
======

Software base for interactive diaries and ebooks for mobile devices
-------------------------------------------------------------------

__iDiary__ is a [cocos2d](http://cocos2d-iphone.org)-based software framework/base for creating interactive multimedia diaries or ebooks. It runs on the Apple iOS platform and has so far been tested on iPad 1 and 2.
The software was created for interactive diaries used in workshops in the [Jewish Museum Berlin](http://www.jmberlin.de).

Features
--------

User __Maniacdev__ created a nice video showing some of the features on YouTube: [iDiary - iPad Development Library Using Cocos2D For Creating Interactive eBooks](http://www.youtube.com/watch?v=DK8BxlPVNCw)

* E-Book look & feel
* built-in 3D page swipe animation
* diverse multimedia objects on the book's pages:
 * images and text
 * movable objects
 * integration of video, audio and animations
 * physical objects (using [Box2D](http://box2d.org/))
* built-in classes for action & reflex games, quizzes, etc.
* script to generate page graphics and code from a Photoshop PSD file
* fast OpenGL based rendering (done by underlying framework 'Cocos2D')

Prerequisites
-------------

This software requires __XCode__ to compile and run. The XCode project file can be found under `src/iDiary2.xcodeproj`. It already contains the sources of the [cocos2d-framework](http://cocos2d-iphone.org) of version 1.0.1 and is ready to compile.


Usage
-----

The software package contains an "example diary" consisting of 8 pages that show usage cases and how to implement them using the specific classes in __idiary__. Details on the software architecture are described in the [github wiki][1].

License
-------

This software is released under BSD 3-clause license which is contained in the file `LICENSE`.

[1]: https://github.com/htw-inka/idiary/wiki
