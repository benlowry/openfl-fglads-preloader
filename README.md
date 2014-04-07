# FGLAds for OpenFL
## With Mochi Media style preloader

A preloader wrapper for the [FGLAds](http://fgl.com/) service for [OpenFL](http://openfl.org/).  Contains rich customization 
to include your own game, developer and sponsor branding.

### Features include:
- attractive preloading bar
- preloading bar converts into play button after the game is finished loading *and* at least 15 seconds have passed
- fully customizable appearance and behavior

### Usage:
In your project's xml file:
<preloader name="FGLPreloader" />

### Customization:
Open FGLPreloader.hx, adjust any or all optional parameters including your FGL ad id.

    gametitle: "", // the name of your game
    developer: "", // developer branding
    developerlink: "", // developer link
    onerror: adFinished,  // function(e:Event)
    oncomplete: adFinished,  // function(e:Event)
    custombackground: // optional displayobject to use as background
    sponsor: "",     // sponsor's name
    sponsorlink: "", // sponsor's url
    background: 0x1C3755, // optional  background color
    titletext: 0xFFFFFF, // color for the game name
    titlebackground: 0x000000, // background color underlaying the game name
    fgltext: 0xFFFFFF, // color for the 'ads by fgl'
    fglbackground: 0x000000, // background color underlaying 'ads by fgl'
    preloadertext: 0x999999, // preloader text color
    preloaderbar: 0x253240, // preloader progress bar color
    preloaderbackground: 0x000000, // preloader bar background color
    adbackground: 0x000000, // ad box background
    playbuttonbackground: 0x333333, // play button background
    playbuttontext: 0xFFFFFF, // play button text color
    playbuttonborder: 0xFFFFFF // play button border color

### Example:
![Loading](http://i.imgur.com/wSnBhf4.png)
![Loaded](http://i.imgur.com/b0jmOJR.png)

### License:

The MIT License (MIT)

Copyright (c) 2014 Ben Lowry

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.