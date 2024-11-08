package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.Bitmap;
	//import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import scaleform.clik.controls.UILoader;
	
	public class MinimapTile extends Sprite
	{
		//private var _dirty : Boolean = true;
		private var _tileX : int = -1;
		private var _tileY : int = -1;
		//private var _loadedTileX : int = -1;
		//private var _loadedTileY : int = -1;
		private var _loader : UILoader = new UILoader();
		
		public function MinimapTile()
		{
			addChild( _loader );
			//_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, handleImageLoad, false, 0, true );
		}
		
		public function load( url : String, tileX : int, tileY : int ):void
		{
			//_dirty = false;
			_tileX = tileX;
			_tileY = tileY;
		//	_loader.source = url;
			//_loader.load( new URLRequest( url ) );
		}
		
		public function replaceLoader( newLoader : UILoader, tileX : int, tileY : int ) : UILoader
		{
			var oldLoader : UILoader = _loader;
			_loader = newLoader;
			_tileX = tileX;
			_tileY = tileY;
			removeChild( oldLoader );
			addChild( newLoader );
			return oldLoader;
		}
		
		private function handleImageLoad( event:Event ):void
		{
			var bm:Bitmap = Bitmap( event.currentTarget.content );
			bm.smoothing = true;
		}
	}
}