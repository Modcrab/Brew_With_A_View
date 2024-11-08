package red.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.managers.RuntimeAssetsManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.utils.CommonUtils;

	import red.game.witcher3.managers.ContextInfoManager;
	import red.core.events.GameEvent;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class CoreComponent extends UIComponent implements IGameAdapter
	{
		public static var isColorBlindMode:Boolean;
		public static var isArabicAligmentMode:Boolean;
		public static var _gameLanguage : String;
		protected var _inputHandlers:Vector.<UIComponent>;
		protected var _inputMgr:InputManager;
		
		protected var _enableInputValidation:Boolean = false;
		protected var _enableHoldEmulation:Boolean = true;
		protected var _enableInputDeviceCheck:Boolean = true;

		public function CoreComponent()
		{
			super();
			_inputMgr = InputManager.getInstance();
			_inputHandlers = new Vector.<UIComponent>;
			addEventListener( GameEvent.CALL, handleGameEvent, false, int.MAX_VALUE, true );
			addEventListener( GameEvent.REGISTER, handleRegisterDataBinding, false, 0, true );
			addEventListener( GameEvent.UNREGISTER, handleUnregisterDataBinding, false, 0, true );

			// Instead of in "configUI" so can initialize things before it tries to call game events
			// and rely on somebody overriding it to call super.
			if ( stage )
			{
				init();
			}
			else
			{
				addEventListener( Event.ADDED_TO_STAGE, init, false, int.MAX_VALUE, true );
			}
		}
		
		public function swapAcceptCancel(value:Boolean):void
		{
			InputManager.getInstance().swapAcceptCancel = value;
			InputDelegate.getInstance().swapAcceptCancel = value;
		}
		
		public function resetInput():void
		{
			InputManager.getInstance().reset();
		}
		
		public static function set gameLanguage ( value : String ) : void
		{
			_gameLanguage = value;
			CommonUtils.setTurkish( value == "TR" );
		}
		
		public static function get gameLanguage () : String
		{
			return _gameLanguage;
		}
		
		public function setControllerType(isGamePad:Boolean):void
		{
			InputManager.getInstance().setControllerType(isGamePad);
		}

		public function setPlatform(platformType:uint):void
		{
			InputManager.getInstance().setPlatformType(platformType);
		}
		
		public function lockControlScheme(lockedControlScheme:uint):void
		{
			InputManager.getInstance().lockedControlScheme = lockedControlScheme;
		}
		
		public function setGamepadType(value:uint):void
		{
			InputManager.getInstance().gamepadType = value;
		}
		
		public function forceInputFeedbackUpdate():void
		{
			InputManager.getInstance().forceInputFeedbackUpdate();
		}
		
		public function setArabicAligmentMode(value:Boolean):void
		{
			isArabicAligmentMode = value;
		}

		private function init( e:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init, false );
			addEventListener( Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, int.MIN_VALUE, true );

			//FIXME: replace the old GameInterface
			//GameInterface.initialize( stage );

			onCoreInit();
		}

		protected function onCoreInit():void { } // for override
		protected function onCoreCleanup():void{ } // for override

		override protected function configUI():void
		{
			super.configUI();
			
			_inputMgr.init(stage, _enableHoldEmulation, _enableInputDeviceCheck);

			if (_enableInputValidation)
			{
				enableInputValidations(true);
			}
		}
		
		override public function toString():String
		{
			return "CoreComponent [ " + this.name + " ]";
		}

		private function handleRemovedFromStage( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false );
			RuntimeAssetsManager.getInstanse().unloadLibrary();
		}

		private function handleGameEvent( e : GameEvent ):void
		{
			//trace("INVENTORY callGameEvent: " + e.eventName + ", " + e.target );
			e.stopImmediatePropagation();
			callGameEvent( e.eventName, e.eventArgs );
		}

		private function handleRegisterDataBinding( e : GameEvent ):void
		{
			e.stopImmediatePropagation();

			var key : String = e.eventName;
			var closure : Object = null;
			var boundObject : Object = null;
			var isGlobal : Boolean = false;

			if ( e.eventArgs.length > 0 )
			{
				closure = e.eventArgs[0] as Object;
			}
			if ( e.eventArgs.length > 1 )
			{
				boundObject = e.eventArgs[1] as Object;
			}
			if ( e.eventArgs.length > 2 )
			{
				isGlobal = e.eventArgs[2] as Boolean;
			}
			registerDataBinding(key, closure, boundObject, isGlobal);
		}

		private function handleUnregisterDataBinding( e : GameEvent ):void
		{
			e.stopImmediatePropagation();
			var key : String = e.eventName;
			var closure : Object = null;
			var boundObject : Object = null;

			if ( e.eventArgs.length > 0 )
			{
				closure = e.eventArgs[0] as Object;
			}
			if ( e.eventArgs.length > 1 )
			{
				boundObject = e.eventArgs[1] as Object;
			}
			unregisterDataBinding(key, closure, boundObject);
		}

		// IGameAdapter functions
		public function registerDataBinding( key:String, closure:Object, boundObject:Object = null, isGlobal:Boolean = false ):void
		{
			if ( _NATIVE_registerDataBinding != null )
			{
				_NATIVE_registerDataBinding( key, closure, boundObject, isGlobal );
			}
		}

		public function unregisterDataBinding( key:String, closure:Object, boundObject:Object = null ):void
		{
			if ( _NATIVE_unregisterDataBinding != null )
			{
				_NATIVE_unregisterDataBinding( key, closure, boundObject );
			}
		}

		public function registerChild( spriteParent:DisplayObject, childName:String ):void
		{
			if ( _NATIVE_registerChild != null )
			{
				_NATIVE_registerChild( spriteParent, childName );
			}
		}

		public function unregisterChild():void
		{
			if ( _NATIVE_unregisterChild != null )
			{
				_NATIVE_unregisterChild();
			}
		}

		public function callGameEvent( eventName:String, eventArgs:Array ):void
		{
			if ( _NATIVE_callGameEvent != null )
			{
				_NATIVE_callGameEvent( eventName, eventArgs );
			}
		}

		public function registerRenderTarget( targetName:String, width:uint, height:uint ):void
		{
			if ( _NATIVE_registerRenderTarget != null )
			{
				_NATIVE_registerRenderTarget( targetName, width, height );
			}
		}

		public function unregisterRenderTarget( targetName:String ):void
		{
			if ( _NATIVE_unregisterRenderTarget != null )
			{
				_NATIVE_unregisterRenderTarget( targetName );
			}
		}


		/*
		 * 	In some cases we can receive 'KEY_UP' input event from other context (from exploration mode or other swfs)
		 *  It happends when we show UI when some button in 'KEY_DOWN' state.
		 *  To ignore this inputs we can use function enableInputValidations
		 */
		
		protected var pressedButtonsByKeys:Object = { };
		protected var pressedButtonsByNavEquivalent:Object = { };

		protected function enableInputValidations(value : Boolean):void
		{
			var inputDlgt:InputDelegate = InputDelegate.getInstance();
			inputDlgt.removeEventListener(InputEvent.INPUT, handleInputValidation, false);
			if (value)
			{
				inputDlgt.addEventListener(InputEvent.INPUT, handleInputValidation, false, 0, true);
			}
		}

		protected function handleInputValidation(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			if (keyDown)
			{
				pressedButtonsByNavEquivalent[details.navEquivalent] = true;
				pressedButtonsByKeys[details.code] = true;
			}
		}
		
		public function isInputValidationEnabled():Boolean
		{
			return _enableInputValidation;
		}

		public function isKeyCodeValid(keyCode:int):Boolean
		{
			if (_enableInputValidation)
			{
				return Boolean(pressedButtonsByKeys[keyCode]);
			}
			return true;
		}

		public function isNavEquivalentValid(navEquivalent:String):Boolean
		{
			if (_enableInputValidation)
			{
				return Boolean(pressedButtonsByNavEquivalent[navEquivalent]);
			}
			return true;
		}

		// C++ functions. Public by necessity; DO NOT CALL DIRECTLY.
		public var _NATIVE_registerDataBinding:Function;
		public var _NATIVE_unregisterDataBinding:Function;
		public var _NATIVE_registerChild:Function;
		public var _NATIVE_unregisterChild:Function;
		public var _NATIVE_callGameEvent:Function;
		public var _NATIVE_registerRenderTarget:Function;
		public var _NATIVE_unregisterRenderTarget:Function;
	}
}
