package red.game.witcher3.managers
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.core.CoreComponent;
	import red.core.CoreHud;
	import red.core.CoreHudModule;
	import red.core.CoreMenu;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.KeyCode;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.events.ControllerChangeEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * @author Yaroslav Getsevich
	 */
	public class InputManager extends EventDispatcher
	{
		public static const LOCKED_SCHEME_NONE:uint = 0;
		public static const LOCKED_SCHEME_GPAD:uint = 1;
		public static const LOCKED_SCHEME_MOUSE:uint = 2;
		
		protected static const CHANGE_CONTROLLER_TYPE_DELAY:Number = -1; // [ms] -1 to turn off
		protected static const CHANGE_CONTROLLER_MOUSE_DELTA:Number = 3; // [px]
		protected static const HOLD_DELAY:Number = 500;
		protected static const HOLD_INTERVAL:Number = 200;
		protected static const HOLD_INTERVAL_MIN:Number = 30;
		protected static const HOLD_INTERVAL_SPEED_UP_SCALE : Number = 0.88; // maximal 30 will be achieved after 600 ms in that case
		
		protected var currentHoldInterval : Number = HOLD_INTERVAL;

		protected static var _instance:InputManager;
		public static function getInstance():InputManager
		{
			if (!_instance) _instance = new InputManager();
			return _instance;
		}
		private var _inputBlocks:Object = { };
		protected var _inputDelegate:InputDelegate;
		protected var _rootStage:DisplayObjectContainer;
		protected var _isGamepad:Boolean;
		protected var _gpadInputReceived:Boolean;
		protected var _pendedGamepadInput:Boolean;
		protected var _pressedMap:Object = { };
		protected var _holdTimer:Timer;
		protected var _ctrlChangeTimer:Timer;
		protected var _bufMouseX:Number = 0;
		protected var _bufMouseY:Number = 0;
		protected var _platformType:uint  = PlatformType.PLATFORM_PC;
		
		protected var _initialized:Boolean;
		protected var _enableHoldEmulation:Boolean;
		protected var _enableInputDeviceCheck:Boolean;
		protected var _swapAcceptCancel:Boolean;
		
		protected var _lockedControlScheme:uint = 0;
		protected var _gamepadType:uint = EInputDeviceType.IDT_Xbox1;
		
		public function init(targetRoot:DisplayObjectContainer, bHoldEmulation:Boolean = true, bInputDeviceCheck:Boolean = true):void
		{
			if (_initialized)
			{
				return;
			}
			
			if (!targetRoot)
			{
				return;
			}
			
			if ( ExternalInterface.available )
			{
				_isGamepad = true; //  ExternalInterface.call("isUsingPad"); // Initial state #Y TODO: Get from WS
			}
			
			_initialized = true;
			_rootStage = targetRoot;
			
			enableInputDeviceCheck = bInputDeviceCheck;
			enableHoldEmulation = bHoldEmulation;
		}
		
		public function addInputBlocker(blockInput:Boolean, factor:String = "default"):void
		{
			_inputBlocks[factor] = blockInput ? 1 : 0;
			updateInputBlockers();
		}
		
		public function removeInputBlocker(factor:String = "default"):void
		{
			delete _inputBlocks[factor];
			updateInputBlockers();
		}
		
		protected function updateInputBlockers():void
		{
			var blockerExist:Boolean = false;
			var unblockerExist:Boolean = false;
			
			for (var curFactor:String in _inputBlocks )
			{
				if (_inputBlocks[curFactor])
				{
					blockerExist = true;
				}
				else
				{
					unblockerExist = true;
					break;
				}
			}
			
			// unblock input if at least one module needs it
			if (unblockerExist || !blockerExist)
			{
				InputDelegate.getInstance().disableInputEvents(false);
			}
			else
			{
				InputDelegate.getInstance().disableInputEvents(true);
			}
		}
		
		public function forceInputFeedbackUpdate():void
		{
			fireCtrlChangeEvent(_isGamepad, _platformType);
		}
		
		public function get gamepadType():uint
		{
			if (getPlatform() == PlatformType.PLATFORM_PS4)
			{
				return EInputDeviceType.IDT_PS4;
			}
			else if (getPlatform() == PlatformType.PLATFORM_PS5)
			{
				return EInputDeviceType.IDT_PS5;
			}
			else if (isXboxPlatform())
			{
				return EInputDeviceType.IDT_Xbox1;
			}
			
			return _gamepadType
		}
		
		public function set gamepadType(value:uint):void
		{
			_gamepadType = value;
			if (_gamepadType == EInputDeviceType.IDT_Steam || value == EInputDeviceType.IDT_Steam)
			{
				// update icons for steam pad
				if (_gamepadType == EInputDeviceType.IDT_Steam)
				{
					_lockedControlScheme = LOCKED_SCHEME_GPAD;
					setGamepadInputType(true, true);
				}
				else
				{
					_lockedControlScheme = LOCKED_SCHEME_NONE; // reset
					setGamepadInputType(_isGamepad, true);
				}
				
				fireCtrlChangeEvent(_isGamepad, _platformType);
			}
		}
		
		public function get lockedControlScheme():uint { return _lockedControlScheme }
		public function set lockedControlScheme(value:uint):void
		{
			if (gamepadType == EInputDeviceType.IDT_Steam)
			{
				// forsed for steam
				value = LOCKED_SCHEME_GPAD;
			}
			
			switch (_lockedControlScheme)
			{
				case LOCKED_SCHEME_GPAD:
					setGamepadInputType(true, true);
					break;
				case LOCKED_SCHEME_MOUSE:
					setGamepadInputType(false, true);
					break;
			}
			_lockedControlScheme = value;
		}
		
		public function get swapAcceptCancel():Boolean { return _swapAcceptCancel }
		public function set swapAcceptCancel(value:Boolean):void
		{
			_swapAcceptCancel = value;
			fireCtrlChangeEvent(_isGamepad, _platformType);
		}
		
		public function get enableInputDeviceCheck():Boolean { return _enableInputDeviceCheck }
		public function set enableInputDeviceCheck(value:Boolean):void
		{
			_enableInputDeviceCheck = value;
			
			_rootStage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse, false);
			_rootStage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouse, false);
			_rootStage.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouse, false);
			
			if (_enableInputDeviceCheck)
			{
				_rootStage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse, false, 0, true);
				_rootStage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse, false, 0, true);
				_rootStage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouse, false, 0, true);
			}
			
			updateInputListeners();
		}
		
		public function get enableHoldEmulation():Boolean { return _enableHoldEmulation }
		public function set enableHoldEmulation(value:Boolean):void
		{
			_enableHoldEmulation = value;
			
			if (_holdTimer)
			{
				_holdTimer.stop();
				_holdTimer.removeEventListener(TimerEvent.TIMER, handleHoldEvent);
				_holdTimer = null;
			}
			
			if (_enableHoldEmulation)
			{
				_holdTimer = new Timer(HOLD_DELAY);
				_holdTimer.addEventListener(TimerEvent.TIMER, handleHoldEvent, false, 0, true);
				_holdTimer.start();
			}
			
			updateInputListeners();
		}
		
		public function getPlatform():uint
		{
			return _platformType;
		}
		
		public function isXboxPlatform():Boolean
		{
			return _platformType == PlatformType.PLATFORM_XBOX1 || _platformType == PlatformType.PLATFORM_XB_SCARLETT_LOCKHART || _platformType == PlatformType.PLATFORM_XB_SCARLETT_ANACONDA;
		}
		
		public function isPsPlatform():Boolean
		{
			return _platformType == PlatformType.PLATFORM_PS4 || _platformType == PlatformType.PLATFORM_PS5;
		}
		
		public function isGamepad():Boolean
		{
			return _isGamepad || _platformType != PlatformType.PLATFORM_PC; // #Y don't support keyboard for consoles;
		}

		public function isPsGamepad():Boolean
		{
			return _gamepadType == EInputDeviceType.IDT_PS4 || _gamepadType == EInputDeviceType.IDT_PS5;
		}
		
		public function setControllerType(isGamepad:Boolean):void
		{
			if (isGamepad != _isGamepad)
			{
				setGamepadInputType(isGamepad);
			}
		}
		
		public function setPlatformType(value:uint):void
		{
			_platformType = value;
			fireCtrlChangeEvent(_isGamepad, _platformType);
		}
		
		protected function updateInputListeners():void
		{
			if (_enableInputDeviceCheck || _enableHoldEmulation)
			{
				_inputDelegate = InputDelegate.getInstance();
				_inputDelegate.addEventListener(InputEvent.INPUT, handleDelegatedInput, false, 1, true);
			}
			else
			{
				_inputDelegate = InputDelegate.getInstance();
				_inputDelegate.removeEventListener(InputEvent.INPUT, handleDelegatedInput, false);
				_inputDelegate = null;
			}
		}
		
		protected function handleHoldEvent(event:Event):void
		{
			if ( currentHoldInterval == HOLD_DELAY )
			{
				currentHoldInterval = HOLD_INTERVAL;
			}
			currentHoldInterval = Math.max(currentHoldInterval * HOLD_INTERVAL_SPEED_UP_SCALE, HOLD_INTERVAL_MIN);
			
			_holdTimer.delay = currentHoldInterval;
			_holdTimer.reset();
			_holdTimer.start();
			
			for (var curKey:String in _pressedMap)
			{
				var curEvent:InputEvent = _pressedMap[curKey] as InputEvent
				var curDetails:InputDetails = curEvent.details;
				
				var keyCode:int = curDetails.code;
				var navCode:String = curDetails.navEquivalent;
				if (swapAcceptCancel)
				{
					if (curDetails.code == KeyCode.PAD_A_CROSS)
					{
						keyCode = KeyCode.PAD_B_CIRCLE;
						navCode = NavigationCode.GAMEPAD_B;
					}
					else
					if (curDetails.code == KeyCode.PAD_B_CIRCLE)
					{
						keyCode = KeyCode.PAD_A_CROSS;
						navCode = NavigationCode.GAMEPAD_A;
					}
				}
				var details:InputDetails = new InputDetails("key", keyCode, InputValue.KEY_HOLD, navCode, curDetails.controllerIndex, curDetails.ctrlKey, curDetails.altKey, curDetails.shiftKey, curDetails.fromJoystick);
				_inputDelegate.dispatchEvent(new InputEvent(InputEvent.INPUT, details));
			}
		}
		
		protected function handleDelegatedInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var isGPad:Boolean;
			
			if (_platformType == PlatformType.PLATFORM_PC)
			{
				isGPad = isGamepadCode(details);
			}
			else
			{
				isGPad = true;
			}
			
			if (_enableHoldEmulation)
			{
				holdProcessing(event);
			}
			if (isGPad)
			{
				_gpadInputReceived = true;
				setGamepadInputType(true);
				return;
			}
			
			// #Y Skip first KB input after GPad input and emulated KEY_HOLD (to avoid KB inputs from dpad)
			else if (_gpadInputReceived || event.details.value == InputValue.KEY_HOLD)
			{
				_gpadInputReceived  = false;
				return;
			}
			setGamepadInputType(false);
		}

		protected function holdProcessing(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var keycode:Number = details.code;
			if (details.value == InputValue.KEY_DOWN)
			{
				_holdTimer.delay = HOLD_DELAY;
				currentHoldInterval = HOLD_DELAY;
				_holdTimer.reset();
				_holdTimer.start();
				if (!_pressedMap[keycode])
				{
					_pressedMap[keycode] = event;
				}

			}
			else if (details.value == InputValue.KEY_UP)
			{
				delete _pressedMap[keycode];
				_holdTimer.stop();
				currentHoldInterval = HOLD_DELAY;
			}
		}

		protected function handleMouse(event:MouseEvent):void
		{
			// I don't want to calculate pow on each mouse move event, so just simple axis delta check:
			var deltaX:Number = Math.abs(event.stageX - _bufMouseX);
			var deltaY:Number = Math.abs(event.stageY - _bufMouseY);
			
			if (deltaX > CHANGE_CONTROLLER_MOUSE_DELTA || deltaY > CHANGE_CONTROLLER_MOUSE_DELTA)
			{
				setGamepadInputType(false);
			}
			_bufMouseX = event.stageX;
			_bufMouseY = event.stageY;
		}

		protected function setGamepadInputType(pGamepadInput:Boolean, forced:Boolean = false):void
		{
			if ((!_ctrlChangeTimer && (pGamepadInput != _isGamepad)) || (_ctrlChangeTimer && (pGamepadInput != _pendedGamepadInput)))
			{
				if (_ctrlChangeTimer)
				{
					_ctrlChangeTimer.removeEventListener(TimerEvent.TIMER, delayedFireControllerChangeEvent);
					_ctrlChangeTimer.stop();
				}
				
				if (lockedControlScheme != LOCKED_SCHEME_NONE && !forced)
				{
					trace("GFX Control scheme locked! Cant change it to from [gamepad ", _isGamepad, "] to [gamepad ", pGamepadInput, "]");
					return;
				}
				
				if (CHANGE_CONTROLLER_TYPE_DELAY > 0)
				{
					_pendedGamepadInput = pGamepadInput;
					_ctrlChangeTimer = new Timer(CHANGE_CONTROLLER_TYPE_DELAY, 1);
					_ctrlChangeTimer.addEventListener(TimerEvent.TIMER, delayedFireControllerChangeEvent, false, 0, true);
					_ctrlChangeTimer.start();
				}
				else
				{
					_isGamepad = pGamepadInput;
					fireCtrlChangeEvent(_isGamepad, _platformType);
				}
			}
		}
		
		protected function delayedFireControllerChangeEvent(event:TimerEvent):void
		{
			if (_pendedGamepadInput != _isGamepad)
			{
				_isGamepad = _pendedGamepadInput;
				fireCtrlChangeEvent(_isGamepad, _platformType)
			}
			if (_ctrlChangeTimer)
			{
				_ctrlChangeTimer.removeEventListener(TimerEvent.TIMER, delayedFireControllerChangeEvent);
				_ctrlChangeTimer.stop();
				_ctrlChangeTimer = null;
			}
		}
		
		protected var _validatingIsGamepad:Boolean = false;
		protected var _validatingPlatformType:uint = 0;
		protected function fireCtrlChangeEvent(pIsGamepad:Boolean, pPlatformType:uint):void
		{
			_validatingIsGamepad = pIsGamepad;
			_validatingPlatformType = pPlatformType;
			_rootStage.removeEventListener(Event.ENTER_FRAME, validateFireCtrlChangeEvent, false);
			_rootStage.addEventListener(Event.ENTER_FRAME, validateFireCtrlChangeEvent, false, 0, true);
		}
		
		protected function validateFireCtrlChangeEvent(event:Event = null):void
		{
			var ctrlEvent:ControllerChangeEvent = new ControllerChangeEvent(ControllerChangeEvent.CONTROLLER_CHANGE);
			
			//trace("GFX --- validateFireCtrlChangeEvent; _validatingIsGamepad:  ", _validatingIsGamepad, "; _validatingPlatformType: ", _validatingPlatformType);
			
			_rootStage.removeEventListener(Event.ENTER_FRAME, validateFireCtrlChangeEvent, false);
			ctrlEvent.isGamepad = _validatingIsGamepad || _validatingPlatformType != PlatformType.PLATFORM_PC; // #Y don't support keyboard for consoles
			ctrlEvent.platformType = _validatingPlatformType;
			dispatchEvent(ctrlEvent);
		}

		protected function isGamepadCode(details:InputDetails):Boolean
		{
			if (details.fromJoystick)
			{
				return true;
			}
			var keycode:Number = details.code;
			switch (keycode)
			{
				case KeyCode.PAD_A_CROSS:
				case KeyCode.PAD_B_CIRCLE:
				case KeyCode.PAD_X_SQUARE:
				case KeyCode.PAD_Y_TRIANGLE:
				case KeyCode.PAD_START:
				case KeyCode.PAD_BACK_SELECT:
				case KeyCode.PAD_DIGIT_UP:
				case KeyCode.PAD_DIGIT_DOWN:
				case KeyCode.PAD_DIGIT_LEFT:
				case KeyCode.PAD_DIGIT_RIGHT:
				case KeyCode.PAD_LEFT_THUMB:
				case KeyCode.PAD_RIGHT_THUMB:
				case KeyCode.PAD_LEFT_SHOULDER:
				case KeyCode.PAD_RIGHT_SHOULDER:
				case KeyCode.PAD_LEFT_TRIGGER:
				case KeyCode.PAD_RIGHT_TRIGGER:
				case KeyCode.PAD_LEFT_STICK_AXIS:
				case KeyCode.PAD_RIGHT_STICK_AXIS:
				case KeyCode.PAD_LEFT_TRIGGER_AXIS:
				case KeyCode.PAD_RIGHT_TRIGGER_AXIS:
				case KeyCode.PAD_RIGHT_STICK_LEFT:
				case KeyCode.PAD_RIGHT_STICK_RIGHT:
				case KeyCode.PAD_RIGHT_STICK_DOWN:
				case KeyCode.PAD_RIGHT_STICK_UP:
					return true;
			}
			return false;
		}

		public function reset() : void //#B
		{
			if ( _pressedMap )
			{
				if (_holdTimer)
				{
					_holdTimer.reset();
					_holdTimer.stop();
				}
				_pressedMap = { };
			}
		}
	}
}
