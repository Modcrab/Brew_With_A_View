package red.game.witcher3.menus.worldmap
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.Label;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.menus.worldmap.ImageContainer;
	
	public class LodContainer extends UIComponent
	{
		private var _backgroundContainer : ImageContainer;
		private var _imageContainer : Vector.< ImageContainer >;
		private var _currentLod : int = -1;
		
		private var _minLod : int;
		private var _maxLod : int;

		public function GetContainer( lod : int ) : ImageContainer
		{
			if ( lod >= 0 && lod < _imageContainer.length )
			{
				return _imageContainer[ lod ];
			}
			return null;
		}

		public function GetCurrentContainer() : ImageContainer
		{
			return GetContainer( _currentLod );
		}
		
		public function GetMinLod() : int
		{
			return _minLod;
		}
		
		public function GetMaxLod() : int
		{
			return _maxLod;
		}
		
		public function GetCurrentLod() : int
		{
			return _currentLod;
		}
		
		public function SetCurrentLod( lod : int, addCurrentToTop : Boolean )
		{
			if ( addCurrentToTop )
			{
				addChild( _imageContainer[ _currentLod ] );
			}
			_currentLod = lod;
		}

		public function CreateLods( textureSize : int, minLod : int, maxLod : int, mapImagePath : String, mapMinX : int, mapMaxX : int, mapMinY : int, mapMaxY : int )
		{
			DeleteLods();

			_minLod = minLod;
			_maxLod	= maxLod;
			_imageContainer = new Vector.< ImageContainer >;

			var ref : Class = getDefinitionByName( "ImageContainer" ) as Class;

			//////////////////////
			// background
			_backgroundContainer = new ref();
			_backgroundContainer.CreateLod( textureSize, 0, mapImagePath, mapMinX, mapMaxX, mapMinY, mapMaxY );
			_backgroundContainer.ShowAllTiles();
			addChild( _backgroundContainer );
			//
			//////////////////////

			for ( var lod = 0; lod <= maxLod; ++lod )
			{
				if ( lod < minLod )
				{
					_imageContainer[ lod ] = null;
					continue;
				}
				var container : ImageContainer = new ref();
				addChild( container );
				
				container.CreateLod( textureSize, lod, mapImagePath, mapMinX, mapMaxX, mapMinY, mapMaxY );
				_imageContainer[ lod ] = container;
			}
			
			SetCurrentLod( maxLod, false );
		}
		
		private function DeleteLods()
		{
			if ( _backgroundContainer )
			{
				_backgroundContainer.DeleteTiles();
				removeChild( _backgroundContainer );
				_backgroundContainer = null;
			}
			
			if ( _imageContainer )
			{
				for ( var i : int = 0; i < _imageContainer.length; ++i )
				{
					var container : ImageContainer = _imageContainer[ i ];
					if ( container )
					{
						container.DeleteTiles();
						removeChild( container );
					}
				}
				_imageContainer = null;
			}
		}
		
		public function UpdateDebugBorders()
		{
			var container : ImageContainer = GetCurrentContainer();
			if ( container )
			{
				container.UpdateDebugBorders();
			}
		}

	}
}
