package red.game.witcher3.menus.worldmap
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import flash.net.URLRequest;
	import flash.filters.GlowFilter;
	
	public class HubMapTile
	{
		var _filename : String;
		var _tileX : int;
		var _tileY : int;
		var _shiftX : Number;
		var _shiftY : Number;
		var _tileScale : Number;
		var _fixedTileScale : Number;
		var _container : MovieClip;

		var _isLoading : Boolean = false;
		var _loader : HubMapTileLoader;

		public function HubMapTile( filename : String, tileX : int, tileY : int, shiftX : Number, shiftY : Number, tileScale : Number, container : MovieClip )
		{
			super();
			
			_filename = filename;
			_tileX = tileX;
			_tileY = tileY;
			_shiftX = shiftX;
			_shiftY = shiftY;
			_tileScale  = tileScale;
			//_fixedTileScale = _tileScale * 0.999;
			_fixedTileScale = _tileScale;
			_container = container;
			_loader = new HubMapTileLoader();
			_loader.x -= ( _shiftX );
			_loader.y -= ( _shiftY );
			_loader.addEventListener( Event.COMPLETE, handleImageLoaded, false, 0, true);
			_loader.addEventListener( IOErrorEvent.IO_ERROR, handleImageFailed, false, 0, true );
		}
		
		public function ShowTile( show : Boolean )
		{
			if ( !_loader )
			{
				return;
			}

			if ( show )
			{
				if ( _loader.source != _filename )
				{
					//
					//trace("Minimap ++++++" + _filename );
					//
					_isLoading = true;
					_loader.source = _filename;
					_container.addChild( _loader );

					//UpdateDebugBorders();
				}
			}
			else
			{
				if ( _loader.source )
				{
					//
					//trace("Minimap ------" + _filename );
					//
					_container.removeChild( _loader );
					_loader.source = null;
				}
			}
		}
		
		public function IsLoader() : Boolean
		{
			return _loader != null;
		}

		protected function handleImageLoaded(event:Event):void
		{
			_isLoading = false;

			var image : Bitmap = Bitmap( event.target.content );
			if ( image )
			{
				image.smoothing = true;
				image.pixelSnapping = PixelSnapping.ALWAYS;
				
				// lod scaling
				image.scaleX /= _fixedTileScale;
				image.scaleY /= _fixedTileScale;
			}
		}
		
		protected function handleImageFailed(event:Event):void
		{
			_isLoading = false;
		}
		
		public function UpdateDebugBorders()
		{
			if ( MapMenu.m_showDebugBorders )
			{
				_loader.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 2, 1, true) ];
			}
			else
			{
				_loader.filters = [];
			}
		}
		
	}
}
