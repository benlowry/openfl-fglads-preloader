package;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.Lib;

/**
 * <p>The FGLAds object is used to show ads! It's very simple.</p>
 *
 * <ul>
 * <li> Copy <a href="http://flashgamedistribution.com/fglads/FGLAds.as">the FGLAds actionscript file</a> into your project. </li>
 * <li> Call the constructor and pass it the stage and your game ID. You can find your FGL Ads ID on the FGD or FGL website.</li>
 * <li> Add an event listener for the EVT_API_READY event. This fires when
 * everything's ready to go. It should take less than a second.</li>
 * <li> In the event handler, call FGLAds.api.showAdPopup(). By default,
 * it will show a 300x250 ad popup in the center of the game. The user
 * can close it after 3s.</li>
 * </ul>
 *
 * <p><b>Example:</b></p>
 * <p><code><pre>
 * function myInitEvent->Void() {
 *     FGLAds(stage, "FGL-EXAMPLE");
 *     FGLAds.api.addEventListener(EVT_API_READY, onAdsReady);
 * }
 *
 * function onAdsReady(e:Event) {
 *     FGLAds.api.showAdPopup();
 * }
 * </pre></code></p>
 *
 * <p>That's it for now. We'll have more ad formats and more ways to load them soon!</p>
 *
 */
class FGLAds extends Sprite
{
    public static inline var version:String = "01";
    public static inline var EVT_NETWORKING_ERROR:String = "networking_error";
    public static inline var EVT_API_READY:String = "api_ready";
    public static inline var EVT_AD_LOADED:String = "ad_loaded";
    public static inline var EVT_AD_SHOWN:String = "ad_shown";
    public static inline var EVT_AD_CLOSED:String = "ad_closed";
    public static inline var EVT_AD_CLICKED:String = "ad_clicked";
    public static inline var EVT_AD_LOADING_ERROR:String = "ad_loading_error";
    public static inline var FORMAT_300x250:String = "300x250";
    public static inline var FORMAT_90x90:String = "90x90";

    //singleton var
    private static var _instance:FGLAds;

    //status vars
    private var _status:String = "Loading";
    private var _loaded:Bool = false;
    private var _inUse:Bool = false;

    //swf loading vars
    private var _referer:String = "";
    private var _loader:Loader;
    private var _context:LoaderContext;

    //live URL
    private var _request:URLRequest;

    //event handlers
    private var _evt_NetworkingError:Event->Void = null;
    private var _evt_ApiReady:Event->Void = null;
    private var _evt_AdLoaded:Event->Void = null;
    private var _evt_AdShown:Event->Void = null;
    private var _evt_AdClicked:Event->Void = null;
    private var _evt_AdClosed:Event->Void = null;
    private var _evt_AdLoadingError:Event->Void = null;

    //display objects
    private var _fglAds:Dynamic;
    private var _x:Float;
    private var _y:Float;

    public static function remove()
    {
        if(_instance != null && _instance._fglAds != null)
        {
            Lib.current.stage.removeChild(_instance._fglAds);
            _instance._fglAds = null;
            _instance = null;
        }
    }

