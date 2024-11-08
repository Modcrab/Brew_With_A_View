package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.minimap2.DistanceInfo;
	import red.game.witcher3.hud.modules.minimap2.WorldConditionInfo;
	import red.game.witcher3.hud.modules.minimap2.BuffedMonsterInfo;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;

	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	import flash.geom.Vector3D;
	import flash.geom.Point

	import scaleform.gfx.Extensions;
	import flash.external.ExternalInterface;

	import flash.events.Event;
	import fl.transitions.easing.Strong;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.constants.InvalidationType;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.motion.TweenEx;
	import red.game.witcher3.hud.modules.minimap2.MapPin;
	import red.game.witcher3.hud.modules.minimap2.CommonMap;
	import red.game.witcher3.hud.modules.minimap2.HubMap;
	import red.game.witcher3.hud.modules.minimap2.InteriorMap;
	import red.game.witcher3.hud.modules.minimap2.WorldConditionInfo;
	import red.game.witcher3.hud.modules.minimap2.BuffedMonsterInfo;
	import red.game.witcher3.utils.CommonUtils;
	import flash.text.TextField;

	public class HudModuleMinimap2 extends HudModuleBase
	{
		public static const HEIGHT_THRESHOLD		: Number = 4;
		public static const DEFAULT_RADIUS			: Number = 33;	// 33 meters is radius for zoom = 1

		public var mcCommonMap				: CommonMap;
		public var mcHubMap					: HubMap;
		public var mcInteriorMap			: InteriorMap;
		public var mcCommonMapMask			: MovieClip;
		public var mcHubMapMask				: MovieClip;
		public var mcInteriorMapMask		: MovieClip;

		public var mcPlayerMarker			: MovieClip;
		public var mcPlayerCamera			: MovieClip;
		public var mcNorthSign				: MovieClip;

		public var mcWorldCondition 		: WorldConditionInfo;
		//public var mcBuffedMonster  		: BuffedMonsterInfo;
		public var mcDistanceQuest			: DistanceInfo;
		public var mcDistanceUser			: DistanceInfo;
		public var mcShading				: MovieClip;

		public static var m_worldName				: String	= "";
		public static var m_worldSize				: Number	= 0;
		public static var m_tileCount				: int		= 0;
		public static var m_tileSize				: Number	= 0;
		public static var m_tileExteriorTextureSize	: Number	= 0;
		public static var m_tileInteriorTextureSize	: Number	= 0;
		public static var m_tileExteriorTextureExtension : String = "jpg"; //"png";
		public static var m_tileInteriorTextureExtension : String = "png";

		public static var m_zoom			: Number = 1;
		public static var m_radius			: Number = DEFAULT_RADIUS / m_zoom;
		public static var m_radiusSquared	: Number = m_radius * m_radius;

		public static var m_isInterior		: Boolean = false;
		public static var m_isDebug			: Boolean = false;
		public static var m_showDebugBorders: Boolean = false;
		public static var m_playerWorldPosX	: Number = 1000000;
		public static var m_playerWorldPosY	: Number = 1000000;
		public static var m_playerWorldPosZ	: Number = 1000000;
		public static var m_playerTileX			: int = -1;
		public static var m_playerTileY			: int = -1;
		public static var m_playerTilePosX		: Number;
		public static var m_playerTilePosY		: Number;
		public static var m_playerTexturePosX	: Number;
		public static var m_playerTexturePosY	: Number;
		public static var m_cameraAngle		: Number = NaN;
		public static var m_rotationEnabled	: Boolean = false;
		
		private static var m_exteriorCoef : Number;
		private static var m_interiorCoef : Number;

		public function HudModuleMinimap2()
		{
			super();
			visible = false;
			EnableMask( true );
		}

		override public function get moduleName():String
		{
			return "Minimap2Module";
		}

		override protected function configUI():void
		{
			super.configUI();
			
			alpha = 0.01;

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );

			mcCommonMapMask.visible		= false;
			mcHubMapMask.visible		= false;
			mcInteriorMapMask.visible	= false;

			mcDistanceQuest.visible	= false;
			mcDistanceQuest.mcIcon.gotoAndStop( 'Quest' );
			mcDistanceUser.visible	= false;
			mcDistanceUser.mcIcon.gotoAndStop( 'User1' );

			// this needs to be after sending game event OnConfigUI
			mcCommonMap.Initialize( mcPlayerMarker );

			UpdateVisibility();

			registerDataBinding( 'hud.minimap.paths.add',			handleAddPath );
			registerDataBinding( 'hud.minimap.paths.delete',		handleDeletePaths );
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// Witcherscript (functions)
		//
		
		public function /* WitcherScript */ SetMapSettings( worldName : String, worldSize : Number, exteriorTextureSize : int, interiorTextureSize : int, tileCount : int )
		{
			//
			//trace("Minimap SetMapSettings " + worldName + " " + worldSize + " " + tileCount + " " + exteriorTextureSize + " " + interiorTextureSize );
			//

			m_worldName					= worldName;
			m_worldSize					= worldSize;
			m_tileCount					= tileCount;
			m_tileSize					= m_worldSize / m_tileCount;
			m_tileExteriorTextureSize	= exteriorTextureSize;
			m_tileInteriorTextureSize	= interiorTextureSize;
			
			m_exteriorCoef = m_tileSize / m_tileExteriorTextureSize;
			m_interiorCoef = m_tileSize / m_tileInteriorTextureSize;
			
			mcHubMap.mcHubMapContainer.InitializeTilePositions();
		}

		public function /* WitcherScript */ SetTextureExtensions( exteriorTextureExtension : String, interiorTextureExtension : String )
		{
			m_tileExteriorTextureExtension = CommonUtils.strTrim( exteriorTextureExtension );
			m_tileInteriorTextureExtension = CommonUtils.strTrim( interiorTextureExtension );
		}

		public function /* WitcherScript */ SetZoom( zoomValue : Number, immediately : Boolean )
		{
			m_zoom 			= zoomValue;
			m_radius		= DEFAULT_RADIUS / m_zoom;
			m_radiusSquared = m_radius * m_radius;
			
			if ( immediately )
			{
				mcCommonMap.SetScale( zoomValue );
				mcHubMap.SetScale( zoomValue );
				mcInteriorMap.SetScale( zoomValue );
			}
			else
			{
				//tween instead of it
				mcCommonMap.SetScale( zoomValue );
				mcHubMap.SetScale( zoomValue );
				mcInteriorMap.SetScale( zoomValue );
			}
		}

		private var _lastGeneralRotation : Number = NaN;
		private var _lastPlayerMarkerRotation : Number = NaN;
		private var _lastPlayerCameraRotation : Number = NaN;

		public function /* WitcherScript */ SetPlayerRotation( cameraAngle : Number, playerAngle : Number )
		{
			var rotDelta = cameraAngle - m_cameraAngle;

			m_cameraAngle		= cameraAngle;

			if ( m_rotationEnabled )
			{
				if ( _lastGeneralRotation != m_cameraAngle )
				{
					_lastGeneralRotation = m_cameraAngle
					
					mcCommonMap.SetRotation( _lastGeneralRotation );
					mcHubMap.rotation       = _lastGeneralRotation;
					mcInteriorMap.rotation  = _lastGeneralRotation;
					mcNorthSign.rotation	= _lastGeneralRotation;
				}
				
				if ( _lastPlayerMarkerRotation != -playerAngle + m_cameraAngle )
				{
					_lastPlayerMarkerRotation = -playerAngle + m_cameraAngle
					mcPlayerMarker.rotation	= _lastPlayerMarkerRotation;
				}
				
				if ( _lastPlayerCameraRotation != 0 )
				{
					_lastPlayerCameraRotation = 0;
					mcPlayerCamera.rotation	= _lastPlayerCameraRotation;
				}
				
				mcCommonMap.UpdateMapPinArrowRotations( rotDelta );
			}
			else
			{
				if ( _lastGeneralRotation != 0 )
				{
					_lastGeneralRotation = 0;
					
					mcCommonMap.SetRotation( _lastGeneralRotation );
					mcHubMap.rotation       = _lastGeneralRotation;
					mcInteriorMap.rotation  = _lastGeneralRotation;
					mcNorthSign.rotation	= _lastGeneralRotation;
				}
				
				if ( _lastPlayerMarkerRotation != -playerAngle )
				{
					_lastPlayerMarkerRotation = -playerAngle;
					
					mcPlayerMarker.rotation	= _lastPlayerMarkerRotation;
				}
				
				if ( _lastPlayerCameraRotation != -m_cameraAngle )
				{
					_lastPlayerCameraRotation = -m_cameraAngle;
					mcPlayerCamera.rotation	= _lastPlayerCameraRotation;
				}
			}
		}
		
		public function /* WitcherScript */ SetPlayerPosition( worldPosX : Number, worldPosY : Number, worldPosZ : Number, updateMapPins : Boolean )
		{
			var moveThreshold : Number = 0.2 / m_zoom;
			if ( Math.abs( m_playerWorldPosX - worldPosX ) > moveThreshold || Math.abs( m_playerWorldPosY - worldPosY ) > moveThreshold )
			{
				// ignore small delta
				//trace("Minimap1 POSITION ", m_playerWorldPosX, m_playerWorldPosY + "          " + moveThreshold + "       " + Math.abs( m_playerWorldPosX - worldPosX ) + " " + Math.abs( m_playerWorldPosY - worldPosY ) );

				m_playerWorldPosX	= worldPosX;
				m_playerWorldPosY	= worldPosY;
				m_playerWorldPosZ	= worldPosZ;

				UpdatePosition();

				mcHubMap.mcHubMapContainer.UpdatePosition( m_radius, m_playerTexturePosX, m_playerTexturePosY );
				mcCommonMap.mcCommonMapContainer.UpdatePosition();
				mcInteriorMap.mcInteriorMapContainer.UpdatePosition();
			}

			if ( updateMapPins )
			{
				mcCommonMap.UpdateMapPinsAppearance( m_radiusSquared );
			}
		}
		
		public function /* WitcherScript */ SetPlayerPositionAndRotation( worldPosX : Number, worldPosY : Number, worldPosZ : Number, updateMapPins : Boolean, cameraAngle : Number, playerAngle : Number )
		{
			SetPlayerPosition( worldPosX, worldPosY, worldPosZ, updateMapPins );
			SetPlayerRotation( cameraAngle, playerAngle )
		}

		public function /* WitcherScript */ NotifyPlayerEnteredInterior( areaPosX : Number, areaPosY : Number, areaYaw : Number, texture : String ) : void
		{
			m_isInterior = true;

			mcInteriorMap.mcInteriorMapContainer.NotifyPlayerEnteredInterior( areaPosX, areaPosY, areaYaw, texture );
			mcCommonMap.UpdateMapPinsAppearance( m_radiusSquared );

			UpdateVisibility();
		}

		public function /* WitcherScript */ NotifyPlayerExitedInterior() : void
		{
			m_isInterior = false;

			mcInteriorMap.mcInteriorMapContainer.NotifyPlayerExitedInterior();
			mcCommonMap.UpdateMapPinsAppearance( m_radiusSquared );

			UpdateVisibility();
		}
		
		public function /* WitcherScript */ DoFading( fadeOut : Boolean, immediately : Boolean )
		{
			if ( fadeOut )
			{
				if ( immediately )
				{
					mcShading.gotoAndPlay("FadedOut");
				}
				else
				{
					mcShading.gotoAndPlay("FadingOut");
				}
			}
			else
			{
				if ( immediately )
				{
					mcShading.gotoAndPlay("FadedIn");
				}
				else
				{
					mcShading.gotoAndPlay("FadingIn");
				}
			}
		}

		public function /* WitcherScript */ EnableRotation( enable : Boolean )
		{
			m_rotationEnabled = enable;
		}

		public function /* WitcherScript */ EnableMask( enable : Boolean )
		{
			if ( enable )
			{
				mcCommonMap.mask	= mcCommonMapMask;
				mcHubMap.mask		= mcHubMapMask;
				mcInteriorMap.mask	= mcInteriorMapMask;
			}
			else
			{
				mcCommonMap.mask	= null;
				mcHubMap.mask		= null;
				mcInteriorMap.mask	= null;
			}
		}

		public function /* WitcherScript */ EnableDebug( enable : Boolean )
		{
			m_isDebug = enable;
			UpdateVisibility();
		}

		public function /* WitcherScript */ EnableBorders( enable : Boolean )
		{
			m_showDebugBorders = enable;
			UpdateDebugBorders();
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// Witcherscript (keys)
		//

		protected function handleAddPath( gameData : Object, index : int )
		{
			if ( index > 0 )
			{
				// erm...
			}
			else if ( gameData )
			{
				mcCommonMap.AddPath( gameData );
			}
		}

		protected function handleDeletePaths( gameData : Object, index : int )
		{
			if ( index > 0 )
			{
				// erm...
			}
			else if ( gameData )
			{
				mcCommonMap.DeletePaths( gameData as Array );
			}
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// C++
		//

		public function /* C++ */ AddMapPin( id : int, tag : String, type : String, radius : Number, canBePointedByArrow : Boolean, priority : int, isQuestPin : Boolean, isUserPin : Boolean, isHighlighted : Boolean )
		{
			mcCommonMap.AddMapPin( id, tag, type, radius, canBePointedByArrow, priority, isQuestPin, isUserPin, isHighlighted );
		}

		public function /* C++ */ MoveMapPin( id : int, posX, posY, posZ : Number )
		{
			mcCommonMap.MoveMapPin( id, posX, posY, posZ );
		}

		public function /* C++ */ DeleteMapPin( id : int )
		{
			mcCommonMap.DeleteMapPin( id );
		}

		public function /* C++ */ HighlightMapPin( id : int, highlighted : Boolean )
		{
			mcCommonMap.HighlightMapPin( id, highlighted );
		}

		public function /* C++ */ UpdateDistanceToHighlightedMapPin( questDistance : Number, userDistance : Number )
		{
			if ( mcDistanceQuest )
			{
				mcDistanceQuest.Update( questDistance, mcCommonMap.GetHighlightedMapPinPosZ(), m_playerWorldPosZ, HEIGHT_THRESHOLD );
			}
			if ( mcDistanceUser )
			{
				mcDistanceUser.Update( userDistance, m_playerWorldPosZ, m_playerWorldPosZ, HEIGHT_THRESHOLD );
			}
		}
		
		public function /* C++ */ AddWaypoint( posX : Number, posY : Number )
		{
			mcCommonMap.AddWaypoint(  WorldToMapX( posX ), WorldToMapY( posY ) ); 
		}

		public function /* C++ */ ClearWaypoints( startingFrom : int )
		{
			mcCommonMap.ClearWaypoints( startingFrom );
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// other
		//
		
		public function UpdateVisibility()
		{
			if ( m_isDebug )
			{
				mcHubMap.visible		= true;
				mcInteriorMap.visible	= true;
				mcInteriorMap.mcInteriorBackground.visible = false;
			}
			else
			{
				mcHubMap.visible		= !m_isInterior;
				mcInteriorMap.visible	= m_isInterior;
				mcInteriorMap.mcInteriorBackground.visible = true;
			}
		}
		
		public function UpdateDebugBorders()
		{
			mcHubMap.mcHubMapContainer.UpdateTileDebugBorders();
		}

		public function UpdatePosition()
		{
			var absolutePlayerWorldPosX : Number = ( m_playerWorldPosX + m_worldSize / 2.0 );
			var absolutePlayerWorldPosY : Number = ( m_playerWorldPosY + m_worldSize / 2.0 );
			
			m_playerTileX = absolutePlayerWorldPosX / m_tileSize;
			m_playerTileY = absolutePlayerWorldPosY / m_tileSize;
			
			m_playerTilePosX = ( ( m_playerTileX * m_tileSize ) - absolutePlayerWorldPosX );
			m_playerTilePosY = ( ( m_playerTileY * m_tileSize ) - absolutePlayerWorldPosY );
			
			m_playerTexturePosX = WorldToMapX( m_playerTilePosX );
			m_playerTexturePosY = WorldToMapY( m_playerTilePosY );
		}
		
		public static function GetCurrCoef() : Number
		{
			return GetCoef( m_isInterior );
		}

		public static function GetCoef( interior : Boolean ) : Number
		{
			if ( interior )
			{
				return m_interiorCoef;
			}
			return m_exteriorCoef;
		}

		public static function WorldToMapX( posX : Number ) : Number
		{
			return posX / m_exteriorCoef;
		}

		public static function WorldToMapY( posY : Number ) : Number
		{
			return -posY / m_exteriorCoef;
		}

		public static function WorldToInteriorMapX( posX : Number ) : Number
		{
			return posX / m_interiorCoef;
		}

		public static function WorldToInteriorMapY( posY : Number ) : Number
		{
			return -posY / m_interiorCoef;
		}

		public static function GetCameraAngle() : Number
		{
			if ( m_rotationEnabled )
			{
				return m_cameraAngle;
			}
			return 0;
		}
	}
}
