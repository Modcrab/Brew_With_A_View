package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import scaleform.clik.core.UIComponent;
	import flash.geom.Point;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.StaticMapPinData;
	import flash.utils.getDefinitionByName;
	
	public class HubMapPreview extends UIComponent
	{
		public var mcHubMapPreviewGeneralMask : MovieClip;
		public var mcHubMapPreviewGeneralContainer : MovieClip;
		public var mcHubMapPreviewFrame : MovieClip;
		
		private var _mapPinClass : Class;

		private var _mapSize : Number;
		private var _textureSize : int;
		private var _visibilityWorldMinX : int;
		private var _visibilityWorldMaxX : int;
		private var _visibilityWorldMinY : int;
		private var _visibilityWorldMaxY : int;
		private var _previewAvailable : Boolean;
		private var _previewMode : int = MODE_SMALL_MAP;
		private var _staticMapPins : Vector.< StaticMapPinPreviewDescribed > = new Vector.< StaticMapPinPreviewDescribed >();
		
		private const MAP_WIDTH_HEIGHT_RATIO : Number = 1.5;    // DO NOT modify, it is adjusted to current sizes of maps
		
		private const MODE_INVISIBLE : int = 0;
		private const MODE_SMALL_MAP : int = 1;
		private const MODE_BIG_MAP   : int = 2;
		
		private const SMALL_MAP_HEIGHT : int = 150;
		private const BIG_MAP_HEIGHT   : int = 250;
		
		private const SMALL_MAP_PIN_SCALE : Number = 1.0;
		private const BIG_MAP_PIN_SCALE : Number = ( 1.0 * BIG_MAP_HEIGHT ) / SMALL_MAP_HEIGHT;

		
		protected override function configUI():void
		{
			super.configUI();
			
			_mapPinClass = getDefinitionByName( "StaticMapPinPreviewBase" ) as Class;
		}
		
		public function setMapSettings( mapSize : Number, textureSize : int, mapPath : String, minX : int, maxX : int, minY : int, maxY : int, previewAvailable : Boolean, previewMode : int )
		{
			_mapSize = mapSize;
			_textureSize = textureSize;
			_visibilityWorldMinX = minX;
			_visibilityWorldMaxX = maxX;
			_visibilityWorldMinY = minY;
			_visibilityWorldMaxY = maxY;
			_previewAvailable = previewAvailable;
			_previewMode = previewMode;
			
			if ( CanBeToggled() )
			{
				// load map only if it is possible to toggle it
				mcHubMapPreviewGeneralContainer.mcHubMapPreviewZoomContainer.SetMapSettings( mapPath );
			}
			
			if ( _previewMode == MODE_SMALL_MAP )
			{
				rescaleMap( SMALL_MAP_HEIGHT );
			}
			else if ( _previewMode == MODE_BIG_MAP )
			{
				rescaleMap( BIG_MAP_HEIGHT );
			}
			updatePinsPositionAndScale( GetPinScaleByMode( _previewMode ) );
		}
		
		private function GetPinScaleByMode( previewMode : int )
		{
			if ( previewMode == MODE_SMALL_MAP )
			{
				return SMALL_MAP_PIN_SCALE;
			}
			else if ( previewMode == MODE_BIG_MAP )
			{
				return BIG_MAP_PIN_SCALE;
			}
			return SMALL_MAP_PIN_SCALE;
		}
		
		private function rescaleMap( previewHeight : Number )
		{
			// visibility - only if map is enabled and can be toggled
			visible = ( CanBeToggled() );

			var previewHeightCoef : Number = Math.abs( WorldYToMapY( -_visibilityWorldMinY ) - WorldYToMapY( -_visibilityWorldMaxY ) );
			
			mcHubMapPreviewGeneralContainer.mcHubMapPreviewZoomContainer.scaleX = previewHeight / previewHeightCoef;
			mcHubMapPreviewGeneralContainer.mcHubMapPreviewZoomContainer.scaleY = previewHeight / previewHeightCoef;

			var scale : Number = GetScale();

			var visibilityMapMinX : Number = WorldXToMapX( _visibilityWorldMinX ) * scale;
			var visibilityMapMaxX : Number = WorldXToMapX( _visibilityWorldMaxX ) * scale;
			var visibilityMapMinY : Number = WorldYToMapY( -_visibilityWorldMaxY ) * scale;
			var visibilityMapMaxY : Number = WorldYToMapY( -_visibilityWorldMinY ) * scale;

			mcHubMapPreviewGeneralContainer.mcHubMapPreviewTextureMask.x = ( visibilityMapMaxX + visibilityMapMinX ) / 2;
			mcHubMapPreviewGeneralContainer.mcHubMapPreviewTextureMask.y = ( visibilityMapMaxY + visibilityMapMinY ) / 2;
			mcHubMapPreviewGeneralContainer.mcHubMapPreviewTextureMask.width = Math.abs( visibilityMapMaxX - visibilityMapMinX );
			mcHubMapPreviewGeneralContainer.mcHubMapPreviewTextureMask.height = Math.abs( visibilityMapMaxY - visibilityMapMinY );

			mcHubMapPreviewGeneralContainer.mcHubMapPreviewZoomContainer.mask =  mcHubMapPreviewGeneralContainer.mcHubMapPreviewTextureMask;
			
			mcHubMapPreviewGeneralMask.x      = ( visibilityMapMaxX + visibilityMapMinX ) / 2;
			mcHubMapPreviewGeneralMask.y      = ( visibilityMapMaxY + visibilityMapMinY ) / 2;
			mcHubMapPreviewGeneralMask.width  = previewHeight * MAP_WIDTH_HEIGHT_RATIO;
			mcHubMapPreviewGeneralMask.height = Math.abs( visibilityMapMaxY - visibilityMapMinY );
			
			mcHubMapPreviewGeneralContainer.mask = mcHubMapPreviewGeneralMask;
			
			mcHubMapPreviewFrame.x      = ( visibilityMapMaxX + visibilityMapMinX ) / 2;
			mcHubMapPreviewFrame.y      = ( visibilityMapMaxY + visibilityMapMinY ) / 2;
			mcHubMapPreviewFrame.width  = previewHeight * MAP_WIDTH_HEIGHT_RATIO + 20;
			mcHubMapPreviewFrame.height = Math.abs( visibilityMapMaxY - visibilityMapMinY ) + 20;
			
			mcHubMapPreviewGeneralContainer.mcTopLine.visible    = false;
			mcHubMapPreviewGeneralContainer.mcBottomLine.visible = false;
			mcHubMapPreviewGeneralContainer.mcLeftLine.visible   = false;
			mcHubMapPreviewGeneralContainer.mcRightLine.visible  = false;
		}
		
		private var _globalAnchorPos : Point;
		public function updateAnchorPosition( globalAnchorPos : Point )
		{
			_globalAnchorPos = globalAnchorPos;
			updateMapPosition();
		}

		public function updateMapPosition()
		{
			var globalPreviewRightBottomPos : Point = mcHubMapPreviewFrame.getBounds( stage ).bottomRight;
			x += _globalAnchorPos.x - globalPreviewRightBottomPos.x;
			y += _globalAnchorPos.y - globalPreviewRightBottomPos.y;
		}
		
		private function GetScale() : Number
		{
			return mcHubMapPreviewGeneralContainer.mcHubMapPreviewZoomContainer.actualScaleX;
		}
		
		private function MapXToWorldX( mapX : Number ) : Number
		{
			var scale : Number = _textureSize / _mapSize;
			return mapX / scale;
		}

		private function MapYToWorldY( mapY : Number ) : Number
		{
			var scale : Number = _textureSize / _mapSize;
			return -mapY / scale;
		}
		
		private function WorldXToMapX( worldX : Number ) : Number
		{
			var scale : Number = _textureSize / _mapSize;
			return worldX * scale;
		}

		private function WorldYToMapY( worldY : Number ) : Number
		{
			var scale : Number = _textureSize / _mapSize;
			return -worldY * scale;
		}

		private var _worldLeftBottom : Point;
		private var _worldRightTop : Point;
		
		public function updateVisibleFramePosition( worldLeftBottom : Point, worldRightTop : Point )
		{
			if ( worldLeftBottom == null || worldRightTop == null )
			{
				worldLeftBottom = _worldLeftBottom;
				worldRightTop   = _worldRightTop;
			}
			else
			{
				_worldLeftBottom = worldLeftBottom;
				_worldRightTop   = worldRightTop;
			}
			
			var scale : Number = GetScale();

			var mapLeftBottom : Point  = new Point( WorldXToMapX( worldLeftBottom.x ) * scale, WorldYToMapY( worldLeftBottom.y ) * scale );
			var mapRightTop : Point    = new Point( WorldXToMapX( worldRightTop.x )   * scale, WorldYToMapY( worldRightTop.y )   * scale );
			var mapLeftTop : Point     = new Point( WorldXToMapX( worldLeftBottom.x ) * scale, WorldYToMapY( worldRightTop.y )   * scale );
			var mapRightBottom : Point = new Point( WorldXToMapX( worldRightTop.x )   * scale, WorldYToMapY( worldLeftBottom.y ) * scale );

			mcHubMapPreviewGeneralContainer.mcTopLine.x          = ( mapLeftTop.x + mapRightTop.x ) / 2;
			mcHubMapPreviewGeneralContainer.mcTopLine.y          = mapLeftTop.y;
			mcHubMapPreviewGeneralContainer.mcTopLine.scaleX     = mapRightTop.x - mapLeftTop.x;
			mcHubMapPreviewGeneralContainer.mcTopLine.visible    = true;
			
			mcHubMapPreviewGeneralContainer.mcBottomLine.x       = ( mapLeftBottom.x + mapRightBottom.x ) / 2;
			mcHubMapPreviewGeneralContainer.mcBottomLine.y       = mapLeftBottom.y;
			mcHubMapPreviewGeneralContainer.mcBottomLine.scaleX  = mapRightBottom.x - mapLeftBottom.x;
			mcHubMapPreviewGeneralContainer.mcBottomLine.visible = true;

			mcHubMapPreviewGeneralContainer.mcLeftLine.x         = mapLeftTop.x;
			mcHubMapPreviewGeneralContainer.mcLeftLine.y         = ( mapLeftTop.y + mapLeftBottom.y ) / 2;
			mcHubMapPreviewGeneralContainer.mcLeftLine.scaleY    = mapLeftTop.y - mapLeftBottom.y;
			mcHubMapPreviewGeneralContainer.mcLeftLine.visible   = true;

			mcHubMapPreviewGeneralContainer.mcRightLine.x        = mapRightTop.x;
			mcHubMapPreviewGeneralContainer.mcRightLine.y        = ( mapRightTop.y + mapRightBottom.y ) / 2;
			mcHubMapPreviewGeneralContainer.mcRightLine.scaleY   = mapRightTop.y - mapRightBottom.y;
			mcHubMapPreviewGeneralContainer.mcRightLine.visible  = true;
		}
		
		public function updateMapPinHighlighting()
		{
			var i : int;
			var pin : StaticMapPinPreviewDescribed;
			
			for ( i = 0; i < _staticMapPins.length; ++i )
			{
				pin = _staticMapPins[ i ] as StaticMapPinPreviewDescribed;
				if ( pin && pin.data.isQuest )
				{
					pin.mcHighlight.visible = pin.data.highlighted;
				}
			}
		}
		
		public function CanBeToggled() : Boolean
		{
			return _previewAvailable;
		}

		public function Toggle()
		{
			if ( _previewMode == MODE_SMALL_MAP )
			{
				_previewMode = MODE_BIG_MAP;
				rescaleMap( BIG_MAP_HEIGHT );
			}
			else if ( _previewMode == MODE_BIG_MAP )
			{
				_previewMode = MODE_SMALL_MAP;
				rescaleMap( SMALL_MAP_HEIGHT );
				
			}

			updateMapPosition();
			updatePinsPositionAndScale( GetPinScaleByMode( _previewMode ) );
			updateVisibleFramePosition( null, null );
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnToggleMinimap', [ _previewMode ] ) );
		}
		
		private var _lmbDown : Boolean = false;
		public function SetLMBDown( lmbDown : Boolean )
		{
			_lmbDown = lmbDown;
		}

		public function IsLMBDown()
		{
			return _lmbDown;
		}
		
		public function GetWorldMapHitPoint( globalMousePos : Point ) : Point
		{
			var localPos : Point = mcHubMapPreviewGeneralContainer.globalToLocal( globalMousePos );
			var scale : Number = GetScale();
			
			//mcHubMapPreviewGeneralContainer.mcTarget.x = localPos.x;
			//mcHubMapPreviewGeneralContainer.mcTarget.y = localPos.y;
			
			var worldPos : Point = new Point( MapXToWorldX( localPos.x / scale ), MapYToWorldY( localPos.y / scale ) );
			
			return worldPos;
		}
		
		public function addPin( data : StaticMapPinData )
		{
			var mapPin : StaticMapPinPreviewDescribed;
			
			if ( data.isPlayer )
			{
				mapPin = new _mapPinClass();
				mapPin.data = data;
				mapPin.gotoAndStop( 'Player' );
				mapPin.rotation = data.rotation;
				mapPin.isPlayer = true;
				mapPin.mcHighlight.visible = false;
			}
			else if ( data.isQuest )
			{
				mapPin = new _mapPinClass();
				mapPin.data = data;
				mapPin.gotoAndStop( 'Quest' );
				mapPin.mcHighlight.visible = data.highlighted;
			}
			else if ( data.isUserPin )
			{
				mapPin = new _mapPinClass();
				mapPin.data = data;
				mapPin.gotoAndStop( data.type );
				mapPin.mcHighlight.visible = false;
			}
			else
			{
				return;
			}
			
			var scale : Number = GetScale();
			var pinScale : Number = GetPinScaleByMode( _previewMode );

			mapPin.id = data.id;
			mapPin.worldX = data.posX;
			mapPin.worldY = data.posY;

			mapPin.x = WorldXToMapX( data.posX ) * scale;
			mapPin.y = WorldYToMapY( data.posY ) * scale;
			
			var scaleCoef : Number = 1;
			if ( mapPin.isPlayer )
			{
				scaleCoef = 0.5;
			}

			mapPin.scaleX = pinScale * scaleCoef;
			mapPin.scaleY = pinScale * scaleCoef;

			_staticMapPins[ _staticMapPins.length ] = mapPin;

			mcHubMapPreviewGeneralContainer.mcHubMapPreviewPinContainer.addChild( mapPin );
		}
		
		public function removePin( id : uint )
		{
			for ( var i : int = _staticMapPins.length - 1; i >= 0; i-- )
			{
				if ( _staticMapPins[ i ].id == id )
				{
					mcHubMapPreviewGeneralContainer.mcHubMapPreviewPinContainer.removeChild( _staticMapPins[ i ] );
					_staticMapPins.splice( i, 1 );
					return;
				}
			}
		}
		
		public function clearPins()
		{
			for ( var i : int = _staticMapPins.length - 1; i >= 0; i-- )
			{
				mcHubMapPreviewGeneralContainer.mcHubMapPreviewPinContainer.removeChild( _staticMapPins[ i ] );
			}
			_staticMapPins.length = 0;
		}
		
		public function updatePinsPositionAndScale( pinScale : Number )
		{
			var scale : Number = GetScale();
			
			for ( var i : int = _staticMapPins.length - 1; i >= 0; i-- )
			{
				_staticMapPins[ i ].x = WorldXToMapX( _staticMapPins[ i ].worldX ) * scale;
				_staticMapPins[ i ].y = WorldYToMapY( _staticMapPins[ i ].worldY ) * scale;
				
				var scaleCoef : Number = 1;
				if ( _staticMapPins[ i ].isPlayer )
				{
					scaleCoef = 0.5;
				}
				_staticMapPins[ i ].scaleX = pinScale * scaleCoef;
				_staticMapPins[ i ].scaleY = pinScale * scaleCoef;
			}
		}

	}
	
}