    public function new(parent:DisplayObjectContainer, gameID:String, px:Float, py:Float)
    {
        super();

        if(_instance == null)
        {
            _instance = this;
        }
        else
        {
            return;
        }

        Security.allowDomain("*");
        Security.allowInsecureDomain("*");			
        Security.loadPolicyFile("http://ads.fgl.com/crossdomain.xml");

        _x = px;
        _y = py;

        _context = new LoaderContext(true);
        _context.applicationDomain = ApplicationDomain.currentDomain;

        _request = new URLRequest("http://ads.fgl.com/swf/FGLAds." + version + ".swf");
        _storedGameID = gameID;

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadingError);
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingComplete);

        try
        {
            _loader.load(_request, _context);
            _status = "Downloading";
        }
        catch(e:Dynamic)
        {
            _status = "Failed";
            _loader = null;
        }

        if(Std.is(parent, Sprite) || Std.is(parent, MovieClip) || Std.is(parent, Stage))
        {
            parent.addChild(this);
        }
        else
        {
        }

        addEventListener(Event.ADDED_TO_STAGE, setupStage);
    }

    public static function api():FGLAds
    {
        if(_instance == null)
        {
            return null;
        }

        return _instance;
    }

    public function showAdPopup(format:String = FORMAT_300x250, delay:Float = 3000, timeout:Float = 0)
    {
        if(_loaded == false)
        {
            return;
        }

        _fglAds.showAdPopup(format, delay, timeout);
    }

    public function status():String
    {
        return _status;
    }

    public static function apiLoaded():Bool
    {
        return _instance != null;
    }

    /**
     * Disable the API. This will stop FGLAds from processing any requests. Use enable() to re-enable the API.
     */
    public function disable()
    {
        if(_status == "Ready")
        {
            _status = "Disabled";
            _loaded = false;
        }
    }

    /**
     * Re-enables the API if it's been disabled using the disable() function.
     */
    public function enable()
    {
        if(_status == "Disabled")
        {
            _status = "Ready";
            _loaded = true;
        }
    }

    // Event handling...

    /** @private */ public function set_onNetworkingError(func:Event->Void)
    {
        _evt_NetworkingError = func;
    }

    /** @private */ public function get_onNetworkingError():Event->Void
    {
        return _evt_NetworkingError;
    }

    private function e_onNetworkingError(e:Event)
    {
        if(_evt_NetworkingError != null)
        {
            _evt_NetworkingError(e);
        }

        dispatchEvent(e);
    }

    /** @private */ public function set_onApiReady(func:Event->Void)
    {
        _evt_ApiReady = func;
    }

    /** @private */ public function get_onApiReady():Event->Void
    {
        return _evt_ApiReady;
    }

    private function e_onApiReady(e:Event)
    {
        if(_evt_ApiReady != null)
        {
            _evt_ApiReady(e);
        }

        dispatchEvent(e);
    }

    /** @private */ public function set_onAdLoaded(func:Event->Void)
    {
        _evt_AdLoaded = func;
    }

    /** @private */ public function get_onAdLoaded():Event->Void
    {
        return _evt_AdLoaded;
    }

    private function e_onAdLoaded(e:Event)
    {
        if(_evt_AdLoaded != null)
        {
            _evt_AdLoaded(e);
        }

        dispatchEvent(e);
    }

    /** @private */ public function set_onAdShown(func:Event->Void)
    {
        _evt_AdShown = func;
    }

    /** @private */ public function get_onAdShown():Event->Void
    {
        return _evt_AdShown;
    }

    private function e_onAdShown(e:Event)
    {
        if(_evt_AdShown != null)
        {
            _evt_AdShown(e);
        }

        dispatchEvent(e);
    }
    /** @private */ public function set_onAdClicked(func:Event->Void)
    {
        _evt_AdClicked = func;
    }

    /** @private */ public function get_onAdClicked():Event->Void
    {
        return _evt_AdClicked;
    }

    private function e_onAdClicked(e:Event)
    {
        if(_evt_AdClicked != null)
        {
            _evt_AdClicked(e);
        }

        dispatchEvent(e);
    }
    /** @private */ public function set_onAdClosed(func:Event->Void)
    {
        _evt_AdClosed = func;
    }

    /** @private */ public function get_onAdClosed():Event->Void
    {
        return _evt_AdClosed;
    }

    private function e_onAdClosed(e:Event)
    {
        if(_evt_AdClosed != null)
        {
            _evt_AdClosed(e);
        }

        dispatchEvent(e);
    }

    /** @private */ public function set_onAdLoadingError(func:Event->Void)
    {
        _evt_AdLoadingError = func;
    }

    /** @private */ public function get_onAdLoadingError():Event->Void
    {
        return _evt_AdLoadingError;
    }

    private function e_onAdLoadingError(e:Event)
    {
        if(_evt_AdLoadingError != null)
        {
            _evt_AdLoadingError(e);
        }

        dispatchEvent(e);
    }

    /* Internal Event->Voids */
    private function resizeStage(e:Event)
    {
        if(_loaded == false)
        {
            return;
        }

        _fglAds.componentWidth = Lib.current.stage.stageWidth;
        _fglAds.componentHeight = Lib.current.stage.stageHeight;
    }

    private function setupStage(e:Event)
    {
        removeEventListener(Event.ADDED_TO_STAGE, setupStage);

        Lib.current.stage.addEventListener(Event.RESIZE, resizeStage);

        if(root != null)
        {
            _referer = root.loaderInfo.loaderURL;
        }

        if(_loaded)
        {
            _fglAds.componentWidth = Lib.current.stage.stageWidth;
            _fglAds.componentHeight = Lib.current.stage.stageHeight;
        }
    }

    private function onLoadingComplete(e:Event)
    {
        _status = "Ready";
        _loaded = true;
        _fglAds = _loader.content;
        _fglAds.componentWidth = Lib.current.stage.stageWidth;
        _fglAds.componentHeight = Lib.current.stage.stageHeight;
        _fglAds.addEventListener(EVT_NETWORKING_ERROR, e_onNetworkingError);
        _fglAds.addEventListener(EVT_API_READY, e_onApiReady);
        _fglAds.addEventListener(EVT_AD_LOADED, e_onAdLoaded);
        _fglAds.addEventListener(EVT_AD_SHOWN, e_onAdShown);
        _fglAds.addEventListener(EVT_AD_CLICKED, e_onAdClicked);
        _fglAds.addEventListener(EVT_AD_CLOSED, e_onAdClosed);
        _fglAds.addEventListener(EVT_AD_LOADING_ERROR, e_onAdLoadingError);
        _fglAds.scrollRect = new Rectangle(Math.floor((Lib.current.stage.stageWidth - 300) / 2), Math.floor((Lib.current.stage.stageHeight - 250) / 2), 300, 250);
        _fglAds.x = _x;
        _fglAds.y = _y;

        if(Lib.current.stage != null)
        {
            Lib.current.stage.addChild(_fglAds);
        }

        if(root != null)
        {
            _referer = root.loaderInfo.loaderURL;
        }

        _fglAds.init(Lib.current.stage, _referer, _storedGameID);
    }

    private function onLoadingError(e:IOErrorEvent)
    {
        _loaded = false;
        _status = "Failed";
    }

    private var _storedGameID:String = "";
}
