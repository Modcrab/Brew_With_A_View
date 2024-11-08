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
	import red.game.witcher3.menus.worldmap.HubMapTile;
	
	public class ImageContainer extends UIComponent
	{
		private var _tiles : Vector.< Vector.< HubMapTile > >;
		private var _boundariesX : Vector.< Boundary >;
		private var _boundariesY : Vector.< Boundary >;
		private var _tileCount : int;
		private var _tileScale : Number;
		
		private var _mapImagesPath		: String;
		private var _mapTextureSize		: int;
		private var _currentLod			: int;
		
		private var _tileMinX			: int;
		private var _tileMaxX			: int;
		private var _tileMinY			: int;
		private var _tileMaxY			: int;

		private var _tilesInvisible		: int = 0;
		private var _tilesVisible		: int = 0;
		
		private var _hideInterval		: int = 0;
		
		private var _showOnlyTilesFromBoundaries : Boolean = true;


		protected override function configUI():void
		{
			super.configUI();
		}
		
		public function GetMapTextureSize() : int
		{
			return _mapTextureSize;
		}
		
		public function CreateLod( textureSize : int, lod : int, path : String, mapMinX : int, mapMaxX : int, mapMinY : int, mapMaxY : int )
		{
			DeleteTiles();
	
			//
			//trace("Minimap CREATE LOD " + lod + " ----------------------------------------------------" );
			//
			
			_mapTextureSize = textureSize;
			_currentLod = lod;
			_mapImagesPath = path;
			
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetCurrentLod( _currentLod );
			//
			//
			//
			
			_tileCount = Math.pow( 2, _currentLod );
			_tileScale = Math.pow( 2, _currentLod - 1 );

			//
			//trace("Minimap _tileCount " + _tileCount + "    _tileScale " + _tileScale );
			//
			
			CreateBoundaries();

			_tileMinX = GetBoundaryX( mapMinX + 1 );
			_tileMaxX = GetBoundaryX( mapMaxX - 1 );
			_tileMinY = GetBoundaryY( mapMinY + 1 );
			_tileMaxY = GetBoundaryY( mapMaxY - 1 );
			//
			//trace("Minimap BOUNDARIES " + _tileMinX + " " + _tileMinY + "   " + _tileMaxX + " " + _tileMaxY );
			//

			CreateTiles();
			
			//PrintTiles();
			//PrintTiles2();
		}

		private function CreateBoundaries()
		{
			var tx, ty : int;
			
			_boundariesX = new Vector.< Boundary >;
			for ( tx = 0; tx < _tileCount; ++tx )
			{
				_boundariesX[ tx ] = new Boundary( -( _tileScale - tx )     * _mapTextureSize / _tileScale,
												   -( _tileScale - tx - 1 ) * _mapTextureSize / _tileScale );
				//
				//trace("Minimap BX " + tx + " " + _boundariesX[ tx ]._min + " " + _boundariesX[ tx ]._max );
				//
			}

			_boundariesY = new Vector.< Boundary >;
			for ( ty = 0; ty < _tileCount; ++ty )
			{
				_boundariesY[ ty ] = new Boundary( -( _tileScale - ty )     * _mapTextureSize / _tileScale,
												   -( _tileScale - ty - 1 ) * _mapTextureSize / _tileScale );
				//
				//trace("Minimap BY " + ty + " " + _boundariesY[ ty ]._min + " " + _boundariesY[ ty ]._max );
				//
			}
		}

		private function CreateTiles()
		{
			var path : String = "img://maps/" + _mapImagesPath + "/level" + _currentLod + "/tile";
			var extension : String = ".jpg"

			var tx, ty;
			_tiles = new Vector.< Vector.< HubMapTile > >;
			for ( ty = 0; ty < _tileCount; ++ty )
			{
				var coefY : Number = _tileScale - ty - 1;

				_tiles[ ty ] = new Vector.< HubMapTile >;
				for ( tx = 0; tx < _tileCount; ++tx )
				{
					var coefX : Number = _tileScale - tx;
					
					//
					//trace("Minimap TILE " + coefX + " " + path + " " + tx + " " + ty + "   " + (coefX * _mapTextureSize / _tileScale) + " " + -coefY * _mapTextureSize / _tileScale );
					//
					
					_tiles[ ty ][ tx ] = new HubMapTile( path + tx + "x" + ty + extension,
														 tx, ty,
														 coefX * _mapTextureSize / _tileScale,
											  			-coefY * _mapTextureSize / _tileScale,
		 											     _tileScale,
														 this
													 );
				}
			}
		}
		
		public function DeleteTiles()
		{
			if ( !_tiles )
			{
				return;
			}
			
			var tx, ty;
			for ( ty = 0; ty < _tileCount; ++ty )
			{
				for ( tx = 0; tx < _tileCount; ++tx )
				{
					_tiles[ ty ][ tx ].ShowTile( false );
				}
			}

			for ( ty = 0; ty < _tileCount; ++ty )
			{
				_tiles[ ty ].splice( 0, _tiles[ ty ].length );
				_tiles[ ty ] = null;
			}
			_tiles.splice( 0, _tiles.length );
			_tiles = null;
		}
		
		private function PrintTiles()
		{
			for ( var ty = 0; ty < _tileCount; ++ty )
			{
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					var tile : HubMapTile = _tiles[ ty ][ tx ] as HubMapTile;
					trace("Minimap Oouu " + tile._tileX + " " + tile._tileY + " " + tile._filename + " " + ( tile._shiftX ) + " " + ( tile._shiftY ) );
				}
			}
		}

		private function PrintTiles2()
		{
			trace("Minimap --------------------------------" );
			for ( var ty = _tileCount - 1; ty >= 0; --ty )
			{
				var line : String = "";
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					var tile : HubMapTile = _tiles[ ty ][ tx ] as HubMapTile;
					if ( tile.IsLoader() )
					{
						line += "X";
					}
					else
					{
						line += ".";
					}
				}
				trace("Minimap " + line );
			}
			trace("Minimap --------------------------------" );
		}
		
		public function GetBoundaryX( val : Number ) : int
		{
			var len : int = _boundariesX.length
			for ( var bx = 0; bx < len; ++bx )
			{
				if ( _boundariesX[ bx ].IsInside( val ) )
				{
					return bx;
				}
			}
			if ( val >= _boundariesX[ len - 1 ]._max )
			{
				return len;
			}
			return -1;
		}

		public function GetBoundaryY( val : Number ) : int
		{
			var len : int = _boundariesY.length
			for ( var by = 0; by < len; ++by )
			{
				if ( _boundariesY[ by ].IsInside( val ) )
				{
					return by;
				}
			}
			if ( val >= _boundariesY[ len - 1 ]._max )
			{
				return len;
			}
			return -1;
		}

		public function UpdateTileStats()
		{
			/*
			_tilesInvisible		= 0;
			_tilesVisible		= 0;
			
			for ( var ty = 0; ty < _tileCount; ++ty )
			{
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					var tile : HubMapTile = _tiles[ ty ][ tx ] as HubMapTile;
					if ( tile )
					{
						if ( tile.IsLoader() )
						{
							_tilesVisible++;
						}
						else
						{
							_tilesInvisible++;
						}
					}
				}
			}

			//
			//trace("Minimap STATS: " +  _currentLod, _tilesVisible, _tilesInvisible );
			//
			
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetTileStats( _currentLod, _tilesVisible, _tilesInvisible );
			//
			//
			//
			
			*/
		}
		
		public function UpdateTiles( center : Point, min : Point, max : Point )
		{
			//var centerIndexX : int = GetBoundaryX( center.x );
			//var centerIndexY : int = GetBoundaryY( center.y );
			var minIndexX    : int = GetBoundaryX(  min.x );
			var minIndexY    : int = GetBoundaryY( -min.y );
			var maxIndexX    : int = GetBoundaryX(  max.x );
			var maxIndexY    : int = GetBoundaryY( -max.y );
			
			//
			//trace("Minimap VIEWPORT " + minIndexX + " " + maxIndexX + "   " + minIndexY + " " + maxIndexY );
			//
			
			var count : int = 0;
			//trace("Minimap -----------------------------------" );
			for ( var ty = 0; ty < _tileCount; ++ty )
			{
				if ( _showOnlyTilesFromBoundaries && ( ty < _tileMinY || ty > _tileMaxY ) )
				{
					continue;
				}
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					if ( _showOnlyTilesFromBoundaries && ( tx < _tileMinX || tx > _tileMaxX ) )
					{
						continue;
					}

					if ( tx >= minIndexX && tx <= maxIndexX &&
						 ty >= minIndexY && ty <= maxIndexY )
					{
						_tiles[ ty ][ tx ].ShowTile( true );
						count++;
						//trace("Minimap SHOW " + tx + " " + ty );
					}
					else
					{
						_tiles[ ty ][ tx ].ShowTile( false );
					}
				}
			}
			//trace("Minimap Tiles shown: " + count );
			
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetVisibleAndPointedTiles( count, minIndexX, minIndexY, maxIndexX, maxIndexY );
			//
			
			UpdateTileStats();
			
			_hideInterval = 0;
		
		}
		
		public function ShowAllTiles()
		{
			for ( var ty = 0; ty < _tileCount; ++ty )
			{
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					var tile : HubMapTile = _tiles[ ty ][ tx ];
					if ( tile )
					{
						tile.ShowTile( true );
					}
				}
			}
		}

		public function HideTiles()
		{
			//
			//trace("Minimap HideTiles" );
			//
			for ( var ty = 0; ty < _tileCount; ++ty )
			{
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					var tile : HubMapTile = _tiles[ ty ][ tx ];
					if ( tile )
					{
						tile.ShowTile( false );
					}
				}
			}

			UpdateTileStats();
		}
		
		public function RequestHideTiles()
		{
			//
			//trace("Minimap RequestHideTiles " + _currentLod );
			//
			_hideInterval = 1000;
		}

		public function ProcessHidingTiles( interval : int )
		{
			if ( _hideInterval > 0 )
			{
				_hideInterval -= interval;
				if ( _hideInterval <= 0 )
				{
					HideTiles();
				}
			}
		}
		
		public function UpdateDebugBorders()
		{
			for ( var ty = 0; ty < _tileCount; ++ty )
			{
				for ( var tx = 0; tx < _tileCount; ++tx )
				{
					var tile : HubMapTile = _tiles[ ty ][ tx ];
					if ( tile && tile.IsLoader() )
					{
						tile.UpdateDebugBorders();
					}
				}
			}
		}
	}
}

class Boundary
{
	public var _min : int;
	public var _max : int;

	public function Boundary( min : int, max : int )
	{
		_min = min;
		_max = max;
	}
	
	public function IsInside( val : int ) : Boolean
	{
		return val >= _min && val <= _max;
	}
}

