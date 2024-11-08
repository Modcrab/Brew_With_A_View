/**************************************************************************

Filename    :   InputDelegate.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

﻿package scaleform.clik.managers {
    
    import flash.display.Stage;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.NavigationCode;
	import scaleform.gfx.GamePad;
	import scaleform.gfx.GamePadAnalogEvent;
    
    import scaleform.gfx.KeyboardEventEx;
	
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
    
    [Event(name="input", type="scaleform.clik.events.InputEvent")]
    
    public class InputDelegate extends EventDispatcher {
        
    // Singleton access
        private static var instance:InputDelegate;
        public static function getInstance():InputDelegate {
            if (instance == null) { instance = new InputDelegate(); }
            return instance;
        }
        
    // Constants:
        public static const MAX_KEY_CODES:uint = 1000;
        public static const KEY_PRESSED:uint = 1;
        public static const KEY_SUPRESSED:uint = 2;
        
    // Public Properties:
        public var stage:Stage;
        public var externalInputHandler:Function;
		
		public var modalInputHandler:Function;
        
    // Protected Properties:
        protected var keyHash:Array; // KeyHash stores all key code states and supression rules. We use a flat array, which uses a max-keys multiplier to look up controller-specific key rules and states. Each key state is a bit containing the appropriate flags.
        
    // Initialization:
        public function InputDelegate() {
            keyHash = [];
        }
        
        public function initialize(stage:Stage):void {
            this.stage = stage;
			
			if (!_inputEventDisabled)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
				stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp, false, 0, true);
				stage.addEventListener(GamePadAnalogEvent.CHANGE, handleGamePad, false, 0, true );
			}
        }
		
	// // #W3 added, for optimization
		private var _inputEventDisabled:Boolean = false;
		public function disableInputEvents(value:Boolean):void
		{
			_inputEventDisabled = value;
			if (stage)
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false);
				stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp, false);
				stage.removeEventListener(GamePadAnalogEvent.CHANGE, handleGamePad, false);
				
				if (!value)
				{
					stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
					stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp, false, 0, true);
					stage.addEventListener(GamePadAnalogEvent.CHANGE, handleGamePad, false, 0, true );
				}
				else
				{
					keyHash = [];
				}
			}
		}
		
	// // #W3 added; swap A/B for japanese version
		private var _swapAcceptCancel:Boolean = false;
		public function get swapAcceptCancel():Boolean { return _swapAcceptCancel }
		public function set swapAcceptCancel(value:Boolean):void
		{
			_swapAcceptCancel = value;
		}
    	
    // Public getter / setters:
        
    // Public Methods:
        public function setKeyRepeat(code:Number, repeat:Boolean, controllerIndex:uint=0):void {
            var index:uint = controllerIndex * MAX_KEY_CODES + code;
            // Note that bitwise operation against null is the same as against 0, so we don't have to initialize the property.
            if (repeat) {
                keyHash[index] &= ~KEY_SUPRESSED;
            } else {
                keyHash[index] |= KEY_SUPRESSED;
            }
        }
        
        public function inputToNav(type:String, code:Number, shiftKey:Boolean = false, value:*=null):String {
            // Keys, likely the PC Keyboard.
            
            if (externalInputHandler != null) {
                return externalInputHandler(type, code, value);
            }
            
			// + 25/04/2014 Getsevich
			// Separate DPad from keyboard's arrow keys
			
            if (type == "key") {
                switch (code) {
                    case KeyCode.UP:
						return NavigationCode.UP;
					case KeyCode.PAD_DIGIT_UP:
                        return NavigationCode.DPAD_UP;
                    case KeyCode.DOWN:
						return NavigationCode.DOWN;
					case KeyCode.PAD_DIGIT_DOWN:
                        return NavigationCode.DPAD_DOWN;
					case KeyCode.PAD_DIGIT_LEFT:
						return NavigationCode.DPAD_LEFT;
					case KeyCode.LEFT: 
                        return NavigationCode.LEFT;
                    case KeyCode.RIGHT:
						return NavigationCode.RIGHT;
					case KeyCode.PAD_DIGIT_RIGHT:
                        return NavigationCode.DPAD_RIGHT;
					case KeyCode.ENTER:
					case KeyCode.SPACE:
                        return NavigationCode.ENTER;
					case KeyCode.BACKSPACE:
                        return NavigationCode.BACK;
					case KeyCode.TAB:
                        if (shiftKey) { return NavigationCode.SHIFT_TAB; }
                        else { return NavigationCode.TAB; }
					case KeyCode.HOME:
                        return NavigationCode.HOME;
					case KeyCode.END:
                        return NavigationCode.END;
					case KeyCode.PAGE_DOWN:
                        return NavigationCode.PAGE_DOWN;
					case KeyCode.PAGE_UP:
                        return NavigationCode.PAGE_UP;
                    case KeyCode.ESCAPE:
                        return NavigationCode.ESCAPE;
                    
                    // Custom handlers for gamepad support
                    case KeyCode.PAD_A_CROSS:
                        return NavigationCode.GAMEPAD_A;
                    case KeyCode.PAD_B_CIRCLE:
                        return NavigationCode.GAMEPAD_B;
                    case KeyCode.PAD_X_SQUARE:
                        return NavigationCode.GAMEPAD_X;
                    case KeyCode.PAD_Y_TRIANGLE:
                        return NavigationCode.GAMEPAD_Y;
                    case KeyCode.PAD_LEFT_SHOULDER:
                        return NavigationCode.GAMEPAD_L1;
                    case KeyCode.PAD_LEFT_TRIGGER:
                        return NavigationCode.GAMEPAD_L2;
                    case KeyCode.PAD_LEFT_THUMB:
                        return NavigationCode.GAMEPAD_L3;
                    case KeyCode.PAD_RIGHT_SHOULDER:
                        return NavigationCode.GAMEPAD_R1;
                    case KeyCode.PAD_RIGHT_TRIGGER:
                        return NavigationCode.GAMEPAD_R2;
                    case KeyCode.PAD_RIGHT_THUMB:
                        return NavigationCode.GAMEPAD_R3;
                    case KeyCode.PAD_START:
                        return NavigationCode.GAMEPAD_START;
                    case KeyCode.PAD_BACK_SELECT:
                        return NavigationCode.GAMEPAD_BACK;
					// #W3 Added ++
                    case KeyCode.PAD_LEFT_STICK_UP: // #W3 added
                        return NavigationCode.UP; // #W3 added
                    case KeyCode.PAD_LEFT_STICK_DOWN: // #W3 added
                        return NavigationCode.DOWN; // #W3 added
                    case KeyCode.PAD_LEFT_STICK_LEFT: // #W3 added
                        return NavigationCode.LEFT; // #W3 added
                    case KeyCode.PAD_LEFT_STICK_RIGHT: // #W3 added
                        return NavigationCode.RIGHT; // #W3 added
					case KeyCode.PAD_RIGHT_STICK_DOWN:
						return NavigationCode.RIGHT_STICK_DOWN;
					case KeyCode.PAD_RIGHT_STICK_UP:
						return NavigationCode.RIGHT_STICK_UP;
					case KeyCode.PAD_RIGHT_STICK_LEFT:
						return NavigationCode.RIGHT_STICK_LEFT;
					case KeyCode.PAD_RIGHT_STICK_RIGHT:
						return NavigationCode.RIGHT_STICK_RIGHT;
					case KeyCode.PAD_PS4_OPTIONS:
						return NavigationCode.GAMEPAD_BACK;
					case KeyCode.PAD_PS4_TOUCH_PRESS:
						return NavigationCode.START;
					// #W3 Added --
                }
            }
            return null;
        }
        
        //LM: Review: Can we do function callBacks?
        public function readInput(type:String, code:int, callBack:Function):Object {
            // Look up game engine stuff
            return null;
        }
        
    // Protected Methods:
        protected function handleKeyDown(event:KeyboardEvent):void {
            var sfEvent:KeyboardEventEx = event as KeyboardEventEx;
            var controllerIdx:uint = (sfEvent == null) ? 0 : sfEvent.controllerIdx;
            
            var code:Number = event.keyCode;
            var keyStateIndex:uint = controllerIdx * MAX_KEY_CODES + code;
            var keyState:uint = keyHash[keyStateIndex];
            
            if (keyState & KEY_PRESSED) {
                if ((keyState & KEY_SUPRESSED) == 0) {
                    handleKeyPress(InputValue.KEY_HOLD, code, controllerIdx, event.ctrlKey, event.altKey, event.shiftKey);
                }
            } else {
                handleKeyPress(InputValue.KEY_DOWN, code, controllerIdx, event.ctrlKey, event.altKey, event.shiftKey);
                keyHash[keyStateIndex] |= KEY_PRESSED;
            }
        }
        
        protected function handleKeyUp(event:KeyboardEvent):void {
            var sfEvent:KeyboardEventEx = event as KeyboardEventEx;
            var controllerIdx:uint = (sfEvent == null) ? 0 : sfEvent.controllerIdx;
            
            var code:Number = event.keyCode;
            var keyStateIndex:uint = controllerIdx * MAX_KEY_CODES + code;
            keyHash[keyStateIndex] &= ~KEY_PRESSED;
            handleKeyPress(InputValue.KEY_UP, code, controllerIdx, event.ctrlKey, event.altKey, event.shiftKey);
        }
        
		protected function handleGamePad(event:GamePadAnalogEvent):void {
			var code:uint = 0;
			var fromJoystick:Boolean = false;
			var xvalue:Number = event.xvalue;
			var yvalue:Number = event.yvalue;
			switch ( event.code )
			{
				case GamePad.PAD_LT:
					code = KeyCode.PAD_LEFT_STICK_AXIS;
					fromJoystick = true; // #W3 added
					break;
				case GamePad.PAD_RT:
					code = KeyCode.PAD_RIGHT_STICK_AXIS;
					fromJoystick = true; // #W3 added
					break;
				case GamePad.PAD_L2:
					code = KeyCode.PAD_LEFT_TRIGGER_AXIS;
					break;
				case GamePad.PAD_R2:
					code = KeyCode.PAD_RIGHT_TRIGGER_AXIS;
				default:
					break;
			}
			
			if ( code != 0 )
			{
				var details:InputDetails = new InputDetails("axis", code, new InputAxisData( xvalue, yvalue ), null, event.controllerIdx, false, false, false, fromJoystick);
				
				if (modalInputHandler != null)
				{
					modalInputHandler(new InputEvent("modalInput", details));
				}
				else
				{
					dispatchEvent(new InputEvent(InputEvent.INPUT, details));
				}
			}
		}
		
        protected function handleKeyPress(type:String, code:Number, controllerIdx:Number, ctrl:Boolean, alt:Boolean, shift:Boolean):void {
            var details:InputDetails = new InputDetails("key", code, type, inputToNav("key", code, shift), controllerIdx, ctrl, alt, shift);
            morphLeftStickPressDetails(details); // #W3 added
			//trace("GFX handleKeyPress ---- ", _swapAcceptCancel, details);
			if (_swapAcceptCancel) // #W3 added
			{
				swapAcceptCancelInputDetails(details);
			}
			//trace("GFX *",  details);
			if (modalInputHandler != null)
			{
				modalInputHandler(new InputEvent("modalInput", details));
			}
			else
			{
				dispatchEvent(new InputEvent(InputEvent.INPUT, details));
			}
        }
		
		// #W3 added, swap A/B for japanese version
		protected function swapAcceptCancelInputDetails(details:InputDetails):void
		{
			if (details.code == KeyCode.PAD_A_CROSS)
			{
				details.code = KeyCode.PAD_B_CIRCLE;
				details.navEquivalent = NavigationCode.GAMEPAD_B;
			}
			else
			if (details.code == KeyCode.PAD_B_CIRCLE)
			{
				details.code = KeyCode.PAD_A_CROSS;
				details.navEquivalent = NavigationCode.GAMEPAD_A;
			}
		}
        
		// #W3 To differentiate whether an up comes from left joystick or otherwhere, but to make it transparent for the systems who don't care
        protected function morphLeftStickPressDetails(details:InputDetails):void
        {
            switch (details.code)
            {
            case KeyCode.PAD_LEFT_STICK_UP:
                details.code = KeyCode.UP;
                details.fromJoystick = true;
                break;
            case KeyCode.PAD_LEFT_STICK_DOWN:
                details.code = KeyCode.DOWN;
                details.fromJoystick = true;
                break;
            case KeyCode.PAD_LEFT_STICK_LEFT:
                details.code = KeyCode.LEFT;
                details.fromJoystick = true;
                break;
            case KeyCode.PAD_LEFT_STICK_RIGHT:
                details.code = KeyCode.RIGHT;
                details.fromJoystick = true;
                break;
            }
        }
    }
}
