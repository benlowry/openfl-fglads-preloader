package ;

import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.filters.BlurFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;
import flash.Lib;

class FGLWrapper extends Sprite
{
    private var _options:Dynamic;
    private var _warnings:Array<String>;
    private var _timerSteps:Int;
    private var _timerEnd:Int = 300;
    private var _timerProgress:Float = 0;
    private var _loadProgress:Float = 0;
    private var _loadingBar:Sprite;
    private var _loadTimer:Timer;
    private var _timerLoaded:Bool = false;
    private var _loaderLoaded:Bool = false;
    private var _button:Sprite;
    private var _buttonOverlay:Sprite;
    private var _buttonFrame:Int = 0;
    private var _buttonAnim:Timer;
    private var _buttonLabel:TextField;
    private var _loaderInfo:LoaderInfo;
    public var preloaderLoaded:Bool = false;

    public function new(options:Dynamic = null)
    {
        super();

        _options = options == null ? {} : options;
        _warnings = new Array<String>();

        // required values
        if(_options.gametitle == null)
        {
            _warnings.push("Please set options.gametitle in your ad initialization");
            _options.gametitle = "GAMETITLE";
        }

        if(_options.developer == null)
        {
            _warnings.push("Please set options.developer in your ad initialization, and options.developerlink if you want it to link to your website");
            _options.developer = "UNKNOWN";
            _options.developerlink = "#";
        }

        if(_options.oncomplete == null)
        {
            _warnings.push("Please set options.oncomplete with your callback function else the ad cannot exit");
        }

        if(_options.adid == null)
        {
            _warnings.push("You did not include your FGL ad id");
        }

        if(Lib.current.stage.stageHeight < 300 || Lib.current.stage.stageWidth < 400)
        {
            _warnings.push("Your game must be at least 400x300 pixels");
        }

        if(_warnings.length > 0)
        {
            trace("FGLWrapper: the following errors caused your ad request to be aborted:");
            trace(_warnings.join("\n"));

            if(_options.oncomplete)
            {
                _options.oncomplete();
            }

            return;
        }

       // default values
        if(_options.background == null) { _options.background = 0x1C3755; }
        if(_options.fgltext == null) { _options.fgltext = 0x999999; }
        if(_options.fglbackground == null) { _options.fglbackground = 0x000000; }
        if(_options.titletext == null) { _options.titletext = 0xCCCCCC; }
        if(_options.titlebackground == null) { _options.titlebackground = 0x000000; }
        if(_options.preloaderbackground == null) { _options.preloaderbackground = 0x000000; }
        if(_options.preloaderbar == null) { _options.preloaderbar = 0x253240; }
        if(_options.preloadertext == null) { _options.preloadertext = 0xCCCCCC; }
        if(_options.playbuttonbackground == null) { _options.playbuttonbackground = 0x000000; }
        if(_options.playbuttonborder == null) { _options.playbuttonborder = 0xFFFFFF; }
        if(_options.playbuttontext == null) { _options.playbuttontext = 0xCCCCCC; }
        if(_options.adbackground == null) { _options.adbackground = 0x000000; }
        if(_options.developerlink == null) { _options.developerlink = "#"; }
        if(_options.developer == null) { _options.developer = ""; }
        if(_options.sponsorlink == null) { _options.sponsorlink = "#"; }
        if(_options.sponsor == null) { _options.sponsor = ""; }

        addEventListener(Event.ADDED_TO_STAGE, init);
        addEventListener(Event.REMOVED_FROM_STAGE, dispose);
    }

