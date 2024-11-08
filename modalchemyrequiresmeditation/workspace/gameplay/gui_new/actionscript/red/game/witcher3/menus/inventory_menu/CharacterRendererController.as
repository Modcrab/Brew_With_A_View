package red.game.witcher3.menus.inventory_menu
{
	import com.gskinner.geom.ColorMatrix;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CursorType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * @author Getsevich Yaroslav
	 * For new Inventory prototype
	 */
	public class CharacterRendererController
	{
		static protected const DEFAULT_ANIMATION_DURATION:Number = 0.5;
		
		static protected const DEFAULT_ENTITY_POS_Y:Number = 1;
		static protected const DEFAULT_ENTITY_ROTATION_Y:Number = 190.71;
		static protected const DEFAULT_ENTITY_SCALE:Number = 3.35;
		
		static protected const CENTERED_ENTITY_POS_Y:Number = 1;
		static protected const CENTERED_ENTITY_ROTATION_Y:Number = 160;
		static protected const CENTERED_ENTITY_SCALE:Number = 3.35;
		
		static protected const MAX_SCALE:Number = 4;
		static protected const MIN_SCALE:Number = 3;
		static protected const MIN_PAN_Y:Number = .5;
		static protected const MAX_PAN_Y:Number = 1.5;
		
		static protected const AXIS_ROTATE_MULT:Number = 2;
		static protected const AXIS_SCALE_MULT:Number = .2;
		static protected const AXIS_MOVE_MULT:Number = .2;
		static protected const AXIS_DEAD_ZONE:Number = .05;
		
		protected var _rendererSprite:MovieClip;
		protected var _defaultPosition:Point;
		protected var _centerPosition:Point;
		protected var _animationTime:Number;
		
		protected var _fadeOutComponents:Vector.<MovieClip>;
		protected var _fadeInComponent:Vector.<MovieClip>;
		
		protected var _currentRotationY:Number = 0;
		protected var _currentPositionY:Number = 0;
		protected var _currentScale:Number = 1;
		
		protected var _targetRotationY:Number = 0;
		protected var _targetPositionY:Number = 0;
		protected var _targetScale:Number = 1;
		
		protected var _deltaRotationY:Number = 0;
		protected var _deltaPositionY:Number = 0;
		protected var _deltaScale:Number = 1;
		
		protected var _timeStamp:int;
		
		protected var _isCentered:Boolean = false;
		protected var _isInTransitionToCenter:Boolean = false;
		protected var _isInTransitionToDefault:Boolean = false;
		
		// INFO PANELS
		protected static const HIDE_INFO_DELAY:Number = 100;
		protected static const SHOW_INFO_DELAY:Number = 600	;
		protected static const FADE_OUT_ALPHA = .3;
		protected static const FADE_OUT_X_OFFSET = 5;
		
		protected var _hideInfoTimer:Timer;
		protected var _showInfoTimer:Timer;
		
		protected var _leftInfoPanelX:Number = 0;
		protected var _rightInfoPanelX:Number = 1420;
		
		protected var _leftInfoPanel:PlayerGeneralStatsPanel;
		protected var _rightInfoPanel:PlayerDetailedStatsPanel;
		
		protected var _enabled:Boolean = true;
		
		private var _btn_navigate:int = -1;
		private var _btn_rotate_gamepad:int = -1;
		private var _btn_rotate_mouse:int = -1;
		private var _btn_zoom:int = -1;
		private var _btn_pan_gamepad:int = -1;
		private var _btn_pan_mouse:int = -1;
		
		private var _mouseHitArea:Sprite;
		private var _menuRef:CoreMenu;
		
		public var inputDisabled:Boolean;
		
		public function isActive():Boolean
		{
			return _isInTransitionToCenter || _isInTransitionToDefault || _isCentered;
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			if (_enabled != value)
			{
				_enabled = value;
				
				if (!enabled && isCentered())
				{
					moveToDefault();
				}
			}
		}
		
		public function get leftInfoPanel():PlayerGeneralStatsPanel { return _leftInfoPanel }
		public function set leftInfoPanel(value:PlayerGeneralStatsPanel)
		{
			_leftInfoPanel = value;
			
			if (_leftInfoPanel)
			{
				_leftInfoPanel.visible = false;
				_leftInfoPanelX = _leftInfoPanel.x;
				_leftInfoPanel.x = _leftInfoPanelX - FADE_OUT_X_OFFSET;
				//_leftInfoPanel.scaleX = _leftInfoPanel.scaleY;
				
				_leftInfoPanel.mcStatsList.bSkipFocusCheck = true;
				_leftInfoPanel.mcStatsList.focusable = false;
				_leftInfoPanel.mcStatsList.selectOnOver = true;
				
				if (_rightInfoPanel)
				{
					_leftInfoPanel.dataSetterDelegate = _rightInfoPanel.setData;
				}
			}
		}
		
		
		public function get rightInfoPanel():PlayerDetailedStatsPanel { return _rightInfoPanel }
		public function set rightInfoPanel(value:PlayerDetailedStatsPanel)
		{
			_rightInfoPanel = value;
			
			if (_rightInfoPanel)
			{
				_rightInfoPanel.visible = false;
				_rightInfoPanelX = _rightInfoPanel.x;
				_rightInfoPanel.x = _rightInfoPanelX + FADE_OUT_X_OFFSET;
				//_rightInfoPanel.scaleX = _rightInfoPanel.scaleY;
				
				if (_leftInfoPanel)
				{
					_leftInfoPanel.dataSetterDelegate = _rightInfoPanel.setData;
				}
			}
		}
		
		public function CharacterRendererController(target:MovieClip, menuRef:CoreMenu):void
		{
			_fadeOutComponents = new Vector.<MovieClip>;
			
			_menuRef = menuRef;
			_animationTime = DEFAULT_ANIMATION_DURATION;
			
			_currentRotationY = _targetRotationY = DEFAULT_ENTITY_ROTATION_Y;
			_currentPositionY = _targetPositionY = DEFAULT_ENTITY_POS_Y;
			_currentScale = _targetScale = DEFAULT_ENTITY_SCALE;
			
			var inptDelegate:InputDelegate = InputDelegate.getInstance();
			
			_rendererSprite = target;
			
			if (_rendererSprite)
			{
				_rendererSprite.stage.removeEventListener(InputEvent.INPUT, handleInput, false);
				_rendererSprite.stage.addEventListener(InputEvent.INPUT, handleInput, false, 9, true);
			}
			
			_mouseHitArea = CommonUtils.createSolidColorSprite(new Rectangle(0, 1, 600, 1080), 0xFF0000, 0);
			addMouseEvents(_mouseHitArea);
			
			_rendererSprite.dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.player.stats", [setPlayerStats] ) );
		}
		
		private function addMouseEvents(target:Sprite):void
		{
			target.doubleClickEnabled = true;
			target.addEventListener(MouseEvent.DOUBLE_CLICK, handleMouseDoubleClick, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OUT, handleMouseRollOut, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver, false, 0, true);
			
			_rendererSprite.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			_rendererSprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMouse, false, 0, true);
		}
		
		private function removeMouseEvents(target:Sprite):void
		{
			target.removeEventListener(MouseEvent.DOUBLE_CLICK, handleMouseDoubleClick, false);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
			target.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false);
			target.removeEventListener(MouseEvent.ROLL_OUT, handleMouseRollOut, false);
			target.removeEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver, false);
			
			_rendererSprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMouse, false);
			_rendererSprite.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false);
		}
		
		public function addFadeOutComponent(target:Sprite):void
		{
			_fadeOutComponents.push(target);
		}
		
		public function setDefaultAnchor(ax:Number, ay:Number):void	{ _defaultPosition = new Point(ax, ay); }
		public function setCenterAnchor(ax:Number, ay:Number):void	{ _centerPosition = new Point(ax, ay);	}
		public function isCentered():Boolean						{ return _isCentered; }
		
		public function moveToCenter():void
		{
			trace("GFX <CharacterRendererController>  ***moveToCenter*** _isCentered: ", _isCentered);
			
			_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestStatsData', [] ));
		}
		
		private function setPlayerStats(statsData:Object):void
		{
			trace("GFX <CharacterRendererController>  ***setPlayerStats*** ");
			
			
			var aValues:Object = { alpha:1, x:_centerPosition.x, y:_centerPosition.y };
			var target_speed:Number = Math.abs(_centerPosition.x - _rendererSprite.x) * _animationTime / 1000; // time in seconds
			
			resetsTweens();
			
			GTweener.removeTweens(_rendererSprite);
			GTweener.to(_rendererSprite, _animationTime, aValues, { onComplete:onFadeOutComplete, ease:Sine.easeOut } );
			
			GTweener.removeTweens(_rightInfoPanel);
			GTweener.removeTweens(_leftInfoPanel);
			GTweener.to(_rightInfoPanel, _animationTime, { x: _rightInfoPanelX, /*scaleX:1, scaleY:1,*/ alpha:1 }, { ease:Sine.easeOut } );
			GTweener.to(_leftInfoPanel, _animationTime, { x: _leftInfoPanelX, /*scaleX:1, scaleY:1,*/ alpha:1 }, { ease:Sine.easeOut } );
			
			_rightInfoPanel.visible = true;
			_leftInfoPanel.visible = true;
			
			_fadeOutComponents.forEach(fadeOutObj);
			_isInTransitionToDefault = false;
			_isInTransitionToCenter = true;
			
			leftInfoPanel.data = statsData.stats;
			leftInfoPanel.focused = 1;
			rightInfoPanel.setTimeData(statsData.hoursPlayed, statsData.minutesPlayed);
			
			_rendererSprite.dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", [ "gui_ep2_character_submenu_in" ] ) );
		}
		
		public function moveToDefault():void
		{
			trace("GFX <CharacterRendererController> ***moveToDefault*** _isCentered: ", _isCentered);
			
			resetsTweens();
			
			var aValues:Object = { alpha:1, x:_defaultPosition.x, y:_defaultPosition.y };
			var target_speed:Number = Math.abs(_defaultPosition.x - _rendererSprite.x) * _animationTime / 1000; // time in seconds
			
			GTweener.removeTweens(_rendererSprite);
			GTweener.to(_rendererSprite, _animationTime, aValues, { onComplete:onFadeInComplete, ease:Sine.easeOut } );
			
			GTweener.removeTweens(_rightInfoPanel);
			GTweener.removeTweens(_leftInfoPanel);
			GTweener.to(_rightInfoPanel, _animationTime, { x: _rightInfoPanelX + FADE_OUT_X_OFFSET, /*scaleX:1, scaleY:1,*/ alpha:0 }, { ease:Sine.easeOut } );
			GTweener.to(_leftInfoPanel, _animationTime, { x: _leftInfoPanelX - FADE_OUT_X_OFFSET, /*scaleX:1, scaleY:1,*/ alpha:0 }, { ease:Sine.easeOut } );
			
			_fadeOutComponents.forEach(fadeInObj);
			_isInTransitionToDefault = true;
			_isInTransitionToCenter = false;
			
			_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnResetPlayerPosition', [] ));
			
			// reset
			resetCursorType();
			isDraggingMode = false;
			isPanningMode = false;
			_leftInfoPanel.enabled = _leftInfoPanel.mouseChildren = _leftInfoPanel.mouseEnabled = true;
			_menuRef.setMouseCursorVisibility(true);
			
			_rendererSprite.dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", [ "gui_ep2_character_submenu_out" ] ) );
		}
		
		private function onFadeOutComplete(tw:GTween = null):void
		{
			trace("GFX <CharacterRendererController> onFadeOutComplete");
			
			_holdReceived = false;
			_isInTransitionToCenter = false;
			_isInTransitionToDefault = false;
			_isCentered = true;
			
			_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlayerStatsShown', [] ));
			
			_rendererSprite.parent.addChild( _mouseHitArea );
			_mouseHitArea.x = ( CommonUtils.getScreenRect().width - _mouseHitArea.width ) / 2;
			_mouseHitArea.y = 100; // hardcoded offset
		}
		
		private function onFadeInComplete(tw:GTween = null):void
		{
			trace("GFX <CharacterRendererController> onFadeInComplete");
			
			_holdReceived = false;
			_isInTransitionToCenter = false;
			_isInTransitionToDefault = false;
			_isCentered = false;
			
			_rightInfoPanel.visible = false;
			_leftInfoPanel.visible = false;
			
			_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlayerStatsHidden', [] ));
			
			_rendererSprite.parent.removeChild( _mouseHitArea );
		}
		
		private function activate():void
		{
			if (_btn_navigate == -1) _btn_navigate = InputFeedbackManager.appendButton(_rendererSprite, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
			if (_btn_rotate_gamepad == -1) _btn_rotate_gamepad = InputFeedbackManager.appendButton(_rendererSprite, NavigationCode.GAMEPAD_RSTICK_TAB, -1, "panel_button_common_rotate");
			if (_btn_rotate_mouse == -1) _btn_rotate_mouse = InputFeedbackManager.appendButton(_rendererSprite, "", KeyCode.LEFT_MOUSE, "panel_button_common_rotate", true);
			if (_btn_zoom == -1) _btn_zoom = InputFeedbackManager.appendButton(_rendererSprite, NavigationCode.GAMEPAD_RSTICK_SCROLL, -1, "panel_button_common_zoom");
			if (_btn_pan_gamepad == -1) _btn_pan_gamepad = InputFeedbackManager.appendButton(_rendererSprite, NavigationCode.DPAD_UP_DOWN, -1, "input_navigation_pan_model");
			if (_btn_pan_mouse == -1) _btn_pan_mouse = InputFeedbackManager.appendButton(_rendererSprite, "", KeyCode.RIGHT_MOUSE, "input_navigation_pan_model",true);
			
			_rendererSprite.dispatchEvent(new Event(Event.ACTIVATE));
		}
		
		private function deactivate():void
		{
			if (_btn_rotate_gamepad != -1) InputFeedbackManager.removeButton(_rendererSprite, _btn_rotate_gamepad);
			if (_btn_rotate_mouse != -1) InputFeedbackManager.removeButton(_rendererSprite, _btn_rotate_mouse);
			if (_btn_navigate != -1) InputFeedbackManager.removeButton(_rendererSprite, _btn_navigate);
			if (_btn_zoom != -1) InputFeedbackManager.removeButton(_rendererSprite, _btn_zoom);
			if (_btn_pan_gamepad != -1) InputFeedbackManager.removeButton(_rendererSprite, _btn_pan_gamepad);
			if (_btn_pan_mouse != -1) InputFeedbackManager.removeButton(_rendererSprite, _btn_pan_mouse);
			
			_btn_rotate_gamepad = -1;
			_btn_rotate_mouse = -1;
			_btn_navigate = -1;
			_btn_zoom = -1;
			_btn_pan_gamepad = -1;
			_btn_pan_mouse = -1;
			
			/*
			if (_btn_pan == -1) _btn_pan = InputFeedbackManager.appendButton(_rendererSprite, NavigationCode.DPAD_UP_DOWN, -1, "Pan");
			if (_btn_pan == -1) _btn_pan = InputFeedbackManager.appendButton(_rendererSprite, NavigationCode.GAMEPAD_DPAD_LR, -1, "Draw sword");
			*/
			
			_rendererSprite.dispatchEvent(new Event(Event.DEACTIVATE));
		}
		
		private var _holdReceived:Boolean = false;
		public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var axisData:InputAxisData;
			var captureInput:Boolean = true;
			var isKeyUp:Boolean = details.value == InputValue.KEY_UP;
			var isKeyDown:Boolean = details.value == InputValue.KEY_DOWN;
			
			// trace("GFX <CharacterRendererController>  handleInput; _isInTransitionState ", _isInTransitionState, " details: ",  details.navEquivalent, details.code, details.value);
			
			// -------------- ON /OFF  --------------
			
			// _isCentered - animation finisheds
			// _isInTransitionState - animation is running
			// _isInTransitionToDefault
			// _isInTransitionToCenter
			
			// ---------------------------
			//
			// TODO: Remove explicit checks
			//
			
			if (event.handled || !enabled || inputDisabled) return;
			
			if (details.navEquivalent == NavigationCode.GAMEPAD_R2 && details.value == InputValue.KEY_HOLD && !_isInTransitionToCenter && !_isCentered)
			{
				_holdReceived = true;
				moveToCenter();
				activate();
			}
			else
			if (details.navEquivalent == NavigationCode.GAMEPAD_R2 && isKeyUp && _holdReceived && (_isCentered || _isInTransitionToCenter))
			{
				_holdReceived = false;
				moveToDefault();
				deactivate();
			}
			else
			if (details.navEquivalent == NavigationCode.GAMEPAD_R2 && isKeyUp && (_isCentered || _isInTransitionToCenter))
			{
				_holdReceived = false;
				moveToDefault();
				deactivate();
			}
			else
			if (details.navEquivalent == NavigationCode.GAMEPAD_R2 && isKeyUp && (!_isCentered || _isInTransitionToDefault))
			{
				_holdReceived = false;
				moveToCenter();
				activate();
			}
			else
			
			
			if (!_isCentered && isKeyUp && details.code == KeyCode.C && !_isInTransitionToCenter)
			{
				_holdReceived = false;
				moveToCenter();
				activate();
			}
			else
			if (_isCentered && isKeyUp && (details.code == KeyCode.C || details.navEquivalent == NavigationCode.GAMEPAD_B ) && !_isInTransitionToDefault)
			{
				_holdReceived = false;
				moveToDefault();
				deactivate();
				
				event.handled = true;
				event.stopImmediatePropagation();
			}
			else
			if (!_isCentered)
			{
				return;
			}
			
			// -------------- MOVE / ROTATE GERALT --------------
			
			
			if (!_isInTransitionToDefault && !_isInTransitionToCenter && _isCentered)
			{
				const DPAD_DELTA = 1;
				
				var isInputHandled:Boolean = false;
				
				/*
				if (details.navEquivalent == NavigationCode.GAMEPAD_A && _isCentered && !_isInTransitionToCenter && !_isInTransitionToDefault)
				{
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlayAnimation', [2] ));
					isInputHandled = true;
				}
				else
				*/
				
				if (details.navEquivalent == NavigationCode.DPAD_UP && isKeyDown )
				{
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnChangeCharRenderFocus', [false] ));
					isInputHandled = true;
				}
				else
				if (details.navEquivalent == NavigationCode.DPAD_DOWN && isKeyDown)
				{
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnChangeCharRenderFocus', [true] ));
					isInputHandled = true;
				}
				else
				if (details.navEquivalent == NavigationCode.DPAD_LEFT)
				{
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlayAnimation', [0] ));
					event.handled = true;
					event.stopImmediatePropagation();
				}
				else
				if (details.navEquivalent == NavigationCode.DPAD_RIGHT)
				{
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlayAnimation', [1] ));
					event.handled = true;
					event.stopImmediatePropagation();
				}
				else
				if (details.code ==KeyCode.PAD_RIGHT_STICK_AXIS)
				{
					axisData = InputAxisData(details.value);
					
					// zoom
					if (Math.abs(axisData.yvalue) > AXIS_DEAD_ZONE)
					{
						_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnScaleCharRenderer', [axisData.yvalue, true] ));
						isInputHandled = true;
					}
					
					// rotate
					if (Math.abs(axisData.xvalue) > AXIS_DEAD_ZONE)
					{
						_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRotateCharRenderer', [-axisData.xvalue] ));
						isInputHandled = true;
					}
				}
				else
				{
					if (details.fromJoystick)
					{
						leftInfoPanel.mcStatsList.handleInput(event);
					}
					
					event.handled = true;
					event.stopImmediatePropagation();
				}
				
				if (isInputHandled)
				{
					event.handled = true;
					event.stopImmediatePropagation();
				}
			}
		}
		
		
		// ------------ Mouse CTRLS ------------
		
		const M_DISTANCE_KOEFF = .08;
		const M_WHEEL_KOEFF = .2;
		
		private var isDraggingMode:Boolean = false;
		private var isPanningMode:Boolean = false;
		private var mouse_dx:Number;
		private var mouse_dy:Number;
		private var cached_mouse_x:Number;
		private var cached_mouse_y:Number;
		
		private var _cursorChanged:Boolean = false;
		private function handleMouseRollOver(event:MouseEvent):void
		{
			if (!_cursorChanged && _isCentered && !_isInTransitionToDefault && !_isInTransitionToCenter)
			{
				_menuRef.setMouseCursorType(CursorType.ROTATE);
				_cursorChanged = true;
			}
		}
		
		private function handleMouseRollOut(event:MouseEvent):void
		{
			resetCursorType();
		}
		
		private function resetCursorType():void
		{
			if (_cursorChanged)
			{
				_menuRef.setMouseCursorType(CursorType.DEFAULT);
				_cursorChanged = false;
			}
		}
		
		private function handleMouseDown(event:MouseEvent):void
		{
			if (!_isInTransitionToDefault && !_isInTransitionToCenter && _isCentered)
			{
				trace("GFX $handleMouseDown : ", mouse_dx, mouse_dy);
				
				var eventEx:MouseEventEx = event as MouseEventEx;
				var isRightBtn:Boolean = eventEx && eventEx.buttonIdx == MouseEventEx.RIGHT_BUTTON;
				
				isDraggingMode = !isRightBtn;
				isPanningMode = isRightBtn;
				
				mouse_dx = event.stageX;
				mouse_dy = event.stageY;
				
				_leftInfoPanel.enabled = _leftInfoPanel.mouseChildren = _leftInfoPanel.mouseEnabled = false;
				_menuRef.setMouseCursorVisibility(false);
				
				var vr:Rectangle = CommonUtils.getScreenRect();
				cached_mouse_x = (event.stageX + vr.x) / vr.width;
				cached_mouse_y = (event.stageY + vr.y) / vr.height;
			}
		}
		
		private function handleMouseUp(event:MouseEvent = null):void
		{
			if (!_isInTransitionToDefault && !_isInTransitionToCenter && _isCentered && (isDraggingMode || isPanningMode))
			{
				isDraggingMode = false;
				isPanningMode = false;
				
				_leftInfoPanel.enabled = _leftInfoPanel.mouseChildren = _leftInfoPanel.mouseEnabled = true;
				
				_menuRef.moveMouseCursor( cached_mouse_x, cached_mouse_y );
				
				trace("GFX $handleMouseUp");
				
				tmpK = 2; // TMP
				_menuRef.removeEventListener(Event.ENTER_FRAME, handleEnterMouseVisibilityValidation, false);
				_menuRef.addEventListener(Event.ENTER_FRAME, handleEnterMouseVisibilityValidation, false, 0, true);
			}
		}
		
		var tmpK:int = 0; // TMP
		private function handleEnterMouseVisibilityValidation(event:Event):void
		{
			if (tmpK < 0) // TMP
			{
				_menuRef.removeEventListener(Event.ENTER_FRAME, handleEnterMouseVisibilityValidation, false);
				_menuRef.setMouseCursorVisibility(true);
			}
			tmpK--;
		}
		
		private function handleMouseMouse(event:MouseEvent):void
		{
			if( !_isInTransitionToDefault && !_isInTransitionToCenter && _isCentered && ( isDraggingMode || isPanningMode ) )
			{
				var distance:Number;
				var mult:int;
				
				trace("GFX $handleMouseMouse isDraggingMode: ", isDraggingMode, "; isPanningMode", isPanningMode);
				
				if (isDraggingMode)
				{
					distance = mouse_dx - event.stageX;
					mult = 1; //mouse_dx < event.stageX ? 1 : -1;
					
					trace("GFX * distance ", distance, mult, "; [ ", mouse_dx, event.stageX , "]");
					
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRotateCharRenderer', [ mult * distance * M_DISTANCE_KOEFF] ));
				}
				else
				if (isPanningMode)
				{
					distance = mouse_dy - event.stageY;
					mult = 1; //mouse_dy < event.stageY ? 1 : -1;
					
					trace("GFX * distance ", distance, mult, "; [ ", mouse_dy, event.stageY , "]");
					
					_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnMoveCharRenderer', [ mult * distance * M_DISTANCE_KOEFF ] ));
				}
				
				mouse_dx = event.stageX;
				mouse_dy = event.stageY;
			}
		}
		
		private function handleMouseWheel(event:MouseEvent):void
		{
			trace("GFX $handleMouseWheel ", event.delta);
			
			if (!_isInTransitionToDefault && !_isInTransitionToCenter && _isCentered)
			{
				_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnScaleCharRenderer', [ event.delta * M_WHEEL_KOEFF, false] ));
			}
		}
		
		private function handleMouseDoubleClick(event:MouseEvent):void
		{
			_rendererSprite.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnResetPlayerPosition', [] ));
		}
		
		// ------------- UTILZ -----------------
		
		private function resetsTweens():void
		{
			GTweener.removeTweens(_rendererSprite);
			_fadeOutComponents.forEach(stopTweenOnObj);
		}
		
		private function stopTweenOnObj(obj:DisplayObject):void
		{
			if (obj)
			{
				GTweener.removeTweens(obj);
			}
		}
		
		private function fadeOutObj(obj:DisplayObject):void
		{
			if (obj)
			{
				var btn : InputFeedbackButton = obj as InputFeedbackButton;
				
				if (btn)
				{
					GTweener.to(obj, _animationTime, { alpha : 0 }, { ease:Sine.easeOut } );
					btn.enabled = false;
				}
				else
				{
					GTweener.to(obj, _animationTime, { alpha : 0 }, { ease:Sine.easeOut } );
				}
			}
			
		}
		
		private function fadeInObj(obj:DisplayObject):void
		{
			if (obj)
			{
				var btn : InputFeedbackButton = obj as InputFeedbackButton;
				
				if (btn)
				{
					GTweener.to(obj, _animationTime, { alpha : 1 }, { } );
					btn.enabled = true;
				}
				else
				{
					GTweener.to(obj, _animationTime, { alpha : 1 }, { } );
				}
			}
		}
		
	}
}
