package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	import red.game.witcher3.events.MapContextEvent;
	import red.game.witcher3.utils.CommonUtils;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.controls.UILoader;

	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.StaticMapPinData;
	
	// NGE
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	// NGE
	

	public class UniverseMap extends BaseMap
	{
		public var mcUniverseMapContainer : UniverseMapContainer;
		public var mcUniverseMapCrosshair : MovieClip;
		
		private var currentSelectedArea:UniverseArea;
		private var scrollTimer:Timer;
		private const SCROLL_COEF = 20;
		
		private var _keyboardScrollLeft		: Boolean = false;
		private var _keyboardScrollRight	: Boolean = false;
		private var _keyboardScrollUp		: Boolean = false;
		private var _keyboardScrollDown		: Boolean = false;

		private static const KEYBOARD_SCROLL_SPEED : int = 10;
		
		private var playeLevel:int;
		
		
		// NGE
		private var _glowFilter:GlowFilter;
		private var GLOW_COLOR:Number = 0xaf9b70;
		private var GLOW_BLUR:Number = 0;
		private var GLOW_STRENGHT:Number = 1;
		private var GLOW_ALPHA:Number = 1.0;
		private var filterArray:Array = [];
		// NGE
		
		
		public function centerCurrentArea(animTransition:Boolean = true, animDuration:Number = .1):void
		{
			if (currentSelectedArea)
			{
				mcUniverseMapContainer.centerArea(currentSelectedArea, animTransition, animDuration);
			}
			else
			{
				mcUniverseMapContainer.centerCurrentArea(animTransition, animDuration);
			}
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.universe.area', 	[ setCurrentArea ] ) );
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.universe.questareas', 	[ setQuestAreas ] ) );
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.universe.playerLevel', 	[ setPlayerLevel ] ) );
			
			scrollTimer = new Timer(24);
			scrollTimer.addEventListener(TimerEvent.TIMER, handleScrollTimer, false, 0, true);
			scrollTimer.start();
			
			_defaultScale = UNIVERSE_MAP_ZOOM;
		}
		
		private function ResetKeyboardInput()
		{
			_keyboardScrollUp = _keyboardScrollDown = _keyboardScrollLeft = _keyboardScrollRight = false;
		}
		
		override public function CanProcessInput() : Boolean
		{
			if ( _transitionTween )
			{
				return false;
			}
			return true;
		}
		
		private function setCurrentArea(mapName:String):void
		{
			mcUniverseMapContainer.setCurrentArea(mapName);
		}
		
		private function setQuestAreas( array : Object, index : int )
		{
			if ( index == -1 )
			{
				mcUniverseMapContainer.setQuestAreas( array );
			}
		}
		private function setPlayerLevel(level : int ):void
		{
			playeLevel = level;
		}
		
		override public function handleInput( event : InputEvent ) : void
		{
            if ( event.handled )
			{
				return;
			}
			
			if ( !IsEnabled() )
			{
				return;
			}

            var details : InputDetails = event.details;
            var keyPress : Boolean = ( details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD );
            var keyUp    : Boolean = ( details.value == InputValue.KEY_UP );
			
			var axisData			: InputAxisData;
			var magnitude			: Number;
			var magnitudeSquared	: Number;
			var magnitudeCubed		: Number;
			
			if ( !CanProcessInput() )
			{
				return;
			}
			
            switch( details.code )
			{
				////////////////////////////////////////////////////////
				//
				// PC ONLY
				//
				case KeyCode.W:
				//case KeyCode.UP:
					if ( keyPress )
					{
						_keyboardScrollUp = true;
					}
					else if ( keyUp )
					{
						_keyboardScrollUp = false;
					}
					event.handled = true;
					break;
				case KeyCode.S:
				//case KeyCode.DOWN:
					if ( keyPress )
					{
						_keyboardScrollDown = true;
					}
					else if ( keyUp )
					{
						_keyboardScrollDown = false;
					}
					event.handled = true;
					break;
				case KeyCode.A:
				//case KeyCode.LEFT:
					if ( keyPress )
					{
						_keyboardScrollLeft = true;
					}
					else if ( keyUp )
					{
						_keyboardScrollLeft = false;
					}
					event.handled = true;
					break;
				case KeyCode.D:
				//case KeyCode.RIGHT:
					if ( keyPress )
					{
						_keyboardScrollRight = true;
					}
					else if ( keyUp )
					{
						_keyboardScrollRight = false;
					}
					event.handled = true;
					break;
				//
				//
				//
				////////////////////////////////////////////////////////

				case KeyCode.PAD_LEFT_STICK_AXIS:
					{
						axisData = InputAxisData( details.value );
						magnitude = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );
						magnitudeSquared = magnitude * magnitude;
						magnitudeCubed = magnitude * magnitude * magnitude;
						
						var scrollValue : Number = Math.min( SCROLL_COEF, SCROLL_COEF * magnitudeSquared );
						_bufScrollX = -scrollValue * axisData.xvalue;
						_bufScrollY = scrollValue * axisData.yvalue;
						//ScrollMap( -scrollValue * axisData.xvalue, scrollValue * axisData.yvalue );
						event.handled = true;
					}
					break;
                default:
                    return;
            }

			validateNow();   // # ?
		}

		private function GetScale() : Number
		{
			return actualScaleX;
		}

		private function GetGlobalCrosshairPos() : Point
		{
			return localToGlobal( new Point( mcUniverseMapCrosshair.x,  mcUniverseMapCrosshair.y) );
		}
		
		private var _bufScrollX:Number = 0;
		private var _bufScrollY:Number = 0;
		private function handleScrollTimer(event:TimerEvent):void
		{
			if (Math.abs(_bufScrollX) > 0 || Math.abs(_bufScrollY) > 0)
			{
				ScrollMap(_bufScrollX, _bufScrollY);
				_bufScrollX = 0;
				_bufScrollY = 0;
			}
			
			///////////////////////////////////////
			//
			// PC ONLY
			//
			if ( _keyboardScrollUp || _keyboardScrollDown || _keyboardScrollLeft || _keyboardScrollRight )
			{
				var upDownScroll : Number = 0;
				var leftRightScroll : Number = 0;
				
				if ( _keyboardScrollUp )
					upDownScroll = KEYBOARD_SCROLL_SPEED;
				else if ( _keyboardScrollDown )
					upDownScroll = -KEYBOARD_SCROLL_SPEED;

				if ( _keyboardScrollLeft )
					leftRightScroll = KEYBOARD_SCROLL_SPEED;
				else if ( _keyboardScrollRight )
					leftRightScroll = -KEYBOARD_SCROLL_SPEED;

				ScrollMap( leftRightScroll, upDownScroll );
			}
			//
			//
			///////////////////////////////////////
		}

		public function ScrollMap( dx : Number, dy : Number )
		{
			var scale:Number = GetScale();
			mcUniverseMapContainer.ScrollMap( dx / scale, dy / scale );
			updateAreaSelection();
		}
		
		public function updateAreaSelection(forceDeselect:Boolean = false):void
		{
			// TODO: Refact, make some events on over!
			var selectedArea:UniverseArea = null;
			var contextEvent:MapContextEvent;

			{
				var newSelectedArea : UniverseArea = mcUniverseMapContainer.GetOveredHub(GetGlobalCrosshairPos());
				if ( currentSelectedArea != newSelectedArea )
				{			
					if ( currentSelectedArea )
					{
						currentSelectedArea.mcIcon.gotoAndStop("inactive");
						
						// NGE
						if(currentSelectedArea as Hub_Custom)
						{
							var customUILoader1:UILoader = currentSelectedArea.mcIcon.getChildByName( "customUILoader" ) as UILoader;	
							
							if(customUILoader1)
							{
								_glowFilter = new GlowFilter( GLOW_COLOR, 1.0, GLOW_BLUR, GLOW_BLUR, 0, BitmapFilterQuality.HIGH );		
								filterArray = [];							
								filterArray.push( _glowFilter );								
								customUILoader1.filters = filterArray;
							}
						}
						// NGE
					}
					if ( newSelectedArea )
					{
						newSelectedArea.mcIcon.gotoAndStop("active");
						
						// NGE
						if(newSelectedArea as Hub_Custom)
						{
							var customUILoader2:UILoader = newSelectedArea.mcIcon.getChildByName( "customUILoader" ) as UILoader;
							
							if(customUILoader2)
							{
								_glowFilter = new GlowFilter( GLOW_COLOR, GLOW_ALPHA, GLOW_BLUR, GLOW_BLUR, GLOW_STRENGHT, BitmapFilterQuality.HIGH );
								filterArray = [];							
								filterArray.push( _glowFilter );							
								customUILoader2.filters = filterArray;
							}
						}
						// NGE
					}
				}
			}

			if ( !forceDeselect )
			{
				selectedArea = mcUniverseMapContainer.GetOveredHub(GetGlobalCrosshairPos());
			}
			
			if ( selectedArea && ( selectedArea != currentSelectedArea ) )
			{
				currentSelectedArea = selectedArea;
				mcUniverseMapCrosshair.gotoAndPlay("snap");
				//mcUniverseMapContainer.highlightArea(selectedArea);

				//selectedArea.mcIcon.scaleX = selectedArea.mcIcon.scaleY = 1.4;
				// tooltip
				var _tempString:String;
				contextEvent = new MapContextEvent(MapContextEvent.CONTEXT_CHANGE);
				contextEvent.active = true;
				var tooltipData:Object = { };
				var levelDiff : int = currentSelectedArea.recLevel - playeLevel;
				var fontColor: String;
				
				if (levelDiff >= 15)
				{
					fontColor = "<font color='#d61010'>";
				}
				else if (levelDiff < 15 && levelDiff>=6 )
				{
					fontColor = "<font color='#d68f29'>";
				}
				else
				{
					fontColor = "<font color='#FFFFFF'>";
				}
				tooltipData.title = "[[map_location_" + currentSelectedArea.GetWorldName() + "]]";
				tooltipData.description = CommonUtils.getLocalization("map_description_" + currentSelectedArea.GetWorldName());
				tooltipData.description += "<br>" + fontColor + CommonUtils.getLocalization("panel_item_required_level") + " " + currentSelectedArea.recLevel + "</font>";
				tooltipData.openRegion = true;
				contextEvent.tooltipData = tooltipData;
				dispatchEvent(contextEvent);
			}
			else if ( !selectedArea && currentSelectedArea )
			{
				currentSelectedArea = null;
				mcUniverseMapCrosshair.gotoAndPlay("normal");
				mcUniverseMapContainer.removeHiglighting();
				
				// tooltip
				contextEvent = new MapContextEvent(MapContextEvent.CONTEXT_CHANGE);
				contextEvent.active = false;
				dispatchEvent(contextEvent);
			}
		}
		
		public function GoToHubMap( hub : UniverseArea ) : Boolean
		{
			if ( hub )
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnSwitchToHubMap', [ hub.GetWorldName( false ) ] ) );
				return true;
			}
			return false;
		}

		public function GoToSelectedHubMap() : Boolean
		{
			var hub : UniverseArea = mcUniverseMapContainer.GetHubMapAtPoint( GetGlobalCrosshairPos() );
			if ( hub )
			{
				return GoToHubMap( hub );
			}
			return false;
		}
		
		override public function Enable( value : Boolean, force : Boolean = false )
		{
			if (_enabled == value)
			{
				if ( !force )
				{
					return;
				}
			}
			
			_enabled = value;
			if (_enabled)
			{
				ResetKeyboardInput();
				showMap(true)
			}
			else
			{
				hideMap(false);
			}
		}
		
		override public function OnControllerChanged( isGamepad : Boolean )
		{
			super.OnControllerChanged( isGamepad );

			mcUniverseMapCrosshair.visible = isGamepad;
			if ( isGamepad )
			{
				mcUniverseMapCrosshair.x = 0;
				mcUniverseMapCrosshair.y = 0;
			}
			//
			//trace("Minimap @@@@@ OnControllerChanged " + isGamepad );
			//
			updateAreaSelection();
		}
		
		public function OnMouseMove( mousePos : Point )
		{
			var localMousePos : Point = globalToLocal( mousePos );
			mcUniverseMapCrosshair.x = localMousePos.x;
			mcUniverseMapCrosshair.y = localMousePos.y;
			
			if ( CanProcessInput() )
			{
				updateAreaSelection();
			}
		}
	
		override protected function handleShowAnim(curTween:GTween = null):void
		{
			super.handleShowAnim( curTween );
			
			updateAreaSelection();
		}

	}
}
