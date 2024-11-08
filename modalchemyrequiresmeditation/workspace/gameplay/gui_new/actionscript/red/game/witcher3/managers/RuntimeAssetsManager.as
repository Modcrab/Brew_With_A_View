package red.game.witcher3.managers 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import scaleform.gfx.Extensions;
	
	/**	
	 * @author Yaroslav Getsevich
	 */
	public class RuntimeAssetsManager extends EventDispatcher
	{
		private static const GAME_ASSETS_LIB_PATH:String = "swf/common/ComponentsLib.swf";
		private static const DEBUG_ASSETS_LIB_PATH:String = "../common/ComponentsLib.swf";
		private static var _instance:RuntimeAssetsManager;
		private var _isLoaded:Boolean;
		private var _isLoading:Boolean;
		private var _loader:Loader;		
		private var _loadCallback:Function;
		
		public function RuntimeAssetsManager()
		{
			_isLoading = false;
			_isLoaded = false;
		}
		
		public static function getInstanse():RuntimeAssetsManager 
		{
			if (!_instance) _instance = new RuntimeAssetsManager();
			return _instance;
		}
		
		public function get isLoaded():Boolean { return _isLoaded }
		public function set isLoaded(value:Boolean):void 
		{ 
			trace("GFX WARNING: [RuntimeAssetsManager] Sorry, isLoaded is read only.")
		}
		
		public function loadLibrary(loadCallback:Function = null):void
		{
			_loadCallback = loadCallback;
			if (_isLoading)
			{
				return;
			}
			if (_isLoaded)
			{
				tryCallback();
			}
			else
			{
				loadAssets();
			}
		}
		
		public function unloadLibrary():void
		{
			if (_loader)
			{
				_loader.unloadAndStop(true);
				_loader = null;
				_isLoaded = false;
				_isLoading = false;
			}
		}
		
		public function getAsset(assetDefinition:String):DisplayObject
		{
			if (!_isLoaded)
			{
				throw new Error("RuntimeAssetsManager is not loaded!");
				return;
			};
			try
			{
				var DisplayItemClass:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition(assetDefinition) as Class;
				var DisplayItem:DisplayObject = new DisplayItemClass() as DisplayObject;
				if (DisplayItem)
				{
					return DisplayItem;
				}
				else
				{
					// Can't convert to DisplayObject, maybe it's a bitmap
					return new Bitmap(new(DisplayItemClass));
				}
				
			}
			catch (err:Error)
			{
				trace("GFX [WARNING] AssetsManager, can't load asset \"" + assetDefinition + "\"", err.message);
				return null;
			}
			return null;
		}
		
		/*
		 * Underhood
		 */
		
		protected function tryCallback():void
		{
			if (_loadCallback != null) _loadCallback();
		}
		
		protected function loadAssets():void
		{
			var libPath:String = Extensions.isScaleform ? GAME_ASSETS_LIB_PATH : DEBUG_ASSETS_LIB_PATH;
			var context:LoaderContext = new LoaderContext();
			var current:ApplicationDomain = ApplicationDomain.currentDomain;
			context.applicationDomain = current;//new ApplicationDomain(current); // let's load it to the same domain
			
			_loader = new Loader();
			_loader.load(new URLRequest(libPath), context);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleAssetsLoaded, false, 0, true);
			_isLoading = true;
		}
		
		protected function handleAssetsLoaded(event:Event):void
		{			
			_isLoaded = true;
			_isLoading = false;
			_loadCallback = null;
			tryCallback();
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
