package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
	import flash.filters.GlowFilter;

	public class HubMapContainer extends UIComponent
	{
		private const TILE_NW = 0;
		private const TILE_N  = 1;
		private const TILE_NE = 2;
		private const TILE_W  = 3;
		private const TILE_C  = 4;
		private const TILE_E  = 5;
		private const TILE_SW = 6;
		private const TILE_S  = 7;
		private const TILE_SE = 8;
		private const TILE_COUNT = 9;

		private var m_tileShiftX : Vector.< Number >;
		private var m_tileShiftY : Vector.< Number >;

		private var m_tileFilenames	: Vector.< String >;
		private var m_tileVisible	: Vector.< Boolean >;
		private var m_tiles			: Vector.< MinimapLoader >;
		private var m_playerTileX	: int = -1;
		private var m_playerTileY	: int = -1;

		public function HubMapContainer()
		{
			m_tileShiftX    = new Vector.< Number >( TILE_COUNT );
			m_tileShiftY    = new Vector.< Number >( TILE_COUNT );
		}
		
		override protected function configUI():void
		{
			super.configUI();

			m_tileFilenames	= new Vector.< String >( TILE_COUNT );
			m_tileVisible	= new Vector.< Boolean >( TILE_COUNT );
			m_tiles			= new Vector.< MinimapLoader >( TILE_COUNT );

			var loader : MinimapLoader;
			for ( var i : int = 0; i < TILE_COUNT; ++i )
			{
				loader = new MinimapLoader();
				loader.autoSize = false;
				addChild( loader );
				
				m_tiles[ i ] = loader;
			}
		}
		
		public function InitializeTilePositions()
		{
			var shift = HudModuleMinimap2.m_tileExteriorTextureSize /*+ 2*/;
			var offset = 0.5; // offset to remove gaps among neighboring tile textures, seems to be working this way
			
			m_tileShiftX[ 0 ] = - shift + offset;
			m_tileShiftX[ 3 ] = - shift + offset;
			m_tileShiftX[ 6 ] = - shift + offset;

			m_tileShiftX[ 1 ] =   0;
			m_tileShiftX[ 4 ] =   0;
			m_tileShiftX[ 7 ] =   0;

			m_tileShiftX[ 2 ] = + shift - offset;
			m_tileShiftX[ 5 ] = + shift - offset;
			m_tileShiftX[ 8 ] = + shift - offset;

			
			m_tileShiftY[ 0 ] = - shift - shift + offset;
			m_tileShiftY[ 1 ] = - shift - shift + offset;
			m_tileShiftY[ 2 ] = - shift - shift + offset;

			m_tileShiftY[ 3 ] = - shift;
			m_tileShiftY[ 4 ] = - shift;
			m_tileShiftY[ 5 ] = - shift;

			m_tileShiftY[ 6 ] = - shift + shift - offset;
			m_tileShiftY[ 7 ] = - shift + shift - offset;
			m_tileShiftY[ 8 ] = - shift + shift - offset;
		}
		
		public function UpdatePosition( radius : Number, playerTexturePosX : Number, playerTexturePosY : Number )
		{
			x = playerTexturePosX;
			y = playerTexturePosY;
			
			var largeRadius : Number = radius * 1.25;
			var largeRadiusDistanceSquared : Number = largeRadius * largeRadius;
			
			var playerTilePosX : Number = -HudModuleMinimap2.m_playerTilePosX;
			var playerTilePosY : Number = -HudModuleMinimap2.m_playerTilePosY;
			var tileSize       : Number = HudModuleMinimap2.m_tileSize;
			
			var leftPosSquared   : Number = playerTilePosX * playerTilePosX;
			var rightPosSquared  : Number = ( tileSize - playerTilePosX ) * ( tileSize - playerTilePosX );
			var bottomPosSquared : Number = playerTilePosY * playerTilePosY;
			var topPosSquared    : Number = ( tileSize - playerTilePosY ) * ( tileSize - playerTilePosY );
			
			m_tileVisible[ TILE_NW ] = ( leftPosSquared  + topPosSquared    < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_N  ] = ( topPosSquared                      < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_NE ] = ( rightPosSquared + topPosSquared    < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_W  ] = ( leftPosSquared                     < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_C  ] =  true;
			m_tileVisible[ TILE_E  ] = ( rightPosSquared                    < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_SW ] = ( leftPosSquared  + bottomPosSquared < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_S  ] = ( bottomPosSquared                   < largeRadiusDistanceSquared );
			m_tileVisible[ TILE_SE ] = ( rightPosSquared + bottomPosSquared < largeRadiusDistanceSquared );
				
			//
			//trace("Minimap ---------------------------------------------------");
			//trace("Minimap " + (int)( m_tileVisible[ TILE_NW ] )    + (int)( m_tileVisible[ TILE_N  ] )    + (int)( m_tileVisible[ TILE_NE ] ) );
			//trace("Minimap " + (int)( m_tileVisible[ TILE_W  ] )    + (int)( m_tileVisible[ TILE_C  ] )    + (int)( m_tileVisible[ TILE_E  ] ) );
			//trace("Minimap " + (int)( m_tileVisible[ TILE_SW ] )    + (int)( m_tileVisible[ TILE_S  ] )    + (int)( m_tileVisible[ TILE_SE ] ) )
			//
			
			var currTileFilename : String;

			if ( HudModuleMinimap2.m_playerTileX != m_playerTileX ||
				 HudModuleMinimap2.m_playerTileY != m_playerTileY )
			{
				// center tile has been changed (player crossed the border between tiles or was teleported)
				m_playerTileX = HudModuleMinimap2.m_playerTileX;
				m_playerTileY = HudModuleMinimap2.m_playerTileY;

				m_tileFilenames[ TILE_NW ] = GetTileFilename( m_playerTileX - 1, m_playerTileY + 1 );
				m_tileFilenames[ TILE_N  ] = GetTileFilename( m_playerTileX,     m_playerTileY + 1 );
				m_tileFilenames[ TILE_NE ] = GetTileFilename( m_playerTileX + 1, m_playerTileY + 1 );
				m_tileFilenames[ TILE_W  ] = GetTileFilename( m_playerTileX - 1, m_playerTileY     );
				m_tileFilenames[ TILE_C  ] = GetTileFilename( m_playerTileX,     m_playerTileY     );
				m_tileFilenames[ TILE_E  ] = GetTileFilename( m_playerTileX + 1, m_playerTileY     );
				m_tileFilenames[ TILE_SW ] = GetTileFilename( m_playerTileX - 1, m_playerTileY - 1 );
				m_tileFilenames[ TILE_S  ] = GetTileFilename( m_playerTileX,     m_playerTileY - 1 );
				m_tileFilenames[ TILE_SE ] = GetTileFilename( m_playerTileX + 1, m_playerTileY - 1 );
	
				var i, j : int;
				
				// copy exising array to temp variable and create new array
				var prevTiles : Vector.< MinimapLoader > = m_tiles;
				m_tiles = new Vector.< MinimapLoader >( TILE_COUNT );
	
				// copy required tiles from prev array to current one if they exist
				var currPrevTile : MinimapLoader;
				for ( i = 0; i < TILE_COUNT; ++i )
				{
					if ( m_tileVisible[ i ] )
					{
						currTileFilename = m_tileFilenames[ i ];
						
						// find existing tile
						for ( j = 0; j < prevTiles.length; ++j )
						{
							currPrevTile = prevTiles[ j ];
							if ( currPrevTile && currPrevTile.source && currPrevTile.source == currTileFilename )
							{
								// it was found
								m_tiles[ i ] = currPrevTile;
								UpdateTilePosition( i );
								prevTiles.splice( j, 1 );
								break;
							}
						}
					}
				}
	
				// reuse previous tiles
				for ( i = 0; i < TILE_COUNT; ++i )
				{
					if ( !m_tiles[ i ] )
					{
						if ( prevTiles.length == 0 )
						{
							trace("Minimap Ouch!" );
						}
						else
						{
							m_tiles[ i ] = prevTiles[ 0 ];
							prevTiles.splice( 0, 1 );
							
							if ( m_tileVisible[ i ] )
							{
								m_tiles[ i ].source = m_tileFilenames[ i ];
								m_tiles[ i ].visible = true;
								UpdateTilePosition( i );
							}
						}
					}
				}
			}
			else
			{
				// the center tile is still the same but we need to update visibility of the others
				
				var currTile : MinimapLoader;
				var currTileSource : String;
				
				for ( i = 0; i < TILE_COUNT; ++i )
				{
					currTileFilename = m_tileFilenames[ i ];
					currTile = m_tiles[ i ];
					currTileSource = currTile.source;
					
					/*
					trace("Minimap -------------------------------------------------------------------------------------" );
					trace("Minimap " + i + " " + currTileVisible + " " + currTileFilename );
					trace("Minimap " + currTile );
					trace("Minimap " + currTileSource );
					*/
					
					if ( m_tileVisible[ i ] )
					{
						if ( !currTileSource || ( currTileSource && currTileSource != currTileFilename ) )
						{
							//trace("Minimap SHOW " + i + " " + currTile.visible + " [" + currTileFilename + "] ");
							currTile.source = currTileFilename;
							currTile.visible = true;
							UpdateTilePosition( i );
						}
					}
					else
					{
						if ( currTileSource && currTileSource.length > 0 )
						{
							//trace("Minimap HIDE " + i + " " + currTile.visible + " [" + currTile.source + "] ");
							currTile.source = "";
						}
					}
				}
			}
		}

		private function GetTileFilename( tileX : int, tileY : int ) : String
		{
			if ( tileX < 0 || tileX >= HudModuleMinimap2.m_tileCount ||
				 tileY < 0 || tileY >= HudModuleMinimap2.m_tileCount )
			{
				return "";
			}
			return "img://minimaps/" + HudModuleMinimap2.m_worldName + "/tile" + tileX + "x" + tileY + "." + HudModuleMinimap2.m_tileExteriorTextureExtension;
		}

		public function UpdateTilePosition( index : int )
		{
			if ( m_tiles[ index ] )
			{
				m_tiles[ index ].x = m_tileShiftX[ index ];
				m_tiles[ index ].y = m_tileShiftY[ index ];
			}
			/*
			trace("Minimap Positions" );
			for ( var i : int = 0; i < TILE_COUNT; ++i )
			{
				trace("Minimap " + i + " " + ((int)( m_tiles[ i ].source != null )) + " "  + m_tiles[ i ].x + " " + m_tiles[ i ].y + " " + m_tiles[ i ].width + " " + m_tiles[ i ].height );
			}
			*/
		}
		
		public function UpdateTileDebugBorders()
		{
			var tileSize : int = m_tiles.length;
			for ( var i = 0; i < tileSize; ++i )
			{
				if ( m_tiles[ i ] )
				{
					if ( HudModuleMinimap2.m_showDebugBorders )
					{
						m_tiles[ i ].filters = [new GlowFilter(0xFF0000, 1, 6, 6, 2, 1, true) ];
					}
					else
					{
						m_tiles[ i ].filters = [];
					}
				}
			}
		}
		
	}

}
