package red.game.witcher3.menus.worldmap
{
	import adobe.utils.ProductManager;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.MapContextEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.Math2;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.gfx.MouseEventEx;

	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.StaticMapPinData;
	import red.game.witcher3.menus.worldmap.data.CategoryPinData;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.worldmap.HubMapPinPanel;

	public class HubMap extends BaseMap
	{
		public var mcHubMapCrosshair		: MapCrosshair;
		public var mcHubMapPinContainer		: HubMapPinContainer;
		public var mcHubMapZoomContainer	: HubMapZoomContainer;
		public var mcHubMapPreview			: HubMapPreview;
		public var mcHubMapPreviewAnchor	: MovieClip;
		
		private const USER_MAP_PIN_PANEL_DELAY : int = 300;
		
		override protected function showMap(animTween:Boolean = true):void
		{
			super.showMap(animTween);
			mcHubMapCrosshair.hideLabel(true);
		}

		override protected function hideMap(animTween:Boolean = true):void 
		{
			super.hideMap(animTween);
			mcHubMapCrosshair.hideLabel(true);
		}
		
		override protected function handleShowAnim(curTween:GTween = null):void 
		{
			super.handleShowAnim(curTween);
			
			setActualScale( 1, 1 );
			mcHubMapZoomContainer.setActualScale( _maxZoom, _maxZoom );
		}

		override public function Enable( value : Boolean, force : Boolean = false )
		{
			//
			//trace("Minimap ******************************************************** HubMap::Enable " + _enabled + " " + value );
			//

			cleanup( value );

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
				showMap(false);
				
				updateMapSwitchHint();
				ResetKeyboardInput();

				StartInitialTimer();
			}
			else
			{
				StopUpdateTexturesTimer();
				StopInitialTimer();
				StopShowTimer();

				hideMap(false);
				
				mcHubMapCrosshair.hideLabel( true );
				mcHubMapCrosshair.capturedState = false;
				
				ClearPins();

				// needed to fading in after switching to hub map
				//mcHubMapContainer.alpha = 0;
				mcHubMapZoomContainer.mcHubMapContainer.mcLodContainer.alpha = 0;
				mcHubMapZoomContainer.mcHubMapContainer.mcGradientContainer.alpha = 0;
				mcHubMapPinContainer.alpha = 0;
				
				if ( funcEnableCategoryPanel != null )
				{
					funcEnableCategoryPanel( false );
				}
				if ( funcEnableQuestTracker != null )
				{
					funcEnableQuestTracker( false );
				}
			}
		}
		
		var _prevTimeOfPressedX : int = 0;
		
		override public function handleInput( event : InputEvent ) : void
		{
			//
			//trace("Minimap handleInput " + event.details.code );
			//
			
            if ( event.handled || !IsEnabled())
			{
				return;
			}
			
			if ( !CanProcessInput() )
			{
				return;
			}
			
            var details : InputDetails = event.details;
            var keyDown : Boolean    = ( details.value == InputValue.KEY_DOWN );
            var keyUp : Boolean    = ( details.value == InputValue.KEY_UP );
            var keyPress : Boolean = ( details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD );
			
			var axisData			: InputAxisData;
			var magnitude			: Number;
			var magnitudeSquared	: Number;
			
			//
			//tracetracetrace("Minimap @@@@@@@@@@@@@@@ " + details.code + " " + KeyCode.NUMPAD_ADD + " " + KeyCode.NUMPAD_SUBTRACT );
			//
			
            switch( details.code )
			{
				////////////////////////////////////////////////////////
				//
				// PC ONLY
				//
				case KeyCode.Z:
					if ( keyDown )
					{
						if ( mcHubMapPreview.CanBeToggled() )
						{
							mcHubMapPreview.Toggle();
						}
					}
					break;
				case KeyCode.Z:
				case KeyCode.EQUAL:
				case KeyCode.NUMPAD_ADD:
					if ( !isAnimationRunning() )
					{
						if ( keyPress )
						{
							_keyboardZoomIn = true;
						}
						else if ( keyUp )
						{
							_keyboardZoomIn = false;
						}
					}
					break;
					
				case KeyCode.C:
				case KeyCode.MINUS:
				case KeyCode.NUMPAD_SUBTRACT:
					if ( !isAnimationRunning() )
					{
						if ( keyPress )
						{
							_keyboardZoomOut = true;
						}
						else if ( keyUp )
						{
							_keyboardZoomOut = false;
						}
					}
					break;
					
				case KeyCode.W:
				//case KeyCode.UP:
					if ( !isAnimationRunning() )
					{
						if ( keyPress )
						{
							_keyboardScrollUp = true;
						}
						else if ( keyUp )
						{
							_keyboardScrollUp = false;
						}
						event.handled = true;
					}
					break;
				case KeyCode.S:
				//case KeyCode.DOWN:
					if ( !isAnimationRunning() )
					{
						if ( keyPress )
						{
							_keyboardScrollDown = true;
						}
						else if ( keyUp )
						{
							_keyboardScrollDown = false;
						}
						event.handled = true;
					}
					break;
				case KeyCode.A:
				//case KeyCode.LEFT:
					if ( !isAnimationRunning() )
					{
						if ( keyPress )
						{
							_keyboardScrollLeft = true;
						}
						else if ( keyUp )
						{
							_keyboardScrollLeft = false;
						}
						event.handled = true;
					}
					break;
				case KeyCode.D:
				//case KeyCode.RIGHT:
					if ( !isAnimationRunning() )
					{
						if ( keyPress )
						{
							_keyboardScrollRight = true;
						}
						else if ( keyUp )
						{
							_keyboardScrollRight = false;
						}
						event.handled = true;
					}
					break;
				//
				//
				//
				////////////////////////////////////////////////////////

				case KeyCode.E:
				case KeyCode.ENTER:
				case KeyCode.PAD_A_CROSS:
					if ( keyUp )
					{
						UseSelectedPin();
						event.handled = true;
					}
					break;
				
				case KeyCode.Q:
				case KeyCode.PAD_X_SQUARE:
					if ( keyDown )
					{
						startSettingUserPin( localToGlobal( new Point( mcHubMapCrosshair.x, mcHubMapCrosshair.y ) ) );
						event.handled = true;
					}
					else if ( keyUp )
					{
						finishSettingUserPin();
						event.handled = true;
					}
					break;

				////////////////////////////////////////////////////
				//
				// DEBUG INPUT START
				//
				case KeyCode.PAD_LEFT_TRIGGER:
					if ( _manualLod )
					{
						if ( keyDown )
						{
							mcHubMapZoomContainer.mcHubMapContainer.DecreaseLod();
						}
						event.handled = true;
					}
					break;
				case KeyCode.PAD_RIGHT_TRIGGER:
					if ( _manualLod )
					{
						if ( keyDown )
						{
							mcHubMapZoomContainer.mcHubMapContainer.IncreaseLod();
						}
						event.handled = true;
					}
					else
					{
						if ( keyDown )
						{
							if ( mcHubMapPreview.CanBeToggled() )
							{
								mcHubMapPreview.Toggle();
							}
						}
					}
					break;
				//
				// DEBUG INPUT END
				//
				////////////////////////////////////////////////////

				case KeyCode.PAD_LEFT_THUMB:
				case KeyCode.TAB:
					if ( keyUp && !isAnimationRunning() )
					{
						CenterBetweenQuestAndPlayer();
						event.handled = true;
					}
					break;

				case KeyCode.PAD_LEFT_STICK_AXIS:
					if ( !isAnimationRunning() )
					{
						axisData = InputAxisData( details.value );
						
						magnitude = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue ); //getMagnitudeSquared
						magnitudeSquared = magnitude * magnitude;
						
						//magnitudeSquared = InputUtils.getMagnitudeSquared( axisData.xvalue, axisData.yvalue );
						
						//trace("TP PAD_LEFT_STICK_AXIS, xvalue: ", axisData.xvalue, " yvalue: ", axisData.yvalue, "; ", magnitudeCubed);
						
						var scrollValue:Number;
						if (magnitude > FORSAGE_TRIGGERING_LIMIT)
						{
							scrollValue = _scrollCoef * magnitudeSquared * FORSAGE_FACTOR;
							_applyAcceleration = true;
							
							//this.alpha = .7;
							
							const IGNORE_SNAPPING_DELAY = 150;							
							if (!_accelerationTimer && !_ignoreSnapping)
							{
								_accelerationTimer = new Timer(IGNORE_SNAPPING_DELAY);
								_accelerationTimer.addEventListener(TimerEvent.TIMER, handleAccelerationTimer, false, 0, true);
								_accelerationTimer.start();
							}
						}
						else
						{
							scrollValue =  _scrollCoef * magnitudeSquared;
							_applyAcceleration = false;
							
							//this.alpha = 1;
							_ignoreSnapping = false;
							if (_accelerationTimer)
							{
								_accelerationTimer.stop();
								_accelerationTimer.removeEventListener(TimerEvent.TIMER, handleAccelerationTimer);
								_accelerationTimer = null;
							}
						}
						
						_gamepadScrollX = -scrollValue * axisData.xvalue;
						_gamepadScrollY = scrollValue * axisData.yvalue;
						event.handled = true;
					}
					break;
					
				case KeyCode.PAD_RIGHT_STICK_AXIS:
					if ( !isAnimationRunning() )
					{
						axisData = details.value as InputAxisData;
						if (axisData)
						{
							if ( Math.abs( axisData.yvalue ) > .8 )
							{
								_gamepadZoomValue = axisData.yvalue;
							}
						}
					}
					break;
					
                default:
                    return;
            }
		}
		
		private var _stagePositionForUserPin : Point;

		private function startSettingUserPin( globalPos : Point )
		{
			_stagePositionForUserPin = globalPos;
			
			if ( !_snapTween1 )
			{
				_prevTimeOfPressedX = getTimer();
				startUserPinTimer();
			}
		}
		
		private function continueSettingUserPin() : Boolean
		{
			if ( _prevTimeOfPressedX > 0 )
			{
				var currTimeOfPressedX : int = getTimer();
				if ( currTimeOfPressedX - _prevTimeOfPressedX > USER_MAP_PIN_PANEL_DELAY )
				{
					enableUserPinPanel( true, _stagePositionForUserPin );
					_prevTimeOfPressedX = 0;
					return true;
				}
			}
			return false;
		}

		private function finishSettingUserPin()
		{
			if ( _prevTimeOfPressedX > 0 )
			{
				var currTimeOfPressedX : int = getTimer();
				if ( currTimeOfPressedX - _prevTimeOfPressedX > USER_MAP_PIN_PANEL_DELAY )
				{
					enableUserPinPanel( true, _stagePositionForUserPin );
				}
				else
				{
					setUserMapPin( 0, false );
				}
				_prevTimeOfPressedX = 0;
				stopUserPinTimer();
			}
		}
		
		private var _userPinTimer:Timer;
		
		private function startUserPinTimer()
		{
			stopUserPinTimer();
			
			_userPinTimer = new Timer(  101 );
			_userPinTimer.addEventListener( TimerEvent.TIMER, handleUserPinTimer, false, 0, true );
			_userPinTimer.start();
		}
		
		private function stopUserPinTimer()
		{
			if ( _userPinTimer )
			{
				_userPinTimer.stop();
				_userPinTimer.removeEventListener( TimerEvent.TIMER, handleUserPinTimer );
				_userPinTimer = null;
			}
		}

		private function handleUserPinTimer(e:TimerEvent):void
		{
			if ( continueSettingUserPin() )
			{
				stopUserPinTimer();
			}
		}

		private var _accelerationTimer:Timer;
		private function handleAccelerationTimer(e:TimerEvent):void
		{
			_ignoreSnapping = true;
			
			_accelerationTimer.stop();
			_accelerationTimer.removeEventListener(TimerEvent.TIMER, handleAccelerationTimer);
			_accelerationTimer = null;
		}
		
		
		
		
		
		private static const FORSAGE_FACTOR:Number = 1;
		private static const FORSAGE_TRIGGERING_LIMIT:Number = .90;
		
		private static const SCROLL_SNAP_SPEED = 26;
		
		private static const SCROLL_COEF_MAX = 20;
		private static const SCROLL_COEF_MIN = 15;
		
		private static const SCROLL_COEF_ACCELERATION:Number = 1;
		private static const ACCELERATION_INTERVAL:Number = 150;
		private static const SNAP_DISTANCE:Number = 15;
		private static const SNAP_DISTANCE_SQUARED:Number = SNAP_DISTANCE * SNAP_DISTANCE;
		private static const SNAP_FREE_LIMIT:Number = 16;
		
		private static const INITIAL_INTERVAL = 20;
		private static const SHOW_INTERVAL = 200;
		private static const UPDATE_HUB_TEXTURES_INTERVAL = 1000;
		private static const FADING_GRADIENT_DURATION = 0.33;
		private static const FADING_TEXTURES_DURATION = 0.66;
		
		private static const MAX_PROCESSED_PIN_COUNT = 30;
		
		private static const POINT_0_0 : Point = new Point( 0, 0 );
		
		private static const KEYBOARD_SCROLL_SPEED : int = 20;
		
		private var _bufPosX      	: Number = 0;
		private var _bufPosY      	: Number = 0;
		private var _snapTween1    	: GTween;
		private var _snapTween2		: GTween;
		
		public var showGotoWorldHint:Function;
		public var showGotoPlayerPin:Function;
		public var showGotoQuestPin:Function;
		public var enableUserPinPanel:Function;
		public var funcClearCategoryPanel : Function;
		public var funcInitializeCategoryPanel : Function;
		public var funcUpdateCategoryPanel : Function;
		public var funcEnableCategoryPanel : Function;
		public var funcAddPinToCategoryPanel : Function;
		public var funcEnableQuestTracker : Function;
		
		private var _mapPinClass			: Class = getDefinitionByName( "StaticMapPinBase" ) as Class;
		private var _staticMapPins			: Vector.< StaticMapPinDescribed > = new Vector.< StaticMapPinDescribed >();
		private var _selectedMapPinIndex	: int = -1;

		private var _playerPinIdx			: int = -1;
		private var _questMapPinIndices		: Vector.< int > = new Vector.< int >();
		private var _lonelyFastTravelPinIdx : int = -1;
		private var _fastTravelPinExist		: Boolean = false;
		
		private var _initialPlayerPinIdx	: int = -1;
		private var _initialLonelyFastTravelPinIdx : int = -1;
		private var _initialFastTravelPinExist : Boolean = false;
		
		private var _mapPinDataArray		: Array;
		private var _mapPinDataIndex		: int;

		private var _closestPinIndex		: int = -1;
		
		private var _scrollCoef				: Number = 0;
		private var _textureSize			: int = 0;
		private var _mapSize				: int = 0;
		private var _tileCount				: int = 0;
		
		private var _speedTimer:Timer;
		private var _inScroll:Boolean;
		private var _applyAcceleration:Boolean;
		private var _ignoreSnapping:Boolean = false;
		
		private var _selectedPinAvatar:StaticMapPinDescribed = null;
		
		private var _initialTimer:Timer;
		private var _showMapTimer:Timer;
		private var _updateTexturesTimer:Timer;		
		private var _scrollAndZoomTimer:Timer;
		
		private var _fastTravelMode:Boolean;
		private var _minZoom : Number;
		private var _maxZoom : Number;
		private var _zoomBoundaries : Vector.< ZoomBoundary >;
		private var _unlimitedZoom : Boolean = false;
		private var _manualLod : Boolean = false;
		
		private var _defaultX : Number = -1;
		private var _defaultY : Number = -1;
		
		private var _menuAnimCompleted : Boolean = false;
		private var _fadingInCompleted : Boolean = false;
		
		private var _worldLeftBottom : Point = new Point;
		private var _worldRightTop   : Point = new Point;
		
		private var _currentAreaId : int = -1;
		
		public function HubMap()
		{
			_defaultScale = 1;
			
			_speedTimer = new Timer(ACCELERATION_INTERVAL, 0);
			_speedTimer.addEventListener(TimerEvent.TIMER, handleSpeedTimer, false, 0, true);
			_speedTimer.start();
			
			_scrollAndZoomTimer = new Timer(33);
			_scrollAndZoomTimer.addEventListener(TimerEvent.TIMER, handleScrollAndZoomTimer, false, 0, true);
			_scrollAndZoomTimer.start();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.pins.static', 			[ setPins ] ) );
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.pins.static.update', 	[ updatePins ] ) );
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.pins.dynamic', 		[ setDynamicPins ] ) );
			
			_scrollCoef = SCROLL_COEF_MIN;
			
			//mcHubMapContainer.alpha = 0;
			mcHubMapZoomContainer.mcHubMapContainer.mcLodContainer.alpha = 0;
			mcHubMapZoomContainer.mcHubMapContainer.mcGradientContainer.alpha = 0;
			mcHubMapPinContainer.alpha = 0;
		}
		
		public function setCurrentAreaId( areaId : int )
		{
			_currentAreaId = areaId;
		}
		
		private function ResetKeyboardInput()
		{
			_keyboardZoomIn = _keyboardZoomOut = false;
			_keyboardScrollUp = _keyboardScrollDown = _keyboardScrollLeft = _keyboardScrollRight = false;
			
			_gamepadZoomValue = 0;
			_gamepadScrollX = _gamepadScrollY = 0;
		}
		
		override public function CanProcessInput() : Boolean
		{
			if ( _initialTimer || _showMapTimer || !_fadingInCompleted )
			{
				return false;
			}
			return true;
		}
		
		override public function OnControllerChanged( isGamepad : Boolean )
		{
			super.OnControllerChanged( isGamepad );
			
			mcHubMapCrosshair.visible = isGamepad;
			if ( isGamepad )
			{
				mcHubMapCrosshair.x = 0;
				mcHubMapCrosshair.y = 0;
			}
			updateMapSwitchHint();
		}

		public function OnMouseDoubleDown( buttonIdx : uint, globalMousePos : Point )
		{
			if ( !CanProcessInput() )
			{
				return;
			}
			UseSelectedPin();
		}
		
		public function OnMouseDown( buttonIdx : uint, globalMousePos : Point )
		{
			updateCursorPosition( globalMousePos );

			if ( mcHubMapPreview.hitTestPoint( globalMousePos.x, globalMousePos.y ) )
			{
				if ( buttonIdx == MouseEventEx.LEFT_BUTTON )
				{
					mcHubMapPreview.SetLMBDown( true );
					centerOnPreviewPosition( globalMousePos );
				}
			}
			else
			{
				if ( buttonIdx == MouseEventEx.RIGHT_BUTTON )
				{
					startSettingUserPin( globalMousePos );
				}
			}
		}
		
		public function OnMouseUp( buttonIdx : uint, globalMousePos : Point )
		{
			if ( buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				mcHubMapPreview.SetLMBDown( false );
			}
			else if ( buttonIdx == MouseEventEx.RIGHT_BUTTON )
			{
				finishSettingUserPin();
			}
		}
		
		public function OnMouseMove( globalMousePos : Point )
		{
			if ( mcHubMapPreview.IsLMBDown() )
			{
				centerOnPreviewPosition( globalMousePos );
			}
			else
			{
				updateCursorPosition( globalMousePos );
				UpdateVisibilityAndPinPositions( false );
				UpdateSelectedMapPin( false );
			}
		}
		
		private function centerOnPreviewPosition( globalMousePos : Point )
		{
			var worldPos : Point = mcHubMapPreview.GetWorldMapHitPoint( globalMousePos );
					
			var targetX : Number = -WorldXToMapX( worldPos.x );
			var targetY : Number = -WorldYToMapY( worldPos.y );
			
			CenterOnPosition( targetX, targetY );
		}

		public function centerOnWorldPosition( worldPos : Point, animate : Boolean )
		{
			var targetX : Number = -WorldXToMapX( worldPos.x );
			var targetY : Number = -WorldYToMapY( worldPos.y );
			
			CenterOnPosition( targetX, targetY, animate );
			UpdateSelectedMapPin( false );
		}

		public function showPinsFromCategory( pins : Array, showUserPins : Boolean, showFastTravelPins : Boolean, showQuestPins : Boolean, disabledPins : Dictionary, onStart : Boolean )
		{
			//trace("Minimap1 showPinsFromCategory--------------------", onStart, disabledPins );
			
			var i : int;
			var categoryPinData : CategoryPinData;
			var pin : StaticMapPinDescribed;
			var pinData : StaticMapPinData;
			
			if ( pins == null )
			{
				// show all
				//trace("Minimap1 =============== ALL" );
				for ( i = 0; i < _staticMapPins.length; ++i )
				{
					pin = _staticMapPins[ i ];
					pinData = pin.data as StaticMapPinData;

					//trace( "Minimap1 +", _staticMapPins[ i ].data.type );

					var hidden : Boolean = true;
					if ( pinData.isUserPin )
					{
						if ( !disabledPins.hasOwnProperty( HubMapPinPanel.USER_PIN_TYPE ) )
						{
							hidden  = false;
						}
					}
					else if ( pinData.isQuest )
					{
						if ( !disabledPins.hasOwnProperty( HubMapPinPanel.QUEST_PIN_TYPE ) )
						{
							hidden  = false;
						}
					}
					else if ( !disabledPins.hasOwnProperty( pin.data.type ) )
					{
						hidden  = false;
					}
					else
					{
						hidden = true;
					}
					
					pin.setHidden( hidden );
				}
			}
			else
			{
				var dictionary : Dictionary = new Dictionary;
				
				if ( pins )
				{
					for ( i = 0; i < pins.length; ++i )
					{
						categoryPinData = pins[ i ] as CategoryPinData;
						dictionary[ categoryPinData._name ] = 1;
					}
				}

				//trace("Minimap1 =============== SEL" );
				for ( i = 0; i < _staticMapPins.length; ++i )
				{
					pin = _staticMapPins[ i ];
					pinData = pin.data as StaticMapPinData;
					
					if (   pinData.isPlayer ||
						 ( pinData.isUserPin    && showUserPins && !disabledPins.hasOwnProperty( HubMapPinPanel.USER_PIN_TYPE ) ) ||
						 ( pinData.isFastTravel && showFastTravelPins ) ||
						 ( pinData.isQuest      && showQuestPins && !disabledPins.hasOwnProperty( HubMapPinPanel.QUEST_PIN_TYPE ) ) ||
						 ( dictionary.hasOwnProperty( pinData.filteredType ) && !disabledPins.hasOwnProperty( pinData.filteredType ) )
					   )
					{
						pin.setHidden( false );
						//trace( "Minimap1 +", pinData.type, pinData.filteredType );
					}
					else
					{
						pin.setHidden( true );
						//trace( "Minimap1 -", pinData.type, pinData.filteredType );
					}
				}
			}
			
			if ( !onStart )
			{
				UpdateVisibilityAndPinPositions( false );
				PinPointersManager.getInstance().updatePointersPosition();
				UpdateSelectedMapPin( false );
			}
		}
		
		public function setHighlightedMapPin( tag: uint )
		{
			var i : int;
			var pinData : StaticMapPinData;
			
			for ( i = 0; i < _staticMapPins.length; ++i )
			{
				pinData = _staticMapPins[ i ].data as StaticMapPinData;
				
				if ( pinData.isQuest )
				{
					if ( pinData.id == tag )
					{
						if ( !pinData.highlighted )
						{
							pinData.highlighted = true;
							_staticMapPins[ i ].UpdateHighlighting();
						}
					}
					else
					{
						if ( pinData.highlighted )
						{
							pinData.highlighted = false;
							_staticMapPins[ i ].UpdateHighlighting();
						}
					}
				}
			}
			
			mcHubMapPreview.updateMapPinHighlighting();
		}
		
		public function updateCursorPosition( mousePos : Point )
		{
			var localMousePos : Point = globalToLocal( mousePos );
			mcHubMapCrosshair.x = localMousePos.x;
			mcHubMapCrosshair.y = localMousePos.y;
		}

		public function SetMenuAnimCompleted()
		{
			_menuAnimCompleted = true;
			updatePreviewAnchorPosition();
		}
		
		public function setDefaultPosition(defX:Number, defY:Number):void
		{
			_defaultX = defX
			_defaultY = defY;
		}
		
		public function cleanup( entering : Boolean ):void
		{
			if ( !entering )
			{
				// only when exiting
				UnselectPin();
				mcHubMapZoomContainer.mcHubMapContainer.HideAllTiles();
			}

			setActualScale( 1, 1 );
			mcHubMapZoomContainer.setActualScale( _maxZoom, _maxZoom );
			
			_scrollCoef = SCROLL_COEF_MIN;			
			
			showMapSwitchHint( false );
		}
		
		public function GetZoomBoundaries() : Vector.< ZoomBoundary >
		{
			return _zoomBoundaries;
		}
		
		public function SetMapZooms( minZoom : Number,  maxZoom : Number, zoom12 : Number, zoom23 : Number, zoom34 : Number )
		{
			_minZoom = minZoom;
			_maxZoom = maxZoom;

			_zoomBoundaries = new Vector.< ZoomBoundary >;
			_zoomBoundaries[ 0 ] = new ZoomBoundary( -1, zoom12 );
			_zoomBoundaries[ 1 ] = new ZoomBoundary( zoom12, zoom23 );
			_zoomBoundaries[ 2 ] = new ZoomBoundary( zoom23, zoom34 );
			_zoomBoundaries[ 3 ] = new ZoomBoundary( zoom34, -1 );
			
			var i : int;
			for ( i = 0; i < _zoomBoundaries.length; ++i )
			{
				if ( _zoomBoundaries[ i ]._min < 0 && _zoomBoundaries[ i ]._max > 0 )
				{
					_zoomBoundaries[ i ]._min = minZoom;
					break;
				}
			}
			for ( i = _zoomBoundaries.length - 1; i >= 0 ; --i )
			{
				if ( _zoomBoundaries[ i ]._max < 0 && _zoomBoundaries[ i ]._min > 0 )
				{
					_zoomBoundaries[ i ]._max = maxZoom;
					break;
				}
			}
			
			//
			//trace("Minimap ------------- ZOOM BOUNDARIES --------------");
			//
			//for ( i = 0; i < _zoomBoundaries.length; ++i )
			//{
			//	trace("Minimap " + i + " " + _zoomBoundaries[ i ].IsValid() + " " + _zoomBoundaries[ i ]._min + " " +  _zoomBoundaries[ i ]._max );
			//}
		}

		var _mapVisMinX : int;
		var	_mapVisMaxX : int;
		var	_mapVisMinY : int;
		var	_mapVisMaxY : int;
		
		public function SetMapVisibilityBoundaries( minX : int, maxX : int, minY : int, maxY : int, gradientScale : Number )
		{
			_mapVisMinX = minX;
			_mapVisMaxX = maxX;
			_mapVisMinY = minY;
			_mapVisMaxY = maxY;
			mcHubMapZoomContainer.mcHubMapContainer.SetMapVisibilityBoundaries( minX, maxX, minY, maxY, gradientScale );
		}
		
		public function SetMapScrollingBoundaries( minX : int, maxX : int, minY : int, maxY : int )
		{
			mcHubMapZoomContainer.mcHubMapContainer.SetMapScrollingBoundaries( minX, maxX, minY, maxY );
		}
		
		public function SetMapSettings( mapSize : Number, tileCount : int, textureSize : int, minLod : int, maxLod : int, imagePath : String, visibleArea : MovieClip, previewAvailable : Boolean, previewMode : int )
		{
			//
			//trace("Minimap SetMapSettings();");
			//

			_textureSize = textureSize;
			_mapSize = mapSize;
			_tileCount = tileCount;
			
			UnselectPin();
			ClearPins();
			mcHubMapZoomContainer.mcHubMapContainer.SetMapSettings( textureSize, minLod, maxLod, imagePath, visibleArea );

			mcHubMapPreview.setMapSettings( mapSize, textureSize, imagePath, MapXToWorldX( _mapVisMinX ),
																			MapXToWorldX( _mapVisMaxX ),
																			MapYToWorldY( _mapVisMinY ),
																			MapYToWorldY( _mapVisMaxY ),
																			previewAvailable,
																			previewMode );
																	
			updatePreviewAnchorPosition();

			//
			//trace("Minimap ======================== SetMapSettings" );
			//setInitMapPosition();
			//
		}
		
		private function updatePreviewAnchorPosition()
		{
			mcHubMapPreview.updateAnchorPosition( localToGlobal( new Point( mcHubMapPreviewAnchor.x, mcHubMapPreviewAnchor.y ) ) );
		}
		
		public function ReinitializeMap()
		{
			setActualScale( 1, 1 );
			mcHubMapZoomContainer.setActualScale( _maxZoom, _maxZoom );
			
			UpdateLod( false );
			
			//
			//trace("Minimap ======================== ReinitializeMap" );
			//
			setInitMapPosition();
		}
		
		public function EnableUnlimitedZoom( enable : Boolean )
		{
			_unlimitedZoom = enable;
		}

		public function EnableManualLod( enable : Boolean )
		{
			_manualLod = enable;
		}
		
		public function UpdateDebugBorders()
		{
			mcHubMapZoomContainer.mcHubMapContainer.UpdateDebugBorders();
		}
		
		private function setPins( gameData : Object, index : int )
		{
			if ( index > -1 )
			{
				return;
			}
			//
			//trace("Minimap ######################################################### setPins");
			//
			
			_mapPinDataArray = gameData as Array;
			_mapPinDataIndex = -1;
		}
		
		private function updatePins( gameData : Object, index : int )
		{
			if ( index > -1 )
			{
				return;
			}
			//
			//trace("Minimap ######################################################### updatePins");
			//
			
			_mapPinDataArray = gameData as Array;
			_mapPinDataIndex = -1;
			
			initializeMapPinsProcessing();
			processMapPins( true );
			finalizeMapPinsProcessing( true );
		}
		
		private function setDynamicPins( gameData : Object, index : int )
		{
			var pinDataArray : Array;
			var pinData : StaticMapPinData;
			var i, pinCount : int;
			var pinScale : Number = GetScale();

			if ( index > -1 )
			{
				return;
			}

			pinDataArray = gameData as Array;
			if ( !pinDataArray )
			{
				return;
			}

			pinCount = pinDataArray.length;
			
			for ( i = 0; i < pinCount; ++i )
			{
				pinData = pinDataArray[ i ] as StaticMapPinData;
				CreatePin( pinData, _staticMapPins.length, pinScale );
				
				if ( pinData.isQuest )
				{
					mcHubMapPreview.addPin( pinData );
				}
				else if ( pinData.isPlayer )
				{
					mcHubMapPreview.addPin( pinData );
				}
				else if ( pinData.isUserPin )
				{
					mcHubMapPreview.addPin( pinData );
				}
				
				if ( funcAddPinToCategoryPanel != null )
				{
					funcAddPinToCategoryPanel( pinData );
				}
			}
			
			if ( funcUpdateCategoryPanel != null )
			{
				funcUpdateCategoryPanel();
			}
			
			//////////////////////////////////////
			// quick ugly hack
			var prevIgnoreSnapping : Boolean = _ignoreSnapping;
			_ignoreSnapping = false;
			//
			//////////////////////////////////////

			UpdateVisibilityAndPinPositions();

			//////////////////////////////////////////////
			// quick ugly hack
			_ignoreSnapping = prevIgnoreSnapping;
			//
			//////////////////////////////////////
			
			PinPointersManager.getInstance().updatePointersPosition();
			UpdateSelectedMapPin( false );
		}
		
		private function initializeMapPinsProcessing()
		{
			//
			//trace("Minimap initializeMapPinsProcessing" );
			//
			
			UnselectPin();
			
			_fastTravelPinExist = false;
			_lonelyFastTravelPinIdx = -1;
			_questMapPinIndices.length = 0;
			_playerPinIdx = -1;

			_initialFastTravelPinExist = false;
			_initialLonelyFastTravelPinIdx = -1;
			_initialPlayerPinIdx = -1;

			_selectedMapPinIndex = -1;
			_mapPinDataIndex = 0;

			PinPointersManager.getInstance().cleanup();
			ClearPins();
		}

		private function processMapPins( immediately : Boolean = false ) : Boolean
		{
			if ( !_mapPinDataArray )
			{
				return true;
			}
			
			// debug event
			//dispatchEvent( new GameEvent(GameEvent.CALL, "OnDebugEvent", [ 0 ] ) );
			//

			var pin : StaticMapPinDescribed;
			var pinData : StaticMapPinData;

			var currPinIndex : int = _mapPinDataIndex;
			var pinCount;
			if ( immediately )
			{
				pinCount = _mapPinDataArray.length;
			}
			else
			{
				pinCount = Math.min( _mapPinDataIndex + MAX_PROCESSED_PIN_COUNT, _mapPinDataArray.length );
			}
			
			var pinScale : Number = GetScale();
			
			//
			//trace("Minimap processMapPins " + currPinIndex + " " + pinCount + "     " + _mapPinDataArray.length );
			//
			for ( ; currPinIndex < pinCount; ++currPinIndex, ++_mapPinDataIndex )
			{
				//
				//trace("Minimap pin " + currPinIndex );
				//
				pinData = _mapPinDataArray[ currPinIndex ] as StaticMapPinData;
				pin = CreatePin( pinData, currPinIndex, pinScale );
				
				if ( !pin )
				{
					continue;
				}
				
				if ( pinData.isFastTravel )
				{
					if ( pinData.journalAreaId == _currentAreaId )
					{
						if ( !_initialFastTravelPinExist )
						{
							_initialLonelyFastTravelPinIdx = currPinIndex;
							_initialFastTravelPinExist = true;
						}
						else
						{
							_initialLonelyFastTravelPinIdx = -1;
						}
					}
					
					if ( !_fastTravelPinExist )
					{
						_lonelyFastTravelPinIdx = currPinIndex;
						_fastTravelPinExist = true;
					}
					else
					{
						_lonelyFastTravelPinIdx = -1;
					}
				}
				else if ( pinData.isQuest )
				{
					if ( pinData.highlighted )
					{
						_questMapPinIndices.unshift( currPinIndex );
					}
					else
					{
						_questMapPinIndices.push( currPinIndex );
					}
					mcHubMapPreview.addPin( pinData );
				}
				else if ( pinData.isPlayer )
				{
					if ( pinData.journalAreaId == _currentAreaId )
					{
						_initialPlayerPinIdx = currPinIndex;
					}
					_playerPinIdx = currPinIndex;
					mcHubMapPreview.addPin( pinData );
				}
				else if ( pinData.isUserPin )
				{
					mcHubMapPreview.addPin( pinData );
				}

				if ( funcAddPinToCategoryPanel != null )
				{
					funcAddPinToCategoryPanel( pinData );
				}
			}
			
			// debug event
			//dispatchEvent( new GameEvent(GameEvent.CALL, "OnDebugEvent", [ 1 ] ) );
			//
			
			return _mapPinDataIndex >= _mapPinDataArray.length;
		}

		private function finalizeMapPinsProcessing( immediately : Boolean = false )
		{
			//
			//trace("Minimap finalizeMapPinsProcessing" );
			//
			
			if ( funcInitializeCategoryPanel != null )
			{
				funcInitializeCategoryPanel();
			}
			
			if ( !immediately )
			{
				setInitMapPosition();
			}
			UpdateVisibilityAndPinPositions();
			UpdateSizeForAreaMapPins( GetComponentScale() );
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function setInitMapPosition()
		{
			//
			//trace("Minimap ======================== setInitMapPosition" );
			//
			if ( _initialLonelyFastTravelPinIdx > -1 )
			{
				CenterOnPin(_initialLonelyFastTravelPinIdx, NaN, NaN, false);
			}
			else if ( _initialPlayerPinIdx > -1 )
			{
				CenterOnPlayer();
			}
			else if ( _defaultX != -1 && _defaultY != -1 )
			{
				CenterOnPosition( _defaultX, _defaultY );
			}
			else
			{
				CenterOnTheMiddleOfTheMap();
			}
		}
		
		protected function ClearPins():void
		{
			_questMapPinIndices.length = 0;
			_playerPinIdx = -1;
			
			for ( var i : int = 0; i < _staticMapPins.length; i++ )
			{
				var curPin:StaticMapPinDescribed = _staticMapPins[i];
				removePinChild(curPin);
			}
			_staticMapPins.length = 0;
			
			mcHubMapPreview.clearPins();

			if ( funcClearCategoryPanel != null )
			{
				funcClearCategoryPanel();
			}
		}

		private function GetScale() : Number
		{
			return mcHubMapZoomContainer.actualScaleX;
		}

		private function GetComponentScale() : Number
		{
			return 1.0 / mcHubMapZoomContainer.actualScaleX;
		}

		protected function handleSpeedTimer(event:TimerEvent):void
		{			
			if (_inScroll && _applyAcceleration)
			{
				_inScroll = false;
				if (_scrollCoef < SCROLL_COEF_MAX)
				{
					_scrollCoef += SCROLL_COEF_ACCELERATION;
				}
			}
			else
			{
				_scrollCoef = SCROLL_COEF_MIN;
			}
			
			// #Y debug speed params			
			//this.parent["debugText"].htmlText = ("Scroll speed: " + Math.round(_scrollCoef * 100) / 100 + "<br/> Scale: " + Math.round(scaleX * 100) / 100 );
			
			/*
			this.parent["tfDebugInfo"].htmlText = ("Scroll speed: " + Math.round(_scrollCoef * 100) / 100);
			
			if (_ignoreSnapping)
			{			
				(this.parent["tfDebugInfo"] as TextField).textColor = 0xFF000;
			}
			else
			{
				(this.parent["tfDebugInfo"] as TextField).textColor = 0xFFFFFF;
			}
			*/
		}
		
		private var _gamepadZoomValue:Number = 0;
		private var _gamepadScrollX:Number = 0;
		private var _gamepadScrollY:Number = 0;
		
		private var _keyboardZoomIn			: Boolean = false;
		private var _keyboardZoomOut		: Boolean = false;
		private var _keyboardScrollLeft		: Boolean = false;
		private var _keyboardScrollRight	: Boolean = false;
		private var _keyboardScrollUp		: Boolean = false;
		private var _keyboardScrollDown		: Boolean = false;

		private var _isZooming:Boolean = false;
		private var _isScrolling:Boolean = false;
		
		private function handleScrollAndZoomTimer(event:TimerEvent):void
		{
			if ( !IsEnabled() )
			{
				return;
			}

			if ( _gamepadZoomValue != 0 )
			{
				_isZooming = zoomMap( _gamepadZoomValue > 0 );
				_gamepadZoomValue = 0;
			}
			else
			{
				_isZooming = false;
			}

			if ( _isZooming )
			{
				// no scrolling when zooming
				return;
			}
			
			if ( Math.abs( _gamepadScrollX ) > 0 || Math.abs( _gamepadScrollY ) > 0 )
			{
				_isScrolling = scrollMap( _gamepadScrollX, _gamepadScrollY );
				_gamepadScrollX = 0;
				_gamepadScrollY = 0;
			}
			else
			{
				_isScrolling = false;
			}

			///////////////////////////////////////
			//
			// PC ONLY
			//
			
			if ( _keyboardZoomIn )
			{
				_isZooming = zoomMap( true );
			}
			else if ( _keyboardZoomOut )
			{
				_isZooming = zoomMap( false );
			}
			else
			{
				_isZooming = false;
			}
			
			if ( _isZooming )
			{
				// no scrolling when zooming
				return;
			}
			
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

				_isScrolling = scrollMap( leftRightScroll, upDownScroll );
			}
			else
			{
				_isScrolling = false;
			}
			
			
			PinPointersManager.getInstance().updatePointersPosition();
			
			
			//
			//
			///////////////////////////////////////
		}
		
		const ZOOM_SPEED:Number = 1.05;
		public function zoomMap( zoomIn : Boolean ) : Boolean
		{
			//
			//trace("Minimap @@@@@@@@@@@@@@@ " + _keyboardZoomIn + " " + _keyboardZoomOut );
			//
			
			
			PinPointersManager.getInstance().updatePointersPosition();
			
			var newScaleX : Number;
			var newScaleY : Number;
			
			if (_transitionTween)
			{
				return false;
			}
			if ( _snapTween2 )
			{
				return false;
			}
			
			if ( _unlimitedZoom )
			{
				if ( zoomIn )
				{
					newScaleX = mcHubMapZoomContainer.actualScaleX * ZOOM_SPEED;
					newScaleY = mcHubMapZoomContainer.actualScaleY * ZOOM_SPEED;
				}
				else
				{
					newScaleX = mcHubMapZoomContainer.actualScaleX / ZOOM_SPEED;
					newScaleY = mcHubMapZoomContainer.actualScaleY / ZOOM_SPEED;
				}
			}
			else
			{
				if ( zoomIn )
				{
					newScaleX = Math.min( mcHubMapZoomContainer.actualScaleX * ZOOM_SPEED, _maxZoom );
					newScaleY = Math.min( mcHubMapZoomContainer.actualScaleY * ZOOM_SPEED, _maxZoom );;
				}
				else
				{
					newScaleX = Math.max( mcHubMapZoomContainer.actualScaleX / ZOOM_SPEED, _minZoom );
					newScaleY = Math.max( mcHubMapZoomContainer.actualScaleY / ZOOM_SPEED, _minZoom );
				}
			}
			
			if ( Math.abs( mcHubMapZoomContainer.scaleX - newScaleX ) < 0.001 && Math.abs( mcHubMapZoomContainer.scaleY - newScaleY ) < 0.001 )
			{
				return false;
			}

			mcHubMapZoomContainer.scaleX = newScaleX;
			mcHubMapZoomContainer.scaleY = newScaleY;
			mcHubMapPinContainer.x = mcHubMapZoomContainer.mcHubMapContainer.x * GetScale();
			mcHubMapPinContainer.y = mcHubMapZoomContainer.mcHubMapContainer.y * GetScale();

			UpdateVisibilityAndPinPositions();
			UpdateSizeForAreaMapPins( GetComponentScale() );
			
			UpdateSelectedMapPin( false );
			updateMapSwitchHint( false );
			UpdateLod();
			
			PinPointersManager.getInstance().updatePointersPosition();
			
			return true;
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetZoom( scaleX );
		}
		
		public function scrollMap( dx : Number, dy : Number ) : Boolean
		{
			// scroll map according to scale
			if ( _snapTween1 )
			{
				return false;
			}
			
			if ( mcHubMapPreview.IsLMBDown() )
			{
				return false;
			}
			
			var scale : Number = GetScale();
			var pX:Number = dx / scale;
			var pY:Number = dy / scale;

			_bufPosX += pX;
			_bufPosY += pY;
			
			var addDist:Number = Math.sqrt(_bufPosX * _bufPosX + _bufPosY * _bufPosY);
			var unSnap:Boolean = addDist > (SNAP_FREE_LIMIT / scale);
			//var unSnap:Boolean = true;
			if (unSnap || (_selectedMapPinIndex == -1) || _ignoreSnapping)
			{
				mcHubMapZoomContainer.mcHubMapContainer.scrollMap(_bufPosX, _bufPosY, _selectedMapPinIndex != -1);
				OnPositionChanged();
				UpdateSelectedMapPin( true );
				_bufPosX = 0;
				_bufPosY = 0;
			}
			_inScroll = true;
			
			PinPointersManager.getInstance().updatePointersPosition();
			
			return true;
			// #Y debug speed params
			//this.parent["debugText"].htmlText = ("Scroll speed: " + Math.round(_scrollCoef * 100) / 100 + "<br/> Scale: " + Math.round(scaleX * 100) / 100 );
		}
		
		protected function UpdateLod( updateTextures : Boolean = true )
		{
			//
			//trace("Minimap @@@@@@@@@@@@@@@@@@@@@@@@ UpdateLod " + updateTextures );
			//
			if ( !_manualLod )
			{
				var requiredLod : int = GetRequiredLod( mcHubMapZoomContainer.actualScaleX );
				if ( requiredLod > 0 )
				{
					mcHubMapZoomContainer.mcHubMapContainer.SwitchToLod( requiredLod, updateTextures );
				}
				else
				{
					if ( updateTextures )
					{
						mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
					}
				}
			}
			else
			{
				mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
			}
		}
		
		protected function GetRequiredLod( zoom : Number ) : int
		{
			var requiredLod : int = -1;
			var currentLod : int =  mcHubMapZoomContainer.mcHubMapContainer.GetCurrentLod();

			//
			//trace("Minimap ---- GetRequiredLod " + currentLod + " " + zoom );
			//
			
			for ( var i : int = 0; i < _zoomBoundaries.length; ++i )
			{
				if ( _zoomBoundaries[ i ].IsValid() && _zoomBoundaries[ i ].IsInside( zoom ) )
				{
					requiredLod = i + 1;
					break;
				}
			}
			
			if ( requiredLod == -1 )
			{
				// no required lod found
				return -1;
			}
			if ( requiredLod == currentLod )
			{
				// nothing to change
				return -1;
			}
			return requiredLod;
		}
		
		protected function updateMapSwitchHint( immediately : Boolean = false )
		{
			//showMapSwitchHint( IsMinZoom() && MapMenu.IsUsingGamepad() );
		}
		
		protected function showMapSwitchHint(value:Boolean):void
		{
			if (showGotoWorldHint != null)
			{
				showGotoWorldHint(value);
			}
		}
		
		public function IsMinZoom() : Boolean
		{
			//var mapSizeInTexels : Number = 2 * _textureSize;
			//return mcHubMapZoomContainer.actualScaleX <= Math.max(stage.stageHeight / mapSizeInTexels, _minZoom );
			return Math.abs( mcHubMapZoomContainer.scaleX - _minZoom ) < 0.001 && Math.abs( mcHubMapZoomContainer.scaleY - _minZoom ) < 0.001;
		}
		
		private function UpdateSizeForAreaMapPins( scale : Number )
		{
			var pin : StaticMapPinDescribed;
			for (var i:uint = 0; i < mcHubMapPinContainer._areaCanvas.numChildren; i++)
			{
				pin = mcHubMapPinContainer._areaCanvas.getChildAt( i ) as StaticMapPinDescribed;
				if ( pin && pin.data && pin.data.radius > 0 )
				{
					var radiusScale : Number = ( pin.data.radius / scale ) * ( 270.0 / _mapSize );

					pin.mcIcon.mcPinRadius.scaleX = radiusScale;
					pin.mcIcon.mcPinRadius.scaleY = radiusScale;
				}
			}
		}
		
		private function UpdateSizeOfPinAvatar( scale : Number )
		{
			var avatarScale : Number = 1.4;
			
			if ( _selectedPinAvatar )
			{
				var selectedPinData : StaticMapPinData = _selectedPinAvatar.data as StaticMapPinData;
				
				if ( !selectedPinData.isPlayer )
				{
					_selectedPinAvatar.scaleX = avatarScale;
					_selectedPinAvatar.scaleY = avatarScale;

					if ( selectedPinData.radius > 0 )
					{
						var radiusScale : Number = ( selectedPinData.radius / scale ) * ( 270.0 / _mapSize ) / avatarScale;

						_selectedPinAvatar.mcIcon.mcPinRadius.scaleX = radiusScale;
						_selectedPinAvatar.mcIcon.mcPinRadius.scaleY = radiusScale;
					}
				}
				
				_selectedPinAvatar.addChild( _selectedPinAvatar.mcDescription );
			}
		}


		private function UpdateSelectedMapPin( softTransition:Boolean = true, allowCenteringOnPin : Boolean = true )
		{
			var pin : StaticMapPinDescribed;

			if ( isAnimationRunning() )
			{
				return;
			}
			
			if ( _closestPinIndex > -1 )
			{
				// there is some pin that needs to be selected
				if ( _selectedMapPinIndex != _closestPinIndex )
				{
					var prevX:Number;
					var prevY:Number;
					// and it's different that currently selected one
					if ( _selectedMapPinIndex > -1 )
					{
						var prevWorldPos : Point = _staticMapPins[_selectedMapPinIndex ].GetWorldPosition();
						prevX = WorldXToMapX( prevWorldPos.x );
						prevY = WorldYToMapY( prevWorldPos.y );

						// so unselect it
						UnselectPin();
					}
					// and select the right one
					SelectPin( _closestPinIndex );
					mcHubMapCrosshair.capturedState = true;
					
					if ( allowCenteringOnPin )
					{
						if ( MapMenu.IsUsingGamepad() )
						{
							CenterOnPin( _closestPinIndex, prevX, prevY, softTransition);
						}
					}
				}
				// otherwise do nothing
			}
			else
			{
				// there is no pin that should be selected
				if ( _selectedMapPinIndex > -1 )
				{
					// but there is one, so unselect him
					UnselectPin()
				}
			}
		}

		private function GetPinIndexByType( type : String ) : int
		{
			for ( var i : int = 0; i < _staticMapPins.length; i++ )
			{
				if ( _staticMapPins[ i ].data.type == type )
				{
					return i;
				}
			}
			return -1;
		}
		
		private function SelectPin( index : int ):void
		{
			if ( _selectedMapPinIndex == index )
			{
				// the same pin, don't select
				return;
			}
			
			if ( index < 0 || index >= _staticMapPins.length )
			{
				// invalid pin index to select
				return;
			}

			// unselect previous pin (don't dispatch context event)
			UnselectPin( false );

			_selectedMapPinIndex = index;
			_bufPosX = 0;
			_bufPosY = 0;

			var currentPin : StaticMapPinDescribed = _staticMapPins[ _selectedMapPinIndex ];
			var currentPinData : StaticMapPinData = currentPin.data as StaticMapPinData;

			// show crosshair label
			mcHubMapCrosshair.showLabel( currentPinData.label, true );

			// manage visibility of selected pin
			
			currentPin.mcIcon.visible = false;
			currentPin.tfLabel.visible = false;

			// create avatar
			var componentScale : Number = GetComponentScale();
			_selectedPinAvatar = new _mapPinClass() as StaticMapPinDescribed;
			_selectedPinAvatar.isAvatar = true;
			_selectedPinAvatar.SetWorldPosition( currentPinData.posX, currentPinData.posY );
			_selectedPinAvatar.setData( currentPinData );
			_selectedPinAvatar.validateNow();			
			
			UpdatePositionOfPinAvatar( GetScale() );
			UpdateSizeOfPinAvatar( GetComponentScale() );
			
			_selectedPinAvatar.UpdateHighlighting();
			
			_selectedPinAvatar.filters = [ new GlowFilter(0, .8, 6, 6, 2, BitmapFilterQuality.HIGH) ];
			if ( currentPinData.rotation )
			{
				_selectedPinAvatar.mcIcon.rotation = currentPinData.rotation;
			}
			else
			{
				_selectedPinAvatar.mcIcon.rotation = 0;
			}
			
			mcHubMapPinContainer._selectedCanvas.addChild(_selectedPinAvatar);
			
			var contextEvent : MapContextEvent = new MapContextEvent( MapContextEvent.CONTEXT_CHANGE );
			contextEvent.active = true;
			contextEvent.mapppinData = currentPinData;
			
			var tooltipData:Object = { };
			tooltipData.title        = currentPinData.label;
			tooltipData.description  = currentPinData.description;
			tooltipData.tracked      = currentPinData.tracked;
			contextEvent.tooltipData = tooltipData;
			dispatchEvent(contextEvent);
		}
		
		private function UnselectPin( dispatchContextEvent : Boolean = true )
		{
			// remove pin avatar if exists
			
			if ( _selectedPinAvatar )
			{
				GTweener.removeTweens( _selectedPinAvatar );
				mcHubMapPinContainer._selectedCanvas.removeChild( _selectedPinAvatar );
				_selectedPinAvatar = null;
			}

			// hide crosshair label
			mcHubMapCrosshair.hideLabel( true );

			// manage visibility of selected pin
			if ( _selectedMapPinIndex >= 0 && _selectedMapPinIndex < _staticMapPins.length )
			{
				var currentPin : StaticMapPinDescribed = _staticMapPins[ _selectedMapPinIndex ];
				
				currentPin.mcIcon.visible = true;
				currentPin.tfLabel.visible = true;
			}

			// do the rest
			_selectedMapPinIndex = -1;
			_scrollCoef = SCROLL_COEF_MIN;
			
			// dispatch event if requested
			if ( dispatchContextEvent )
			{
				var contextEvent : MapContextEvent = new MapContextEvent( MapContextEvent.CONTEXT_CHANGE );
				contextEvent.active = false;
				dispatchEvent( contextEvent );
			}
		}

		private function MapXToWorldX( mapX : Number ) : Number
		{
			var scale : Number = ( 2.0 * _textureSize ) / _mapSize;
			return mapX / scale;
		}

		private function MapYToWorldY( mapY : Number ) : Number
		{
			var scale : Number = ( 2.0 * _textureSize ) / _mapSize;
			return -mapY / scale;
		}

		/*
		private function MapToWorld( mapPos : Point ) : Point
		{
			var scale : Number = ( 2.0 * _textureSize ) / _mapSize;
			return new Point( mapPos.x / scale, -mapPos.y / scale );
		}
		*/

		private function WorldXToMapX( worldX : Number ) : Number
		{
			var scale : Number = ( 2.0 * _textureSize ) / _mapSize;
			return worldX * scale;
		}

		private function WorldYToMapY( worldY : Number ) : Number
		{
			var scale : Number = ( 2.0 * _textureSize ) / _mapSize;
			return -worldY * scale;
		}

		/*
		private function WorldToMap( worldPos : Point ) : Point
		{
			var scale : Number = ( 2.0 * _textureSize ) / _mapSize;
			return new Point( worldPos.x * scale, -worldPos.y * scale );
		}
		*/

		private function CreatePin( staticMapPinData : StaticMapPinData, index : int, pinScale : Number ) : StaticMapPinDescribed
		{
			if ( staticMapPinData.type == "" )
			{
				return null;
			}

			var staticMapPin : StaticMapPinDescribed = new _mapPinClass();

			setupRenderer( staticMapPin );

			staticMapPin.SetWorldPosition( staticMapPinData.posX, staticMapPinData.posY );
			staticMapPin.UpdateMapPosition2( WorldXToMapX( staticMapPinData.posX ) * pinScale, WorldYToMapY( staticMapPinData.posY ) * pinScale );

			staticMapPin.setData( staticMapPinData );
			
			staticMapPin.InitPingAnimation();
			staticMapPin.UpdateHighlighting();

			_staticMapPins[ index ] = staticMapPin;
			staticMapPin.validateNow();
			addPinChild( staticMapPin );
			
			if (staticMapPinData.rotation)
			{
				staticMapPin.mcIcon.rotation = staticMapPinData.rotation;
			}
			else
			{
				staticMapPin.mcIcon.rotation = 0;
			}

			//staticMapPin.filters = [new GlowFilter(0x000000, .5, 4, 4, 2, BitmapFilterQuality.HIGH)];
			
			return staticMapPin;
		}
		
		// #Y Move to the MapMenu.as
		public function UseSelectedPin()
		{
			if ( _selectedMapPinIndex > -1 )
			{
				var pin : StaticMapPinDescribed = _staticMapPins[ _selectedMapPinIndex ];
				if ( pin )
				{
					if ( pin.data.isFastTravel )
					{
						var areaId:int = pin.data.areaId ? pin.data.areaId : -1;
						dispatchEvent( new GameEvent(GameEvent.CALL, "OnStaticMapPinUsed", [ pin.data.id,  areaId] ) );
					}
				}
			}
		}
		
		private function addPinChild(targetPin : StaticMapPinDescribed):void
		{
			if (targetPin)
			{
				var pinData : StaticMapPinData = targetPin.data as StaticMapPinData;
				var targetCanvas : Sprite = mcHubMapPinContainer.getPinCanvas( pinData );
				targetCanvas.addChild(targetPin);
			}
		}
		
		private function removePinChild(targetPin : StaticMapPinDescribed):void
		{
			if (targetPin)
			{
				var pinData : StaticMapPinData = targetPin.data as StaticMapPinData;
				var targetCanvas : Sprite = mcHubMapPinContainer.getPinCanvas( pinData );
				targetCanvas.removeChild(targetPin);
			}
		}
		
		public function RemoveUserMapPin( id : uint )
		{
			for ( var i : int = _staticMapPins.length - 1; i >= 0; i-- )
			{
				if ( _staticMapPins[ i ].data.isUserPin )
				{
					if ( _staticMapPins[ i ].data.id == id )
					{
						mcHubMapPreview.removePin( id );

						UnselectPin();

						removePinChild( _staticMapPins[ i ] );
						_staticMapPins.splice( i, 1 );

						UpdateVisibilityAndPinPositions( false );
						UpdateSelectedMapPin( false );

						return;
					}
				}
			}
		}

		private var _animationTween : GTween;
		private const ANIMATION_INTERVAL : Number = 0.25;
		
		private function CenterOnPosition( posX : Number, posY : Number, animate : Boolean = false )
		{
			if ( isAnimationRunning() )
			{
				return;
			}
			if ( animate )
			{
				var restrictedX : Number = mcHubMapZoomContainer.mcHubMapContainer.GetRestrictedX( posX );
				var restrictedY : Number = mcHubMapZoomContainer.mcHubMapContainer.GetRestrictedY( posY );
				
				_animationTween = GTweener.to( mcHubMapZoomContainer.mcHubMapContainer, ANIMATION_INTERVAL, { x : restrictedX, y : restrictedY }, { ease:Sine.easeInOut, onChange : handleTransitionChange, onComplete : handleTransitionComplete } );
			}
			else
			{
				mcHubMapZoomContainer.mcHubMapContainer.setImmediatePosition( posX, posY );
			}
				
			OnPositionChanged();
			mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
		}

		protected function handleTransitionChange( tween : GTween )
		{
			OnPositionChanged();
			mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
		}
		
		protected function handleTransitionComplete( tween : GTween )
		{
			OnPositionChanged();
			mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();

			_animationTween.end();
			_animationTween = null;

			UpdateSelectedMapPin( true, false );
		}
		
		public function isAnimationRunning() : Boolean
		{
			return _animationTween != null;
		}
		
		private function CenterOnTheMiddleOfTheMap()
		{
			mcHubMapZoomContainer.mcHubMapContainer.x = 0;
			mcHubMapZoomContainer.mcHubMapContainer.y = 0;
			
			OnPositionChanged();
			mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetScroll( mcHubMapContainer.x, mcHubMapContainer.y );
		}
		
		public function IsPlayerPinExist() : Boolean
		{
			return _playerPinIdx > -1;
		}
		
		public function IsCenteredOnPlayerPin() : Boolean
		{
			if ( _playerPinIdx > -1 )
			{
				return IsCenteredOnPin( _playerPinIdx );
			}
			return false;
		}
		
		public function CenterOnPlayer(transitionAnim:Boolean = false, doNotSelect : Boolean = false) : Boolean
		{
			if ( _playerPinIdx > -1 )
			{
				CenterOnPin( _playerPinIdx, NaN, NaN, transitionAnim, doNotSelect);
				return true;
			}
			return false;
		}
		
		public function IsQuestPinExist() : Boolean
		{
			return _questMapPinIndices.length > 0;
		}
		
		public function IsCenteredOnQuestPin() : Boolean
		{
			if ( _questMapPinIndices.length > 0 )
			{
				return IsCenteredOnPin( _questMapPinIndices[ 0 ] );
			}
			return false;
		}
		
		public function CenterOnQuest(transitionAnim:Boolean = false, doNotSelect : Boolean = false) :	Boolean
		{
			if ( _questMapPinIndices.length > 0 )
			{
				//
				//trace("Minimap ======================== CenterOnQuest " + transitionAnim );
				//
				CenterOnPin( _questMapPinIndices[ 0 ], NaN, NaN, transitionAnim, doNotSelect);
				return true;
			}
			return false;
		}
		
		private function IsCenteredOnPin( pinIndex : int ) : Boolean
		{
			if ( pinIndex < 0 || pinIndex >= _staticMapPins.length )
			{
				return false;
			}

			var worldPos : Point = _staticMapPins[ pinIndex ].GetWorldPosition();
			var p1x : Number = -WorldXToMapX( worldPos.x );
			var p1y : Number = -WorldYToMapY( worldPos.y );
			var p2x : Number = mcHubMapZoomContainer.mcHubMapContainer.x;
			var p2y : Number = mcHubMapZoomContainer.mcHubMapContainer.y;
			
			return Math.pow( p2x - p1x, 2 ) + Math.pow( p2y - p1y, 2 ) < 0.01;
		}
		
		const ANIM_SPEED:Number = .01;
		public function CenterOnPin( pinIndex : int, prevX:Number = NaN, prevY:Number = NaN, transitionAnim:Boolean = true, doNotSelect : Boolean = false)
		{
			if ( pinIndex < 0 || pinIndex >= _staticMapPins.length )
			{
				return;
			}
			var worldPos : Point = _staticMapPins[ pinIndex ].GetWorldPosition();
			var targetX = -WorldXToMapX( worldPos.x );
			var targetY = -WorldYToMapY( worldPos.y );
			//var targetX = -_staticMapPins[ pinIndex ].x;
			//var targetY = -_staticMapPins[ pinIndex ].y;
			if ( !isNaN(prevX) && !isNaN(prevY) )
			{
				mcHubMapZoomContainer.mcHubMapContainer.x = - prevX;
				mcHubMapZoomContainer.mcHubMapContainer.y = - prevY;
				
				OnPositionChanged();
			}
			if ( transitionAnim )
			{
				mcHubMapCrosshair.capturedState = false;
				
				if (!_ignoreSnapping)
				{
					GTweener.removeTweens(mcHubMapZoomContainer.mcHubMapContainer);
					_snapTween1 = GTweener.to( mcHubMapZoomContainer.mcHubMapContainer, .3, { x :targetX, y:targetY }, { onComplete:handleSnapTween1Complete, data: { pinIdx:pinIndex } } );
					
					GTweener.removeTweens( mcHubMapPinContainer );
					_snapTween2 = GTweener.to( mcHubMapPinContainer, .3, { x :targetX * GetScale(), y:targetY * GetScale() }, { onComplete:handleSnap2TweenComplete } );
				}
				else
				{
					mcHubMapZoomContainer.mcHubMapContainer.x = targetX;
					mcHubMapZoomContainer.mcHubMapContainer.y = targetY;
					handleSnapTween1Complete(new GTween(null, 1, null, { data: { pinIdx:pinIndex }  } ));
					
					mcHubMapPinContainer.mcHubMapContainer.x = targetX;
					mcHubMapPinContainer.mcHubMapContainer.y = targetY;				
					handleSnap2TweenComplete();
				}
				
			}
			else
			{
				mcHubMapZoomContainer.mcHubMapContainer.x = targetX;
				mcHubMapZoomContainer.mcHubMapContainer.y = targetY;
				
				OnPositionChanged();
				if ( _menuAnimCompleted )
				{
					mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
				}
				
				if (_selectedMapPinIndex != -1)
				{
					UnselectPin();
				}
				if ( !doNotSelect )
				{
					SelectPin( pinIndex );
				}
			}
			_scrollCoef = SCROLL_COEF_MIN;
			
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetScroll( mcHubMapContainer.x, mcHubMapContainer.y );
		}
		
		protected function handleSnapTween1Complete(tweenInstance:GTween):void
		{
			SelectPin( tweenInstance.data.pinIdx );
			_snapTween1 = null;
			_snapTween2 = null;
			
			OnPositionChanged();
			mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
		}
		
		protected function handleSnap2TweenComplete(tweenInstance:GTween = null):void
		{
			_snapTween2 = null;
		}

		protected function setupRenderer( renderer : IListItemRenderer )
		{
            renderer.owner = this;
			renderer.focusTarget = this;
			renderer.tabEnabled = false; // Children can still be tabEnabled, or the renderer could re-enable this. //LM: There is an issue with this. Setting disabled could automatically re-enable. Consider alternatives.
            renderer.doubleClickEnabled = true;
			UIComponent(renderer).visible = true;
        }

        protected function cleanUpRenderer( renderer : IListItemRenderer )
		{
            renderer.owner = null;
            renderer.focusTarget = null;
            // renderer.tabEnabled = true;
            renderer.doubleClickEnabled = false;
        }
		
		private function StartInitialTimer()
		{
			//
			//trace("Minimap HubMap::StartInitialTimer");
			//
			StopInitialTimer();

			_initialTimer = new Timer( 20 );
			_initialTimer.addEventListener(TimerEvent.TIMER, handleInitialTimer, false, 0, true);
			_initialTimer.start();
			
			_mapPinDataIndex = -1;
		}
		
		private function StopInitialTimer()
		{
			if ( _initialTimer )
			{
				//
				//trace("Minimap HubMap::StopInitialTimer");
				//
				_initialTimer.removeEventListener(TimerEvent.TIMER, handleInitialTimer);
				_initialTimer.stop();
				_initialTimer = null;
			}
		}
		
		protected function handleInitialTimer(event:TimerEvent):void
		{
			//
			//trace("Minimap HubMap::handleInitialTimer " + _initialTimer.currentCount + " / " + _initialTimer.repeatCount );
			//

			if ( _menuAnimCompleted )
			{
				//
				//trace("Minimap ------------------------ |||||||||||||||||||||||||||||||||||||||||||| _menuAnimCompleted" );
				//

				if ( _mapPinDataIndex == -1 )
				{
					initializeMapPinsProcessing();
				}
				
				if ( processMapPins() )
				{
					finalizeMapPinsProcessing();

					StopInitialTimer();
				
					StartShowTimer();
					StartUpdateTexturesTimer();
				
					UpdateVisibilityAndPinPositions();
					mcHubMapZoomContainer.mcHubMapContainer.ShowTilesFromCurrentLod();
				}
			}
		}
		
		private function StartShowTimer()
		{
			//
			//trace("Minimap HubMap::StartShowTimer");
			//
			StopShowTimer();
			
			_showMapTimer = new Timer( SHOW_INTERVAL );
			_showMapTimer.addEventListener(TimerEvent.TIMER, handleShowTimer, false, 0, true);
			_showMapTimer.start();
		}

		private function StopShowTimer()
		{
			if ( _showMapTimer )
			{
				//
				//trace("Minimap HubMap::StopShowTimer");
				//

				_showMapTimer.removeEventListener(TimerEvent.TIMER, handleShowTimer);
				_showMapTimer.stop();
				_showMapTimer = null;
			}
		}

		private function handleShowTimer(event:TimerEvent):void
		{
			//
			//trace("Minimap HubMap::handleShowTimer");
			//
			StopShowTimer();
			_fadingInCompleted = false;

			mcHubMapZoomContainer.mcHubMapContainer.mcGradientContainer.alpha = 0;
			GTweener.removeTweens( mcHubMapZoomContainer.mcHubMapContainer.mcGradientContainer);
			GTweener.to( mcHubMapZoomContainer.mcHubMapContainer.mcGradientContainer, FADING_GRADIENT_DURATION, { alpha:1 }, { ease:Sine.easeIn } );

			mcHubMapZoomContainer.mcHubMapContainer.mcLodContainer.alpha = 0;
			GTweener.removeTweens( mcHubMapZoomContainer.mcHubMapContainer.mcLodContainer);
			GTweener.to( mcHubMapZoomContainer.mcHubMapContainer.mcLodContainer, FADING_TEXTURES_DURATION, { alpha:1 }, { ease:Sine.easeIn, onComplete:handleFadingInEnded } );

			mcHubMapPinContainer.alpha = 0;
			GTweener.removeTweens( mcHubMapPinContainer );
			GTweener.to( mcHubMapPinContainer, FADING_GRADIENT_DURATION, { alpha:1 }, { ease:Sine.easeIn } );
		}
		
		protected function handleFadingInEnded(tweenInstance:GTween = null):void
		{
			_fadingInCompleted = true;
			
			if ( funcEnableCategoryPanel != null )
			{
				funcEnableCategoryPanel( true );
			}
			if ( funcEnableQuestTracker != null )
			{
				funcEnableQuestTracker( true );
			}

			//
			//trace("Minimap handleFadingInEnded " + _fadingInCompleted);
			//
		}

		private function StartUpdateTexturesTimer()
		{
			//
			//trace("Minimap HubMap::StartUpdateTexturesTimer");
			//
			StopUpdateTexturesTimer();

			// entering the same map
			handleUpdateTexturesTimer( null );
			
			_updateTexturesTimer = new Timer( UPDATE_HUB_TEXTURES_INTERVAL, 0 );
			_updateTexturesTimer.addEventListener(TimerEvent.TIMER, handleUpdateTexturesTimer, false, 0, true);
			_updateTexturesTimer.start();
		}
		
		private function StopUpdateTexturesTimer()
		{
			if ( _updateTexturesTimer )
			{
				//
				//trace("Minimap HubMap::StopUpdateTexturesTimer");
				//

				_updateTexturesTimer.removeEventListener(TimerEvent.TIMER, handleUpdateTexturesTimer);
				_updateTexturesTimer.stop();
				_updateTexturesTimer = null;
			}
		}
		
		protected function handleUpdateTexturesTimer( event:TimerEvent ):void
		{
			//
			//trace("Minimap HubMap::handleUpdateTexturesTimer");
			//
			mcHubMapZoomContainer.mcHubMapContainer.ProcessHidingTiles( UPDATE_HUB_TEXTURES_INTERVAL );
		}
		
		private function OnPositionChanged()
		{
			//
			//trace("Minimap !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! OnPositionChanged !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			//
			
			mcHubMapPinContainer.x = mcHubMapZoomContainer.mcHubMapContainer.x * GetScale();
			mcHubMapPinContainer.y = mcHubMapZoomContainer.mcHubMapContainer.y * GetScale();
			
			//
			//trace("Minimap ------------------------ OnPositionChanged" );
			//
			
			UpdateVisibilityAndPinPositions( false );
			UpdateSizeForAreaMapPins( GetComponentScale() );
			
			UpdateGotoButton( false );
		}
		
		public function UpdateGotoButton( checkGamepad )
		{
			if ( !checkGamepad )
			{
				if ( MapMenu.IsUsingGamepad() )
				{
					return
				}
			}
			
			var foundIndex : int = GetNextPinIndexToShow();
			if ( foundIndex == -1 )
			{
				showGotoPlayerPin( false );
				showGotoQuestPin( false );
				InputFeedbackManager.updateButtons(this);
			}
			else
			{
				var type : String = _staticMapPins[ foundIndex ].data.type;
				if ( type == "Player" )
				{
					showGotoPlayerPin( true );
					showGotoQuestPin( false );
					InputFeedbackManager.updateButtons(this);
				}
				else
				{
					showGotoPlayerPin( false );
					showGotoQuestPin( true );
					InputFeedbackManager.updateButtons(this);
				}
			}
		}
		
		private function UpdateVisibilityAndPinPositions( updatePinPositions : Boolean = true )
		{
			var pin : StaticMapPinDescribed;
			var pinWorldPos : Point;
			var pinScale = GetScale();

			mcHubMapZoomContainer.mcHubMapContainer.UpdateVisibileArea();
			
			_worldLeftBottom.x = MapXToWorldX( mcHubMapZoomContainer.mcHubMapContainer.GetVisibleAreaLocalLeftBottomPos().x );
			_worldLeftBottom.y = MapYToWorldY( mcHubMapZoomContainer.mcHubMapContainer.GetVisibleAreaLocalLeftBottomPos().y );
			_worldRightTop.x   = MapXToWorldX( mcHubMapZoomContainer.mcHubMapContainer.GetVisibleAreaLocalRightTopPos().x );
			_worldRightTop.y   = MapYToWorldY( mcHubMapZoomContainer.mcHubMapContainer.GetVisibleAreaLocalRightTopPos().y );

			//
			//trace("Minimap ------------------------ UpdateVisibilityAndPinPositions" );
			//trace("Minimap LEFT TOP     [" + worldLeftBottom.x + " " + worldLeftBottom.y + "]" );
			//trace("Minimap RIGHT BOTTOM [" + worldRightTop.x   + " " + worldRightTop.y   + "]" );
			//
		
			var globalCrosshairPosition;
			if ( MapMenu.IsUsingGamepad() )
			{
				globalCrosshairPosition = localToGlobal( POINT_0_0 );
			}
			else
			{
				globalCrosshairPosition = MapMenu.GetCurrGlobalMousePos();
			}
			
			var globalPinPosition : Point;
			var currentPinDistanceSquared : Number;
			var closestPinDistanceSquared : Number = 1000000;

			// clear closest pin index
			_closestPinIndex = -1;

			for ( var i : int = _staticMapPins.length - 1; i >= 0; --i )
			{
				pin = _staticMapPins[ i ] as StaticMapPinDescribed;
				if ( !pin )
				{
					continue;
				}

				pinWorldPos = pin.GetWorldPosition();
				
				if ( updatePinPositions )
				{
					pin.UpdateMapPosition2( WorldXToMapX( pinWorldPos.x ) * pinScale, WorldYToMapY( pinWorldPos.y ) * pinScale );
				}

				if ( pinWorldPos.x >= _worldLeftBottom.x && pinWorldPos.x <= _worldRightTop.x &&
					 pinWorldPos.y >= _worldLeftBottom.y && pinWorldPos.y <= _worldRightTop.y )
				{
					pin.SetVisibleInArea( true );
					
					globalPinPosition = pin.localToGlobal( POINT_0_0 );
					currentPinDistanceSquared = Math2.getSquaredSegmentLength( globalCrosshairPosition, globalPinPosition );
					
					if ( !pin.isHidden() )
					{
						if ( _closestPinIndex == -1 || closestPinDistanceSquared > currentPinDistanceSquared || ( closestPinDistanceSquared == currentPinDistanceSquared && pin.data.isFastTravel ) )
						{
							if ( currentPinDistanceSquared < SNAP_DISTANCE_SQUARED && !_ignoreSnapping)
							{
								_closestPinIndex = i;
								closestPinDistanceSquared = currentPinDistanceSquared;
							}
						}
					}
				}
				else
				{
					pin.SetVisibleInArea( false );
				}
			}
			
			UpdatePositionOfPinAvatar( pinScale );
			UpdateSizeOfPinAvatar( GetComponentScale() );
			
			if ( mcHubMapPreview.CanBeToggled() )
			{
				mcHubMapPreview.updateVisibleFramePosition( _worldLeftBottom, _worldRightTop );
			}
		}
		
		private function UpdatePositionOfPinAvatar( scale : Number )
		{
			if ( _selectedPinAvatar )
			{
				var worldPos : Point = _selectedPinAvatar.GetWorldPosition();
				_selectedPinAvatar.UpdateMapPosition2( WorldXToMapX( worldPos.x ) * scale, WorldYToMapY( worldPos.y ) * scale );
			}
		}
		
		public function setUserMapPin( index : int, fromSelectionPanel : Boolean )
		{
			var worldPositionForUserPin : Point = getWorldPositionFromCursor();

			dispatchEvent( new GameEvent(GameEvent.CALL, "OnUserMapPinSet", [ worldPositionForUserPin.x, worldPositionForUserPin.y, index, fromSelectionPanel ] ) );
		}
		
		public function getWorldPositionFromCursor() : Point
		{
			if ( _selectedMapPinIndex > 0 )
			{
				var worldPos : Point = _staticMapPins[ _selectedMapPinIndex ].GetWorldPosition();
				return new Point( worldPos.x, worldPos.y );
			}
			var mapPos : Point = new Point( -mcHubMapZoomContainer.mcHubMapContainer.x + mcHubMapCrosshair.x / GetScale(), -mcHubMapZoomContainer.mcHubMapContainer.y + mcHubMapCrosshair.y / GetScale() );
			return new Point( MapXToWorldX( mapPos.x ), MapYToWorldY( mapPos.y ) );
		}

		private function CenterBetweenQuestAndPlayer()
		{
			var foundIndex : int = -1;
			
			foundIndex = GetNextPinIndexToShow();
			if ( foundIndex != -1 )
			{
				CenterOnPin( foundIndex, NaN, NaN, false, false );
				if ( !MapMenu.IsUsingGamepad() )
				{
					// I don't remember why, but this needs to be here
					UpdateSelectedMapPin( false );
				}
			}
		}
		
		private function GetNextPinIndexToShow() : int
		{
			var i, j : int;
			var indices : Vector.< int > = new Vector.< int >;
			var foundIndex : int = -1;

			for ( i = 0; i < _questMapPinIndices.length; ++i )
			{
				// check positions one by one
				var currentIndex : int = _questMapPinIndices[ i ];
				var currentPos : Point = _staticMapPins[ currentIndex ].GetWorldPosition();
				var samePosFound : Boolean = false;
				for ( j = 0; j < indices.length; ++j )
				{
					var othertIndex : int = indices[ j ];
					var otherPos : Point = _staticMapPins[ othertIndex ].GetWorldPosition();
					if ( currentPos.equals( otherPos ) )
					{
						samePosFound = true;
						break;
					}
				}
				
				if ( !samePosFound )
				{
					indices[ indices.length ] = _questMapPinIndices[ i ];
				}
			}
			if ( _playerPinIdx != -1 )
			{
				indices.unshift( _playerPinIdx );
			}

			if ( MapMenu.IsUsingGamepad() )
			{
				for ( i = 0; i < indices.length; ++i )
				{
					if ( indices[ i ] == _selectedMapPinIndex )
					{
						foundIndex = i;
						break;
					}
				}

				if ( foundIndex == -1 )
				{
					if ( indices.length > 0 )
					{
						foundIndex = indices[ 0 ];
					}
				}
				else
				{
					foundIndex = indices[ ( foundIndex + 1 ) % indices.length ];
				}
			}
			else
			{
				for ( i = 0; i < indices.length; ++i )
				{
					if ( IsCenteredOnPin( indices[ i ] ) )
					{
						foundIndex = i;
						break;
					}
				}

				if ( foundIndex == -1 )
				{
					if ( indices.length > 0 )
					{
						foundIndex = indices[ 0 ];
					}
				}
				else
				{
					foundIndex = indices[ ( foundIndex + 1 ) % indices.length ];
				}
			}
			
			return foundIndex;
		}
	}
}
