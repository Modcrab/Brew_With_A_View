package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import red.game.witcher3.hud.modules.minimap2.MapPin;
	import red.game.witcher3.hud.modules.minimap2.Waypoint;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;

	public class CommonMap extends BaseMap
	{
		public var mcCommonMapContainer : CommonMapContainer;

		private var _centerMovieClip	: MovieClip;
		private var _highlightedMapPin	: MapPin;
		private var _mapPins			: Dictionary = new Dictionary();
		private var _mapPaths			: Dictionary = new Dictionary();
		private var _waypoints			: Vector.< Waypoint > = new Vector.< Waypoint >();
		private var _realWaypointsCount : int = 0;
		private var _mapPinPool			: Vector.< MapPin > = new Vector.< MapPin >();

		private static const PIN_LOWEST_PRIORITY = 0;
		private static const PIN_NORMAL_PRIORITY = 1;
		private static const PIN_HIGHEST_PRIORITY = 2;
		
		private static const WAYPOINT_PRIORITY = PIN_LOWEST_PRIORITY;
		
		private var refWaypoint : Class;
		private var refPin : Class;
		private var refArr : Class;
		
		
		public function Initialize( centerMovieClip : MovieClip )
		{
			refWaypoint = getDefinitionByName( 'WaypointInstance' ) as Class;
			refPin = getDefinitionByName( 'MapPinInstance' ) as Class;
			refArr = getDefinitionByName( 'QuestDirectionCurrentMain' ) as Class;
			
			_centerMovieClip = centerMovieClip;
			AddMapPinsToPool( 50 );
		}

		private function AddMapPinsToPool( count : int )
		{
			var mapPin : MapPin;

			for ( var i = 0; i < count; ++i )
			{
				mapPin = new MapPin();
				mapPin.pinClip = new refPin();
				mapPin.arrowClip = new refArr();
				
				mapPin.arrowClip.x = _centerMovieClip.x;
				mapPin.arrowClip.y = _centerMovieClip.y;
				mapPin.arrowClip.rotationZ = -90;

				_mapPinPool.push( mapPin );
			}
		}
		
		private function GetMapPinFromPool() : MapPin
		{
			if ( _mapPinPool.length == 0 )
			{
				// initial number of pins was not enough?
				AddMapPinsToPool( 1 );
			}
			return _mapPinPool.pop();
		}
		
		private function PutMapPinToPool( mapPin : MapPin )
		{
			return _mapPinPool.push( mapPin );
		}
		
		override public function SetRotation( angle : Number )
		{
			rotation = angle;

			UpdateMapPinsRotation();
		}

		override public function SetScale( value : Number )
		{
			var coef : Number = HudModuleMinimap2.GetCoef( false );
			var finalScale = ZOOM_COEF * coef * value;

			scaleX = finalScale;
			scaleY = finalScale;

			UpdateMapPinsScale();
		}

		public function GetMapPinRotation() : Number
		{
			return -rotation;
		}

		public function GetMapPinScale() : Number
		{
			return 1.0 / actualScaleX;
		}

		public function GetAreaMapPinScale() : Number
		{
			return actualScaleX;
		}

		public function UpdateMapPinsAppearance( radiusSquared : Number )
		{
			for each ( var mapPin : MapPin in _mapPins )
			{
				mapPin.UpdateMapPinAppearance( radiusSquared );
			}
			
			// not required, called once when creating
			/*
			var size = _waypoints.length;
			var waypoint : MapPin;
			for ( var i : int = 0; i < size; ++i )
			{
				waypoint = _waypoints[ i ] as MapPin;
				waypoint.UpdateMapPinAppearance( radiusSquared );
			}
			*/
		}

		public function UpdateMapPinsRotation()
		{
			var rot : Number = GetMapPinRotation();

			for each ( var mapPin : MapPin in _mapPins )
			{
				mapPin.SetPinRotation( rot );
			}

			// not really necessary as long as they are cirlces
			/*
			var size = _waypoints.length;
			var waypoint : MapPin;
			for ( var i : int = 0; i < size; ++i )
			{
				waypoint = _waypoints[ i ] as MapPin;
				waypoint.SetPinRotation( rot );
			}
			*/
		}

		public function UpdateMapPinsScale()
		{
			var sc : Number = GetMapPinScale();

			for each ( var mapPin : MapPin in _mapPins )
			{
				mapPin.SetIconScale( sc );
			}
			
			var size = _waypoints.length;
			var waypoint : Waypoint;
			for ( var i : int = 0; i < size; ++i )
			{
				waypoint = _waypoints[ i ] as Waypoint;
				waypoint.SetScale( sc );
			}
		}
		
		public function UpdateMapPinArrowRotations( rotDelta : Number )
		{
			for each ( var mapPin : MapPin in _mapPins )
			{
				mapPin.UpdateMapPinArrowRotation( rotDelta );
			}
		}

		public function AddWaypoint( mapX : Number, mapY : Number )
		{
			var waypoint : Waypoint;
			if ( _realWaypointsCount < _waypoints.length )
			{
				waypoint = _waypoints[ _realWaypointsCount ];
			}
			else
			{
				waypoint = new Waypoint();
				waypoint.pinClip = new refWaypoint();
				waypoint.SetScale( GetMapPinScale() );
				waypoint.ForceShow( true );

				// addchild only once
				mcCommonMapContainer.addChildPin( WAYPOINT_PRIORITY, waypoint.pinClip );

				_waypoints.push( waypoint );
				
				//
				//trace("Minimap waypoints " + _waypoints.length );
				//
			}
			_realWaypointsCount++;

			waypoint.Show( true );

			waypoint.SetPosition( mapX, mapY );
		}

		public function ClearWaypoints( startingFrom : int )
		{
			var waypoint : Waypoint;
			var size : int = _waypoints.length;
			for ( var i : int = startingFrom; i < size; ++i )
			{
				_waypoints[ i ].Show( false );
				
				// never remove child
				//mcCommonMapContainer.removeChildPin( WAYPOINT_PRIORITY, waypoint.pinClip );
			}
			_realWaypointsCount = 0;
		}

		public function AddMapPin( id : int, tag : String, type : String, radius : Number, canBePointedByArrow : Boolean, priority : int, isQuestPin : Boolean, isUserPin : Boolean, isHighlighted : Boolean )
		{
			var mapPin : MapPin;
			
			mapPin = _mapPins[ id ];
			if ( mapPin )
			{
				//trace("Minimap ################################# HudModuleMinimap::AddMapPin: Possible map pin id collision? " + id );
				return;
			}

			mapPin = GetMapPinFromPool();

			mapPin.OnInitialize( type );
			//
			//trace("Minimap GetMapPinFromPool " + _mapPinPool.length );
			//

			mapPin.id		= id;
			mapPin.tag		= tag;
			mapPin.type		= type;
			mapPin.radius	= radius;
			mapPin.highlighted = isHighlighted;
			mapPin.canBePointedByArrow = canBePointedByArrow; 
			mapPin.canHeightArrowsBeShown = ( radius == 0 ) && !isUserPin;
			mapPin.priority = priority;
			mapPin.isQuestPin = isQuestPin;
			mapPin.isUserPin = isUserPin;

			mcCommonMapContainer.addChildPin( mapPin.priority, mapPin.pinClip );
			parent.addChild( mapPin.arrowClip );

			mapPin.SetPinRotation( GetMapPinRotation() );

			mapPin.SetIconScale( GetMapPinScale() );
			mapPin.SetRadiusScale( radius, 1.0 / HudModuleMinimap2.GetCoef( false ) );

			mapPin.ShowPin( true );
			mapPin.ShowPinIcon( !mapPin.isQuestPin || mapPin.radius == 0 );
			mapPin.ShowPinRadius( mapPin.radius != 0 );
			mapPin.ShowArrow( false );
			mapPin.ForceShowHeightArrows( false, false, true );
			mapPin.ShowNewFeedback( type == "Enemy" || type == "EnemyDead" );
			
			mapPin.UpdatePinRadiusColor();
			mapPin.UpdateHeightArrowsForQuestPins();

			HighlightMapPinInstance( mapPin, isHighlighted );

			_mapPins[ id ] = mapPin;
		}

		public function MoveMapPin( id : int, posX, posY, posZ : Number )
		{
			var mapPin : MapPin;
			
			mapPin = _mapPins[ id ];
			if ( !mapPin )
			{
				//trace("Minimap ################################# HudModuleMinimap::MoveMapPin: Lookup failed on map pin id: " + id );
				return;
			}
			
			
			var updateZpos:Boolean = mapPin.posZ != posZ;
			if (mapPin.posX != posX || mapPin.posY != posY || updateZpos)
			{
				mapPin.posX = posX;
				mapPin.posY = posY;
				mapPin.posZ = posZ;			
			
				mapPin.UpdateMapPinPosition(  HudModuleMinimap2.WorldToMapX( mapPin.posX ),
											  HudModuleMinimap2.WorldToMapY( mapPin.posY ) );
				mapPin.UpdateMapPinAppearance( HudModuleMinimap2.m_radiusSquared, updateZpos );
			}
		}

		public function DeleteMapPin( id : int )
		{
			var mapPin : MapPin;
			
			mapPin = _mapPins[ id ];
			if ( !mapPin )
			{
				trace("Minimap ################################# HudModuleMinimap::DeleteMapPin: Lookup failed on map pin id: " + id );
				return;
			}

			mcCommonMapContainer.removeChildPin( mapPin.priority, mapPin.pinClip );
			parent.removeChild( mapPin.arrowClip );

			mapPin.ShowPin( false );
			mapPin.ShowArrow( false );
		
			mapPin.OnDeinitialize();
			PutMapPinToPool( mapPin );
			
			//
			//trace("Minimap GetMapPinFromPool " + _mapPinPool.length );
			//
			
			if ( _highlightedMapPin == mapPin )
			{
				_highlightedMapPin = null;
			}
			
			_mapPins[ id ] = null;
			delete _mapPins[ id ];
		}

		public function DeleteMapPins( dataArray : Array )
		{
			var size : int = dataArray.length;
			for ( var i : int = 0; i < size; ++i )
			{
				DeleteMapPin( dataArray[ i ].id );
			}
		}

		public function HighlightMapPin( id : int, highlighted : Boolean )
		{
			var mapPin : MapPin;
			
			mapPin = _mapPins[ id ];
			if ( !mapPin )
			{
				trace("Minimap ################################# HudModuleMinimap::HighlightMapPin: Lookup failed on map pin id: " + id );
				return;
			}
			
			HighlightMapPinInstance( mapPin, highlighted );
		}

		public function HighlightMapPinInstance( mapPin : MapPin, highlighted : Boolean )
		{
			mapPin.highlighted = highlighted;
			
			if ( highlighted )
			{
				_highlightedMapPin = mapPin;
			}
			else
			{
				if ( _highlightedMapPin == mapPin )
				{
					_highlightedMapPin = null;
				}
			}

			if ( highlighted )
			{
				// addChild to put highlighted map pin on top
				parent.addChild( mapPin.arrowClip );
			}
			
			mapPin.UpdateHighlighting();
		}

		public function GetHighlightedMapPinPosZ() : Number
		{
			if ( _highlightedMapPin )
			{
				return _highlightedMapPin.posZ;
			}
			return 0;
		}

		public function AddPath( gameData : Object )
		{
			var id : int		= gameData.id;
			var mapPath : MapPath;

			mapPath = _mapPaths[ id ];
			if ( mapPath )
			{
				trace("Minimap ################################# HudModuleMinimap::AddPath: Possible map path id collision? " + id );
				return;
			}

			mapPath = new MapPath();

			mapPath.x = 0;
			mapPath.y = 0;
			mapPath.visible = true;

			/*
			var controlPointArray	: Array		= gameData.controlPoints;
			if ( controlPointArray )
			{
				for ( var i = 0; i < controlPointArray.length; ++i )
				{
					mapPath.AddControlPoint( controlPointArray[ i ].x, controlPointArray[ i ].y );
				}
			}
			*/

			var splinePointArray	: Array		= gameData.splinePoints;
			if ( splinePointArray )
			{
				var size : int = splinePointArray.length;
				for ( var i = 0; i < size; ++i )
				{
					mapPath.AddSplinePoint(	splinePointArray[ i ].x, splinePointArray[ i ].y );
				}
			}

			mapPath.SetupCurve( gameData.x, gameData.y, gameData.color, gameData.lineWidth );

			mcCommonMapContainer.addChildPin( PIN_LOWEST_PRIORITY, mapPath );

			_mapPaths[ id ] = mapPath;
		}

		public function DeletePaths( dataArray : Array )
		{
			var id : int;
			var mapPath : MapPath;
			
			var size : int = dataArray.length;
			for ( var i : int = 0; i < size; ++i )
			{
				id = dataArray[ i ].id;
				
				mapPath = _mapPaths[ id ];
				if ( !mapPath )
				{
					trace("Minimap ################################# HudModuleMinimap::DeletePaths: Lookup failed on map path id: " + id );
					continue;
				}

				mcCommonMapContainer.removeChildPin( PIN_LOWEST_PRIORITY, mapPath );
				delete _mapPaths[ id ];
			}
		}
	}

}
