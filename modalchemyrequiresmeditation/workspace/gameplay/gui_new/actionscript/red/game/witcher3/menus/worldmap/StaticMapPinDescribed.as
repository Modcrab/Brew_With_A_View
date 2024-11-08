/***********************************************************************
/** PANEL WorldMap map pin class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import scaleform.clik.controls.Label;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import fl.transitions.easing.*;
	import red.game.witcher3.utils.motion.TweenEx;
	
	import red.game.witcher3.data.StaticMapPinData;
	import scaleform.clik.controls.ListItemRenderer;
	import red.game.witcher3.data.StaticMapPinData;
	import scaleform.clik.events.InputEvent;
	import flash.geom.Point;

	public class StaticMapPinDescribed extends ListItemRenderer
	{
		//{region Art clips
		// ------------------------------------------------
		
		public var mcDescription			: Label;
		public var mcIcon					: MovieClip;
		public var tfLabel					: TextField;
		
		public var isAvatar:Boolean = false;
		
		private var _isInVisibleArea			: Boolean;
		private var _worldPosition				: Point;
		
		private static const HEIGHT_THRESHOLD		: Number = 10;
		
		private static const UNSELECTED_PIN_SCALE	: Number = 1.5; // 0.8
		private static const UNSELECTED_PIN_ALPHA	: Number = 1.0;
		private static const SELECTED_PIN_SCALE		: Number = 1.5;
		private static const SELECTED_PIN_ALPHA		: Number = 1.0;
		
		private var _pinInitialized:Boolean = false;
		private var _hasPointer:Boolean = false;
		
		//{region Initialization
		// ------------------------------------------------
		
		public function StaticMapPinDescribed()
		{
			_isInVisibleArea = false;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			preventAutosizing = true;
			mcIcon.scaleX = UNSELECTED_PIN_SCALE;
			mcIcon.scaleY = UNSELECTED_PIN_SCALE;
			mcIcon.alpha  = UNSELECTED_PIN_ALPHA;
			mcDescription.visible = false;
			focused = 1;			
		}
		
	//{region Overrides
	// ------------------------------------------------
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			update();
			
			if (!_pinInitialized)
			{
				_pinInitialized = true;
				
				if (!isAvatar && (data.isUserPin || data.isPlayer || data.isQuest))
				{
					PinPointersManager.getInstance().addPinPointer(this);
					_hasPointer = true;
				}
			}
		}
		
		override protected function updateAfterStateChange():void
		{
			super.updateAfterStateChange();

			//update();
		}
		
	//{region Internal callbacks and updates
	// ------------------------------------------------
	
		public function update():void //temp hax
		{
			if ( ! data ) // check before cast, so if data is an empty string etc then don't throw an exception
			{
				return;
			}
			var pinData : StaticMapPinData = data as StaticMapPinData;
			var prefix : String = "";

			if ( !pinData )
			{
				return;
			}
			mcIcon.mcPinIcon.visible = true;
			mcIcon.mcPinIcon.gotoAndStop( pinData.type );
			updateLabel();
			if ( pinData.radius && pinData.radius > 0 )
			{
				mcIcon.mcPinRadius.visible = true;
				mcIcon.mcPinRadius.mcRadialCircle.visible = true;
				mcIcon.mcPinRadius.mcRadialGlow.visible = false;
				if ( pinData.isQuest )
				{
					if ( pinData.type == 'QuestBelgard' )
					{
						mcIcon.mcPinRadius.mcRadialCircle.gotoAndStop( 3 );
					}
					else if ( pinData.type == 'QuestCoronata' )
					{
						mcIcon.mcPinRadius.mcRadialCircle.gotoAndStop( 4 );
					}
					else if ( pinData.type == 'QuestVermentino' )
					{
						mcIcon.mcPinRadius.mcRadialCircle.gotoAndStop( 5 );
					}
					else
					{
						mcIcon.mcPinRadius.mcRadialCircle.gotoAndStop( 1 );
					}
				}
				else
				{
					mcIcon.mcPinRadius.mcRadialCircle.gotoAndStop( 2 );
				}
			}
			else
			{
				mcIcon.mcPinRadius.visible = false;
			}
		}
		
		public function SetWorldPosition( worldX : Number, worldY : Number )
		{
			_worldPosition = new Point( worldX, worldY );
		}
		
		public function SetWorldPositionEx( worldX : Number, worldY : Number )
		{
			var pinData : StaticMapPinData = data as StaticMapPinData;
			pinData.posX = worldX;
			pinData.posY = worldY;
		}
		
		public function GetWorldPosition() : Point
		{
			return _worldPosition;
		}

		public function SetVisibleInArea( isInVisibleArea : Boolean )
		{
			_isInVisibleArea = isInVisibleArea;
			
			if (_hasPointer)
			{
				PinPointersManager.getInstance().showPinPointer(this, !_isInVisibleArea && !_isHidden);
			}
			
			//
			//trace("Minimap [" + _isInVisibleArea + "] [" + data.type + "]");
			//
		}
		
		public function IsVisibleInArea() : Boolean
		{
			return _isInVisibleArea;
		}
		
		private var _isHidden:Boolean = false;
		public function isHidden() : Boolean
		{
			return _isHidden;
		}
		
		public function setHidden(value:Boolean):void
		{
			_isHidden = value;
			visible = _isHidden ? false : true;
		}
		
		public function Show( showMapPin : Boolean )
		{
			mcIcon.visible = showMapPin;
			
			if (_hasPointer)
			{
				PinPointersManager.getInstance().showPinPointer(this, !_isInVisibleArea && !_isHidden);
			}
		}

		public function UpdateMapPosition2( mapX : Number, mapY : Number )
		{
			x = mapX;
			y = mapY;
		}

		public function UpdateMapPosition( mapPinPos : Point, scale : Number )
		{
			x = mapPinPos.x * scale;
			y = mapPinPos.y * scale;
		}

		public function UpdateScale( scale : Number, mapSize : int, addChildDescription : Boolean = false, force : Boolean = false )
		{
		}
		
		public function InitPingAnimation()
		{
			var pinData : StaticMapPinData = data as StaticMapPinData;
			if ( !pinData )
			{
				return;
			}
			if ( pinData.isPlayer )
			{
				mcIcon.mcPingAnimation.gotoAndPlay("Animation");
			}
		}
		
		public function UpdateHighlighting()
		{
			var pinData : StaticMapPinData = data as StaticMapPinData;
			if ( !pinData )
			{
				return;
			}
			
			if ( mcIcon.mcPinGlow )
			{
				mcIcon.mcPinGlow.visible = pinData.highlighted;
			}
		}
		
		private function updateLabel():void
		{
			var pinData : StaticMapPinData = data as StaticMapPinData;
			if ( pinData )
			{
				if ( pinData.isFastTravel )
				{
					//trace("Minimap ################################## updateLabel");
					tfLabel.htmlText = pinData.label;
					tfLabel.visible = true;
				}
				else
				{
					tfLabel.visible = false;
				}
			}
		}
	}
}
