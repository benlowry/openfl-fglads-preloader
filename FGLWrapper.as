/*
untested actionscript version (the origin of) of the haxe version
*/

package 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.BlurFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class FGLAdWrapper extends Sprite
	{
		private var _options:Object;
		private var _warnings:Vector.<String>;
		private var _timerSteps:int;
		private const _timerEnd:int = 300;
		private var _timerProgress:Number = 0;
		private var _loadProgress:Number = 0;
		private var _loadingBar:Sprite;
		private var _timerLoaded:Boolean = false;
		private var _loaderLoaded:Boolean = false;
		private var _button:Sprite;
		private var _buttonOverlay:Sprite;
		private var _buttonFrame:int = 0;
		private var _buttonAnim:Timer;
		private var _buttonLabel:TextField;
		private var _loadTimer:Timer;

		public function FGLAdWrapper(options:Object = null)
		{
			_options = options || {};
			_warnings = new Vector.<String>();
			
			if(!_options.gametitle) {
				_warnings.push("Please set options.gametitle in your ad initialization");
				_options.gametitle = "GAMETITLE";
			}
			
			if(!_options.developer) {
				_warnings.push("Please set options.developer in your ad initialization, and options.developerlink if you want it to link to your website");
				_options.developer = "UNKNOWN";
				_options.developerlink = "#";
			}
			
			if(!_options.oncomplete) {
				_warnings.push("Please set options.oncomplete with your callback function else the ad cannot exit");
			}

			// default values
			if(!_options.background) { _options.background = 0x1C3755; }
			if(!_options.fgltext) { _options.fgltext = 0x999999; }
			if(!_options.fglbackground) { _options.fglbackground = 0x000000; }
			if(!_options.titletext) { _options.titletext = 0xCCCCCC; }
			if(!_options.titlebackground) { _options.titlebackground = 0x000000; }
			if(!_options.preloaderbackground) { _options.preloaderbackground = 0x000000; }
			if(!_options.preloaderbar) { _options.preloaderbar = 0x253240; }
			if(!_options.preloadertext) { _options.preloadertext = 0xCCCCCC; }
			if(!_options.playbuttonbackground) { _options.playbuttonbackground = 0x000000; }
			if(!_options.playbuttonborder) { _options.playbuttonborder = 0xFFFFFF; }
			if(!_options.playbuttontext) { _options.playbuttontext = 0xCCCCCC; }
			if(!_options.adbackground) { _options.adbackground = 0x000000; }
			if(!_options.developerlink) { _options.developerlink = "#"; }
			if(!_options.developer) { _options.developer = ""; }
			if(!_options.sponsorlink) { _options.sponsorlink = "#"; }
			if(!_options.sponsor) { _options.sponsor = ""; }
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, dispose, false, 0, true);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);

			if(stage.stageHeight < 300 || stage.stageWidth < 400) {
				_warnings.push("Your game must be at least 400x300 pixels");
			}
			
			if(_warnings.length > 0) {
				
				trace("The following errors caused your ad request to be aborted:");
				trace(_warnings.join("\n"));
				
				if(_options.oncomplete) {
					_options.oncomplete();
				}
				
				return;
			}

		    var bottom = 0;

		    if(_options.custombackground)
		    {
		        addChild(_options.custombackground);
		        bottom = 1;
		    }
			
			// the background color, which we will make configurable
			graphics.beginFill(_options.background, 1);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
		
			// set up the fgl link
			var pformat:TextFormat = new TextFormat();
			pformat.color = _options.fgltext;
			pformat.font = "Arial";	
			pformat.size = "10";
			
			var fgl:TextField = new TextField();
			fgl.embedFonts = false;
			fgl.autoSize = TextFieldAutoSize.RIGHT;
			fgl.htmlText = "<a href=\"https://fgl.com/?game=" + _options.adid + "\" target=\"_blank\">ads by fgl</a>";
			fgl.x = stage.stageWidth - int(fgl.width) - 2;
			fgl.y = stage.stageHeight - int(fgl.height);
			fgl.setTextFormat(pformat);
			fgl.selectable = false;
			fgl.textColor = _options.fgltext;
			addChild(fgl);
			
			var fglbg:Sprite = new Sprite();
			fglbg.graphics.beginFill(_options.fglbackground);
			fglbg.graphics.drawRect(0, 0, int(fgl.width) + 4, int(fgl.height) + 2);
			fglbg.graphics.endFill();
			fglbg.x = stage.stageWidth - fglbg.width;
			fglbg.y = stage.stageHeight - fglbg.height;
			addChildAt(fglbg, bottom);
			
			// set up the game title, sponsor and developer link
			var devformat:TextFormat = new TextFormat();
			devformat.color = _options.titletext;
			devformat.font = "Arial";		
			devformat.size = "12";
			
			var devtext:String = _options.gametitle + " by <a href=\"" + _options.developerlink + "\" target=\"_blank\"><b>" + _options.developer + "</b></a>";
			
			if(_options.sponsor) {
				devtext += " and <a href=\"" + _options.sponsorlink + "\" target=\"_blank\"><b>" + _options.sponsor + "</b></a>";
			}
			
			var devblurb:TextField = new TextField();
			devblurb.autoSize = TextFieldAutoSize.LEFT;
			devblurb.embedFonts = false;
			devblurb.htmlText =  devtext;
			devblurb.textColor = _options.titletext;
			devblurb.x = 2;
			devblurb.y = 0;
			devblurb.setTextFormat(devformat);
			devblurb.selectable = false;
			addChild(devblurb);
			
			var devblurbbg:Sprite = new Sprite();
			devblurbbg.graphics.beginFill(_options.titlebackground, 0.5);
			devblurbbg.graphics.drawRect(0, 0, int(devblurb.width) + 6, int(devblurb.height) + 2);
			devblurbbg.graphics.endFill();
			devblurbbg.x = 0;
			devblurbbg.y = 0;
			addChildAt(devblurbbg, bottom);
			
			// set up the ad box
			var adbg:Sprite = new Sprite();
			adbg.graphics.beginFill(_options.adbackground, 1);
			adbg.graphics.drawRect(0, 0, 308, 258);
			adbg.x = int((stage.stageWidth - 308) / 2);
			adbg.y = int((stage.stageHeight - 258) / 2) - 20;
			adbg.alpha = 0.8;
			addChild(adbg);
			
			// set up the ad
	        var adcontainer:Sprite = new Sprite();
	        adcontainer.x = adbg.x + 4;
	        adcontainer.y = adbg.y + 4;
	        addChild(adcontainer);

	        var ads = new FGLAds(adcontainer, _options.adid, adcontainer.x, adcontainer.y);
	        ads.addEventListener(FGLAds.EVT_API_READY, function(e:Event)
	        {
	            ads.showAdPopup();
	        });
			
			// set up the timer/loading bar
			var loadingbg:Sprite = new Sprite();
			loadingbg.graphics.beginFill(_options.preloaderbackground, 1);
			loadingbg.graphics.drawRect(0, 0, 150, 20);
			loadingbg.x = int((stage.stageWidth - 150) / 2);
			loadingbg.y = adbg.y + adbg.height + 30;
			addChild(loadingbg);
			
			_loadingBar = new Sprite();
			_loadingBar.graphics.beginFill(_options.preloaderbar, 1);
			_loadingBar.graphics.drawRect(0, 0, 148, 18);
			_loadingBar.x = loadingbg.x + 1;
			_loadingBar.y = loadingbg.y + 1;
			addChild(_loadingBar);
			
			var loadingformat:TextFormat = new TextFormat();
			loadingformat.color = _options.preloadertext;
			loadingformat.font = "Arial";		
			loadingformat.size = "10";
			loadingformat.align = "center";
			
			var loadingblurb:TextField = new TextField();
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
			_loadTimer = new Timer(20, _timerEnd);
			_loadTimer.addEventListener(TimerEvent.TIMER, tick, false, 0, true);
			_loadTimer.start();
			 
			root.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ignore, false, 0, true);
			root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, loading, false, 0, true);
			root.loaderInfo.addEventListener(Event.COMPLETE, loaded, false, 0, true);
			
			// set up the progress 
			addEventListener(Event.ENTER_FRAME, refresh, false, 0, true);
		}
		
		private function refresh(e:Event):void
		{
			_loadingBar.width = Math.min(_timerProgress, _loadProgress) * 148;
			
			if(_timerLoaded && _loaderLoaded)
			{
				ready(e);
			}
		}
		
		private function ready(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, refresh, false);
			
			// play time
			var format:TextFormat = new TextFormat();
			format.color = _options.playbuttontext;
			format.font = "Arial";		
			format.size = "12";
			format.align = "center";
			
			_button = new Sprite();
			_button.graphics.beginFill(_options.playbuttonbackground, 1);
			_button.graphics.drawRect(0, 0, 150, 22);
			_button.graphics.endFill();
			_button.graphics.lineStyle(0.1, _options.playbuttonborder || 0xFFFFFF, 0.5);
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
			_button.addEventListener(MouseEvent.CLICK, click, false, 0, true);
			_button.addEventListener(MouseEvent.MOUSE_OVER, over, false, 0, true);
			_button.addEventListener(MouseEvent.MOUSE_OUT, out, false, 0, true);
			addChild(_button);
			
			_buttonOverlay = new Sprite();
			_buttonOverlay.graphics.lineStyle(0.1, _options.playbuttonborder || 0xFFFFFF, 1);
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
			_buttonAnim.addEventListener(TimerEvent.TIMER, buttonAnimation, false, 0, true);
			_buttonAnim.start();
			buttonAnimation(null);
		}
		
		private function click(e:MouseEvent):void
		{
			_options.oncomplete();
			remove();	
		}
		
		private function over(e:MouseEvent):void
		{
			_buttonOverlay.alpha = 1;
			_buttonLabel.alpha = 1;
		}
		
		private function out(e:MouseEvent):void
		{
			_buttonOverlay.alpha = 0;	
			_buttonLabel.alpha = 0.8;
		}
		
		private function buttonAnimation(e:TimerEvent):void
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
		
		private function loading(e:ProgressEvent):void
		{
			_loadProgress = e.bytesLoaded / e.bytesTotal;
		}
		
		private function loaded(e:Event):void
		{
			_loaderLoaded = true;
		}
		
		private function tick(e:Event):void
		{
			_timerSteps++;
			_timerProgress = _timerSteps / _timerEnd;

			if(_timerSteps == _timerEnd)
			{
				_timerLoaded = true;
			}
		}
		
		public function remove():void
		{
			if(parent) {
				// TODO: deactivate the ads here
				parent.removeChild(this);
			}
		}
		
		private function ignore(e:Event):void
		{
		}

		private function dispose(e:Event):void
		{
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
}