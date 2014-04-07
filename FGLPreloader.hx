package ;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.Lib;
import openfl.Assets;

@:bitmap("../assets/images/adbackground.jpg") class AdBG extends BitmapData { }


class FGLPreloader extends NMEPreloader
{
    private var wrapper:FGLWrapper;

    public function new()
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, init);
        addEventListener(Event.REMOVED_FROM_STAGE, dispose);
    }

    private function init(e:Event)
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);

        wrapper = new FGLWrapper(
        {
            adid: "FGL-20027885",
            gametitle: Settings.NAME + " Jigsaw Puzzles",
            developer: "PuzzleBoss", // your name
            developerlink: "http://puzzleboss.com/?from=" + Settings.PACKAGE, // your url
            onerror: adFinished,  // function(e:Event)
            oncomplete: adFinished,  // function(e:Event)
            custombackground: new Bitmap(new AdBG(0, 0)) // optional displayobject to use as background
           /*
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
           */
        });
        
        addChild(wrapper);
    }

    override public function onUpdate(bytesLoaded:Int, bytesTotal:Int)
    {
    }

    override public function onInit()
    {
    }

    override public function onLoaded()
    {
    }

    private function adFinished(e:Event)
    {
        dispatchEvent (new Event (Event.COMPLETE));
    }

    private function dispose(e:Event)
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
    }
}