    private function init(e:Event):Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);

        // the background color, which we will make configurable
        graphics.beginFill(_options.background, 1);
        graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
        graphics.endFill();

        var bottom = 0;

        if(_options.custombackground != null)
        {
            addChild(_options.custombackground);
            bottom = 1;
        }

        // set up the fgl link
        var pformat = new TextFormat();
        pformat.color = _options.fgltext;
        pformat.font = "Arial";
        pformat.size = 10;

        var fgl = new TextField();
        fgl.embedFonts = false;
        fgl.autoSize = TextFieldAutoSize.RIGHT;
        fgl.htmlText = "<a href=\"https://fgl.com/?game=" + _options.gameid + "\" target=\"_blank\">ads by fgl</a>";
        fgl.x = Lib.current.stage.stageWidth - Std.Std.int(fgl.width) - 2;
        fgl.y = Lib.current.stage.stageHeight - Std.Std.int(fgl.height);
        fgl.setTextFormat(pformat);
        fgl.selectable = false;
        fgl.textColor = _options.fgltext;
        addChild(fgl);

        var bg = new Sprite();
        bg.graphics.beginFill(_options.fglbackground);
        bg.graphics.drawRect(0, 0, Std.int(fgl.width) + 4, Std.int(fgl.height) + 2);
        bg.graphics.endFill();
        bg.x = Lib.current.stage.stageWidth - bg.width;
        bg.y = Lib.current.stage.stageHeight - bg.height;
        addChildAt(bg, bottom);

        // set up the game title, sponsor and developer link
        var devformat = new TextFormat();
        devformat.color = _options.titletext;
        devformat.font = "Arial";
        devformat.size = 12;

        var devtext = _options.gametitle + " by <a href=\"" + _options.developerlink + "\" target=\"_blank\"><b>" + _options.developer + "</b></a>";

        if(_options.sponsor != "")
        {
            devtext += " and <a href=\"" + _options.sponsorlink + "\" target=\"_blank\"><b>" + _options.sponsor + "</b></a>";
        }

        var devblurb = new TextField();
        devblurb.autoSize = TextFieldAutoSize.LEFT;
        devblurb.embedFonts = false;
        devblurb.htmlText =  devtext;
        devblurb.textColor = _options.titletext;
        devblurb.x = 2;
        devblurb.y = 0;
        devblurb.setTextFormat(devformat);
        devblurb.selectable = false;
        addChild(devblurb);

        var devblurbbg = new Sprite();
        devblurbbg.graphics.beginFill(_options.titlebackground, 0.5);
        devblurbbg.graphics.drawRect(0, 0, Std.int(devblurb.width) + 6, Std.int(devblurb.height) + 2);
        devblurbbg.graphics.endFill();
        devblurbbg.x = 0;
        devblurbbg.y = 0;
        addChildAt(devblurbbg, bottom);

        // set up the ad box
        var adbg = new Sprite();
        adbg.graphics.beginFill(_options.adbackground, 1);
        adbg.graphics.drawRect(0, 0, 308, 258);
        adbg.x = Std.int((Lib.current.stage.stageWidth - 308) / 2);
        adbg.y = Std.int((Lib.current.stage.stageHeight - 258) / 2) - 20;
        adbg.alpha = 0.8;
        addChild(adbg);

        // set up the ad
        var adcontainer = new Sprite();
        adcontainer.x = adbg.x + 4;
        adcontainer.y = adbg.y + 4;
        addChild(adcontainer);

        var ads = new FGLAds(adcontainer, _options.adid, adcontainer.x, adcontainer.y);
        ads.addEventListener(FGLAds.EVT_API_READY,  function(e:Event)
        {
            ads.showAdPopup();
        });

        // set up the timer/loading bar
        var loadingbg = new Sprite();
        loadingbg.graphics.beginFill(_options.preloaderbackground, 1);
        loadingbg.graphics.drawRect(0, 0, 150, 20);
        loadingbg.x = Std.int((Lib.current.stage.stageWidth - 150) / 2);
        loadingbg.y = adbg.y + adbg.height + 30;
        addChild(loadingbg);

        _loadingBar = new Sprite();
        _loadingBar.graphics.beginFill(_options.preloaderbar, 1);
        _loadingBar.graphics.drawRect(0, 0, 148, 18);
        _loadingBar.x = loadingbg.x + 1;
        _loadingBar.y = loadingbg.y + 1;
        addChild(_loadingBar);

        var loadingformat = new TextFormat();
        loadingformat.color = _options.preloadertext;
        loadingformat.font = "Arial";
        loadingformat.size = 10;
        loadingformat.align = TextFormatAlign.CENTER;

        var loadingblurb = new TextField();
        loadingblurb.embedFonts = false;
        loadingblurb.htmlText =  "LOADING";
        loadingblurb.textColor = _options.preloadertext;
        loadingblurb.width = loadingbg.width;
        loadingblurb.x = loadingbg.x;
        loadingblurb.y = loadingbg.y + 2;
        loadingblurb.setTextFormat(loadingformat);
        loadingblurb.selectable = false;
        loadingblurb.multiline = false;
        addChild(loadingblurb);

        // set up the loading
        _loadTimer = new Timer(50, _timerEnd);
        _loadTimer.addEventListener(TimerEvent.TIMER, tick);
        _loadTimer.start();

        _loaderInfo = flash.Lib.current.loaderInfo;
        _loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ignore);
        _loaderInfo.addEventListener(ProgressEvent.PROGRESS, loading);
        _loaderInfo.addEventListener(Event.COMPLETE, loaded);

        // set up the progress
        addEventListener(Event.ENTER_FRAME, refresh);
    }

    private function refresh(e:Event):Void
    {
        _loadingBar.width = Math.min(_timerProgress, _loadProgress) * 148;

        if(_timerLoaded && _loaderLoaded && preloaderLoaded)
        {
            ready(e);
        }
    }

    private function ready(e:Event):Void
    {
        removeEventListener(Event.ENTER_FRAME, refresh);

        // play time
        var format = new TextFormat();
        format.color = _options.playbuttontext;
        format.font = "Arial";
        format.size = 12;
        format.align = TextFormatAlign.CENTER;

        _button = new Sprite();
        _button.graphics.beginFill(_options.playbuttonbackground, 1);
        _button.graphics.drawRect(0, 0, 150, 22);
        _button.graphics.endFill();
        _button.graphics.lineStyle(0.1, _options.playbuttonborder, 0.5);
        _button.graphics.moveTo(0, 0);
        _button.graphics.lineTo(_button.width, 0);
        _button.graphics.lineTo(_button.width, _button.height);
        _button.graphics.lineTo(0, _button.height);
        _button.graphics.lineTo(0, 0);
        _button.x = _loadingBar.x - 1;
        _button.y = _loadingBar.y - 1;
        _button.mouseChildren = false;
        _button.useHandCursor = true;
        _button.buttonMode = true;
        _button.addEventListener(MouseEvent.CLICK, click);
        _button.addEventListener(MouseEvent.MOUSE_OVER, over);
        _button.addEventListener(MouseEvent.MOUSE_OUT, out);
        addChild(_button);

        _buttonOverlay = new Sprite();
        _buttonOverlay.graphics.lineStyle(0.1, _options.playbuttonborder, 1);
        _buttonOverlay.graphics.moveTo(0, 0);
        _buttonOverlay.graphics.lineTo(_button.width, 0);
        _buttonOverlay.graphics.lineTo(_button.width, _button.height);
        _buttonOverlay.graphics.lineTo(0, _button.height);
        _buttonOverlay.graphics.lineTo(0, 0);
        _buttonOverlay.x = _button.x;
        _buttonOverlay.y = _button.y;
        addChild(_buttonOverlay);

        _buttonLabel = new TextField();
        _buttonLabel.text = "PLAY GAME";
        _buttonLabel.width = _button.width;
        _buttonLabel.height = _button.height;
        _buttonLabel.setTextFormat(format);
        _buttonLabel.textColor = _options.playbuttontext;
        _buttonLabel.selectable = false;
        _buttonLabel.multiline = false;
        _buttonLabel.y = 2;
        _buttonLabel.alpha = 0.8;
        _button.addChild(_buttonLabel);

        _buttonAnim = new Timer(20);
        _buttonAnim.addEventListener(TimerEvent.TIMER, buttonAnimation);
        _buttonAnim.start();
        buttonAnimation(null);
    }

    private function click(e:MouseEvent):Void
    {
        _options.oncomplete(e);
        remove();
    }

    private function over(e:MouseEvent):Void
    {
        _buttonOverlay.alpha = 1;
        _buttonLabel.alpha = 1;
    }

    private function out(e:MouseEvent):Void
    {
        _buttonOverlay.alpha = 0;
        _buttonLabel.alpha = 0.8;
    }

    private function buttonAnimation(e:TimerEvent):Void
    {
        _buttonFrame++;
        _button.filters = [new BlurFilter(4 - (_buttonFrame / 30 * 10), 4  - (_buttonFrame / 30 * 10), 10)];
        _buttonOverlay.alpha = 1 - (_buttonFrame / 20);

        if(_buttonFrame == 20)
        {
            _button.filters = [];
            _buttonAnim.stop();
        }
    }

    private function loading(e:ProgressEvent):Void
    {
        _loadProgress = e.bytesLoaded / e.bytesTotal;
    }

    private function loaded(e:Event):Void
    {
        _loaderLoaded = true;
    }

    private function tick(e:Event):Void
    {
        _timerSteps++;
        _timerProgress = _timerSteps / _timerEnd;

        if(_timerSteps == _timerEnd)
        {
            _timerLoaded = true;
        }

        //trace("timer.tick", _timerSteps, _timerProgress, _timerLoaded);
    }

    public function remove():Void
    {
        if(parent != null)
        {
            parent.removeChild(this);
        }
    }

    private function ignore(e:Event):Void
    {
    }

    private function dispose(e:Event)
    {
        FGLAds.remove();

        removeEventListener(Event.ADDED_TO_STAGE, init);
        removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
        removeEventListener(Event.ENTER_FRAME, refresh);
        _buttonAnim.removeEventListener(TimerEvent.TIMER, buttonAnimation);
        _button.removeEventListener(MouseEvent.CLICK, click);
        _button.removeEventListener(MouseEvent.MOUSE_OVER, over);
        _button.removeEventListener(MouseEvent.MOUSE_OUT, out);
        _loadTimer.removeEventListener(TimerEvent.TIMER, tick);
        _loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ignore);
        _loaderInfo.removeEventListener(ProgressEvent.PROGRESS, loading);
        _loaderInfo.removeEventListener(Event.COMPLETE, loaded);
    }
}
