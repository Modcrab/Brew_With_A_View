package red.game.witcher3.controls
{
	import adobe.utils.CustomActions;
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.core.data.InputAxisData;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.KeyboardKeys;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * Input button binded
	 * @author Yaroslav Getsevich
	 */
	public class InputFeedbackButton extends Button
	{
		protected static const HOLD_ANIM_STEPS_COUNT:Number = 30;
		protected static const HOLD_ANIM_INTERVAL:Number = 20; // ms
		protected static const DISABLED_ALPHA = .4;
		protected static const CLICKABLE_BK_OFFSET = 10;
		protected static const INVALIDATE_DISPLAY_DATA:String = "invalidate_display_data";
		protected static const GPAD_ICON_SIZE:Number = 64;
		protected static const TEXT_PADDING_KEYBOARD:Number = 5; // Distance between text and icon
		protected static const TEXT_PADDING_PAD:Number = 1; // Distance between text and icon
		protected static const TEXT_OFFSET:Number = 6;  // Hack to prevent text's cutting
		protected static const KEY_LABEL_PADDING:Number = 5;
		
		protected static const HOLD_INT_MAX_ANGLE:Number = 360;
		protected static const HOLD_INT_MAX_FRAME:Number = 28;
		protected static const HOLD_INT_FIRST_FRAME:Number = 2;
		
		public var mcIconXbox:MovieClip;
		public var mcIconPS:MovieClip;
		public var mcIconPS4:MovieClip;
		public var mcIconPS5:MovieClip;
		public var mcIconSteam:MovieClip;
		public var mcKeyboardIcon:KeyboardButtonIcon;
		public var mcMouseIcon:KeyboardButtonMouseIcon;
		public var mcHoldAnimation:MovieClip;
		
		public var mcClickRect:MovieClip;
		
		public var tfHoldPrefix:TextField;
		public var tfKeyLabel:TextField;
		
		public var holdCallback:Function;
		public var addHoldPrefix:Boolean;
		
		protected var _currentWidth:Number;
		protected var _targetViewer:DisplayObject;
		protected var _bindingData:KeyBindingData;
		protected var _isGamepad:Boolean;
		protected var _gpadIcon:MovieClip;
		protected var _clickable:Boolean = true;
		protected var _labelPosition:Number;
		
		protected var _holdTimer:Timer;
		protected var _holdProgress:Number;
		protected var _holdDuration:Number = -1;
		protected var _holdIndicatorMask:Sprite;
		protected var _holdIndicator:Sprite;

		protected var _posXSource:int = 0;
		protected var _shiftXForGamepad:int = 0;
		protected var _shiftXForKeyboard:int = 0;
		
		// for using on stage, outside of InputFeedBackModule
		protected var _displayGamepadCode:String = "";
		protected var _displayGamepadKeyCode:int = -1;
		protected var _displayKeyboardCode:int = -1;
		protected var _dataFromStage:Boolean;
		
		protected var _contentInvalid:Boolean = false;
		protected var _actualVisibility:Boolean = true;
		protected var _lowercaseLabels:Boolean = false;
		protected var _overrideTextColor:Number = -1;
		protected var _dontSwapAcceptCancel:Boolean;
		
		private var _timerActivated:Boolean = false;
		
		public function InputFeedbackButton()
		{
			constraintsDisabled = true;
			preventAutosizing = true;
			
			if (mcIconXbox) mcIconXbox.visible = false;
			if (mcIconPS) mcIconPS.visible = false;
			if (mcIconPS4) mcIconPS4.visible = false;
			if (mcIconPS5) mcIconPS5.visible = false;
			if (mcKeyboardIcon) mcKeyboardIcon.visible = false;
			if (mcIconSteam) mcIconSteam.visible = false;
			
			_gpadIcon = mcIconXbox; // default
			focusable = false;
			if (textField)
			{
				textField.text = "";
				textField.autoSize = TextFieldAutoSize.LEFT;
			}
			
			if (mcClickRect) mcClickRect.visible = false;
			if (mcHoldAnimation) mcHoldAnimation.visible = false;
			if (tfKeyLabel) tfKeyLabel.visible = false;
			if (mcMouseIcon) mcMouseIcon.visible = false;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			SetHoldButtonText();
			if (tfHoldPrefix)
				tfHoldPrefix.visible = false;
		}
		
		public function get dontSwapAcceptCancel():Boolean { return _dontSwapAcceptCancel }
		public function set dontSwapAcceptCancel(value:Boolean):void
		{
			_dontSwapAcceptCancel = value;
		}
		
		public function get overrideTextColor():Number { return _overrideTextColor };
		public function set overrideTextColor(value:Number):void
		{
			_overrideTextColor = value;
		}
		
		/**
		 * WARNING! Can cause problems in german localization!
		 */
		public function get lowercaseLabels():Boolean { return _lowercaseLabels }
		public function set lowercaseLabels(value:Boolean):void
		{
			_lowercaseLabels = value;
		}
		
		override public function set visible(value:Boolean):void
		{
			_actualVisibility = value;
			updateVisibility();
		}
		
		/**
		 * Duration [ms] of the hold idicator animation. Enabled if > 0, otherwise disabled
		 */
		public function get holdDuration():Number { return _holdDuration }
		public function set holdDuration(value:Number):void
		{
			_holdDuration = value;
			InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, handleHoldInput, false); // to avoid double call
			
			//trace("GFX <", this, "> holdDuration ", _holdDuration);
			
			if (_holdDuration > 0)
			{
				SetHoldButtonText();
				InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleHoldInput, false, 0, true);
			}
			else
			{
				stopHoldAnimation();
			}
		}

		public function get clickable():Boolean { return _clickable }
		public function set clickable(value:Boolean):void
		{
			_clickable = value;
		}

		/**
		 * For using button outside InputFeedBackModule
		 */
		public function setDataFromStage(gpadCode:String, kbCode:int, gpadKeyCode : int = -1, defHoldDuration : Number = 0, isRadialMenu : Boolean = false, doubleTap : Boolean = false ):void // NGE
		{
			var inputMgr:InputManager = InputManager.getInstance();
			_isRadialMenu = isRadialMenu; // NGE
			_doubleTap = doubleTap; // NGE
			inputMgr.removeEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged);
			inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
			
			_displayGamepadCode = gpadCode;
			_displayGamepadKeyCode = gpadKeyCode;
			_displayKeyboardCode = kbCode;
			_dataFromStage = true;
			
			holdDuration = defHoldDuration;
			updateDataFromStage();
			
			SetHoldButtonText();
		}
		
		public function setShiftForGamepad( newShift: int = 0, kbrd: int = 0) : void
		{
			_posXSource = x;
			_shiftXForGamepad = newShift;
			_shiftXForKeyboard = kbrd;
		}

		public function getViewWidth():Number
		{
			if (mcClickRect.visible)
			{
				return mcClickRect.actualWidth;
			}
			return _currentWidth ? _currentWidth : width;
		}

		public function GetIconSize() : int
		{
			if ( _gpadIcon.visible)
			{
				return GPAD_ICON_SIZE;
			}
			else if ( mcKeyboardIcon.visible )
			{
				return mcKeyboardIcon.width;
			}
			return 0;
		}

		public function getBindingData():KeyBindingData
		{
			return _bindingData;
		}

		public function setData(bindingData:KeyBindingData, isGamepad:Boolean, dontUpdate:Boolean = false):void
		{
			_bindingData = bindingData;
			if (dontUpdate) return;
			
			if (_bindingData)
			{
				var isPlayStation:Boolean = InputManager.getInstance().isPsPlatform();
				
				var newGpadIcon:MovieClip =  getCurrentPadIcon();
				
				if (_gpadIcon && _gpadIcon != newGpadIcon)
				{
					_gpadIcon.visible = false;
				}
				if (mcMouseIcon)
				{
					mcMouseIcon.visible = false;
				}
				_gpadIcon = newGpadIcon;
				_isGamepad = isGamepad;
				_label = _bindingData.label;
				
				if (_shiftXForGamepad > 0) 
				{
					x = _posXSource;
					if (isGamepad || isPlayStation) 
					{
						x += _shiftXForGamepad;
					}
					else
					{
						x += _shiftXForKeyboard;
					}
				}
				
				if (_isGamepad || isPlayStation)
				{
					displayGamepadIcon();
					if (mcHoldAnimation) { mcHoldAnimation.alpha = 1; }
				}
				else
				{
					displayKeyboardIcon();
					if (mcHoldAnimation) { mcHoldAnimation.alpha = 0; }
				}
			}
			else
			{
				_contentInvalid = true;
				updateVisibility();
			}
		}
		
		protected function getCurrentPadIcon():MovieClip
		{
			var curGamepadType:uint = InputManager.getInstance().gamepadType;
			
			switch (curGamepadType)
			{
				case EInputDeviceType.IDT_PS4:
					if(mcIconPS){
						return mcIconPS;
					}
					else {
						return mcIconPS4;
					}
				case EInputDeviceType.IDT_PS5:
					if(mcIconPS5){
						return mcIconPS5;
					}
					else {
						return mcIconPS;
					}
				case EInputDeviceType.IDT_Xbox1:
					return mcIconXbox;
				case EInputDeviceType.IDT_Steam:
					if (mcIconSteam)
						return mcIconSteam;
					else
						return mcIconXbox;
				default:
					return mcIconXbox;
			}
			
			return mcIconXbox;
		}

		public function displayGamepadIcon():void
		{
			var curGpadNavCode:String = _bindingData.gamepad_navEquivalent;
			var curGpadKeyCode:int = _bindingData.gamepad_keyCode;
			
			updateText();
			if (curGpadNavCode)
			{
				SetupGamepadIcon(curGpadNavCode);
			}
			else if( curGpadKeyCode > 0)
			{
				var inputDelegate : InputDelegate;
				inputDelegate = InputDelegate.getInstance();
				curGpadNavCode = inputDelegate.inputToNav( "key", curGpadKeyCode );
				SetupGamepadIcon(curGpadNavCode);
			}
			else
			{
				_contentInvalid = true;
				updateVisibility();
			}
		}
		
		public function getCurrentHoldProgress():Number
		{
			var maxValue:Number = mcHoldAnimation ? HOLD_INT_MAX_FRAME : HOLD_INT_MAX_ANGLE;
			return _holdProgress / maxValue;
		}
		
		protected function SetHoldButtonText():void
		{
			if (tfHoldPrefix && tfHoldPrefix.visible)
			{
				tfHoldPrefix.autoSize = TextFieldAutoSize.LEFT;
				// NGE
				if(_doubleTap)
					tfHoldPrefix.text = "[[ControlLayout_doubleTap]]";
				else
					tfHoldPrefix.text = "[[ControlLayout_hold]]";
				// NGE
				if (!CoreComponent.isArabicAligmentMode)
				{
					tfHoldPrefix.text = "[" + tfHoldPrefix.text.toUpperCase() + "]";
				}
				else
				{
					tfHoldPrefix.text = "*" + tfHoldPrefix.text.toUpperCase() + "*";
				}
				tfHoldPrefix.width = tfHoldPrefix.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			}
		}

		protected var currentPadIconWidth:Number;
		protected function SetupGamepadIcon( navCode : String )
		{
			var hitArea:Sprite;
			
			try
			{
				_gpadIcon.visible = true;
				_gpadIcon.gotoAndStop( getPadIconFrameLabel(navCode) );
				mcKeyboardIcon.visible = false;
				
				if (mcClickRect) mcClickRect.visible = false;
				if (tfKeyLabel) tfKeyLabel.visible = false;
				
				_contentInvalid = false;
				updateVisibility();
				
				hitArea = _gpadIcon["viewrect"] as Sprite;
				currentPadIconWidth = hitArea ? hitArea.width : _gpadIcon.width;
				_labelPosition = currentPadIconWidth + TEXT_PADDING_PAD;
				
				_gpadIcon.x = Math.round(currentPadIconWidth / 2);
				
				updateText();
				
				_currentWidth = currentPadIconWidth + textField.width + TEXT_PADDING_PAD + (_holdDuration > 0 ? tfHoldPrefix.width : 0);
				
				if (_holdIndicator) _holdIndicator.visible = false; // prev one
				_holdIndicator = _gpadIcon["holdIndicator"] as Sprite;
				if (_holdIndicator) _holdIndicator.visible = false;
			}
			catch (err:Error)
			{
				trace("GFX #ERROR# [", this, "]");
				trace("GFX # _gpadIcon ", _gpadIcon, "; mcIconSteam ", mcIconSteam);
				trace("GFX # ", err.message, err.getStackTrace());
				
			}
		}
		
		protected function getPadIconFrameLabel(navLabel:String):String
		{
			var inputMgr:InputManager = InputManager.getInstance();
			if (!_dontSwapAcceptCancel && inputMgr.swapAcceptCancel)
			{
				if (navLabel == NavigationCode.GAMEPAD_A)
				{
					return NavigationCode.GAMEPAD_B;
				}
				else
				if (navLabel == NavigationCode.GAMEPAD_B)
				{
					return NavigationCode.GAMEPAD_A;
				}
			}
			return navLabel;
		}
		
		private var _isRadialMenu, _doubleTap : Boolean; // NGE
		
		protected function displayKeyboardIcon():void
		{
			var curKbCode:int = _bindingData.keyboard_keyCode;
			
			if (curKbCode > 0)
			{
				var keyLabel:String = KeyboardKeys.getKeyLabel(curKbCode);
				
				if (!clickable)
				{
					if (mcMouseIcon && mcMouseIcon.isMouseKey(curKbCode))
					{
						mcMouseIcon.visible = true;
						mcMouseIcon.keyCode = curKbCode;
						_labelPosition = mcMouseIcon.width + TEXT_PADDING_KEYBOARD;
					}
					else
					{
						mcKeyboardIcon.visible = true;
						mcKeyboardIcon.label = keyLabel;
						_labelPosition = mcKeyboardIcon.width + TEXT_PADDING_KEYBOARD;
					}
					
					if (tfKeyLabel)	tfKeyLabel.visible = false;
					if (mcClickRect) mcClickRect.visible = false;
				}
				else
				{
					if (tfKeyLabel)
					{
						tfKeyLabel.x = KEY_LABEL_PADDING;
						tfKeyLabel.visible = true;
						
						tfKeyLabel.text = keyLabel;
						if (!CoreComponent.isArabicAligmentMode)
						{
							tfKeyLabel.text = "[" + CommonUtils.toUpperCaseSafe(tfKeyLabel.text) + "]";
						}
						else
						{
							tfKeyLabel.text = "*" + CommonUtils.toUpperCaseSafe(tfKeyLabel.text) + "*";
						}
						
						tfKeyLabel.width = tfKeyLabel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						_labelPosition = tfKeyLabel.x + tfKeyLabel.textWidth + TEXT_PADDING_KEYBOARD;
						
						// NGE
						if(_isRadialMenu)
						{
							tfKeyLabel.visible = false;
							tfKeyLabel.width = 0;
							_labelPosition = TEXT_PADDING_KEYBOARD;
						}
						// NGE
					}
					if (mcClickRect)
					{
						mcClickRect.visible = true;
					}
				}
				
				_contentInvalid = false;
				_gpadIcon.visible = false;
				
				updateText();
				
				_currentWidth = mcKeyboardIcon.width + textField.width + TEXT_PADDING_PAD + (_holdDuration > 0 ? tfHoldPrefix.width : 0);
			}
			else
			{
				_contentInvalid = true;
			}
			
			updateVisibility();
		}

		public function updateDataFromStage():void
		{
			if (_displayGamepadCode || _displayKeyboardCode > 0 || _displayGamepadKeyCode > 0 )
			{
				var newBinderData:KeyBindingData = new KeyBindingData();
				newBinderData.actionId = 0;
				newBinderData.gamepad_navEquivalent = _displayGamepadCode;
				newBinderData.keyboard_keyCode = _displayKeyboardCode;
				newBinderData.gamepad_keyCode = _displayGamepadKeyCode;
				newBinderData.label = label ? label : "";
				
				_isGamepad = InputManager.getInstance().isGamepad();
				_dataFromStage = true;
				
				setData(newBinderData, _isGamepad);
				stopHoldAnimation();
			}
		}
		
		protected function updateVisibility():void
		{
			var newVisibilityValue = _actualVisibility && !_contentInvalid
			if (super.visible != newVisibilityValue)
			{
				super.visible = newVisibilityValue;
				UpdateHoldAnimation();
			}
		}

		protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			if (_dataFromStage)
			{
				SetHoldButtonText();
				updateDataFromStage();
			}
		}
		
		override protected function updateText():void
		{
			if (tfHoldPrefix)
			{
				if ((holdDuration > 0 || addHoldPrefix) && _label && textField)
				{
					SetHoldButtonText();
					tfHoldPrefix.textColor = (_overrideTextColor > -1) ? _overrideTextColor : 0xFFFFFF;
					tfHoldPrefix.autoSize = TextFieldAutoSize.LEFT;
					tfHoldPrefix.visible = true;
					tfHoldPrefix.width = tfHoldPrefix.textWidth + CommonConstants.SAFE_TEXT_PADDING;
					tfHoldPrefix.x = _labelPosition;
					textField.x = _labelPosition + tfHoldPrefix.width;
				}
				else
				{
					tfHoldPrefix.visible = false;
					textField.x = _labelPosition;
				}
			}
			
            if (_label != null && textField != null)
			{
				if (_overrideTextColor >= 0)
				{
					textField.textColor = _overrideTextColor
                	textField.text = _label;
				}
				else
				{
					textField.htmlText = _label;
				}
				if (_lowercaseLabels)
				{
					textField.text = CommonUtils.toLowerCaseExSafe(textField.text);
				}
				textField.width = textField.textWidth + TEXT_OFFSET;
				if (mcClickRect && mcClickRect.visible)
				{
					// #Y mcClickRect size changed in code, so we can't provide any animation on stage for it
					var animStateClip:KeyboardButtonClickArea = mcClickRect as KeyboardButtonClickArea;
					if (animStateClip)
					{
						animStateClip.state = state;
						animStateClip.setActualSize(CLICKABLE_BK_OFFSET + textField.x + textField.width, mcClickRect.height);
						mcClickRect.x = 0;
						mcClickRect.y = - mcClickRect.height / 2;
						mcClickRect.visible = true;
					}
					else
					if (mcClickRect)
					{
						mcClickRect.visible = false;
					}
				}
            }
			if (enabled)
			{
				this.filters = []
				alpha = 1;
			}
			else if (this.filters.length < 1)
			{
				var desaturationFilter:ColorMatrixFilter = CommonUtils.getDesaturateFilter();
				this.filters = [desaturationFilter];
				alpha = DISABLED_ALPHA;
			}
        }
		
		private function SpawnHoldAnimationMask():void
		{
			if (_holdIndicatorMask == null)
			{
				_holdIndicatorMask = new Sprite();
				_holdIndicatorMask.x = _holdIndicator.x + _holdIndicator.width / 2;
				_holdIndicatorMask.y = _holdIndicator.y;
				addChild(_holdIndicatorMask);
				_holdIndicator.mask = _holdIndicatorMask;
			}
		}
		
		// private
		public function startHoldAnimation():void
		{
			if (!_holdIndicator)
			{
				trace("GFX Can't find _holdIndicator in the InputFeedbackButton ", parent);
				return;
			}
			
			if (_holdTimer)
			{
				// already started
				return;
			}
			
			stopHoldAnimation(); // reset all
			
			if (!mcHoldAnimation)
			{
				// don't have static mask, create dynamic one
				SpawnHoldAnimationMask();
			}
			else
			{
				mcHoldAnimation.visible = true;
				mcHoldAnimation.gotoAndStop("Idle");
				
				if (clickable && mcClickRect["mcHoldAnim"])
				{
					mcClickRect["mcHoldAnim"].gotoAndStop("Idle");
				}
			}
			
			_holdTimer = new Timer(HOLD_ANIM_INTERVAL);
			_holdTimer.addEventListener(TimerEvent.TIMER, handleHoldTimer, false, 0, true);
			_holdTimer.start();
			
			_holdProgress = 0;
		}
		
		protected function stopHoldAnimation():void
		{
			if (_holdTimer)
			{
				_timerActivated = false;
				_holdTimer.removeEventListener(TimerEvent.TIMER, handleHoldTimer, false);
				_holdTimer.stop();
				_holdTimer = null;
			}
			if (_holdIndicatorMask)
			{
				_holdIndicatorMask.visible = false;
				//removeChild(_holdIndicatorMask);
				//_holdIndicatorMask = null;
			}
			if (_holdIndicator)
			{
				_holdIndicator.visible = false;
			}
			if (mcHoldAnimation)
			{
				mcHoldAnimation.visible = false
				mcHoldAnimation.gotoAndStop("Idle");
				
				if (clickable && mcClickRect["mcHoldAnim"])
				{
					mcClickRect["mcHoldAnim"].gotoAndStop("Idle");
				}
			}
			_holdProgress = 0;
		}
		
		protected function handleHoldTimer(event:TimerEvent):void
		{
			var maxValue:Number = mcHoldAnimation ? HOLD_INT_MAX_FRAME : HOLD_INT_MAX_ANGLE;
			
			if (_holdProgress > maxValue)
			{
				stopHoldAnimation();
				if (holdCallback != null && !_timerActivated)
				{
					holdCallback();
					_timerActivated = true;
				}
				if (mcHoldAnimation)
				{
					mcHoldAnimation.gotoAndPlay("Done");
				}
				return;
			}
			
			if (!mcHoldAnimation)
			{
				SpawnHoldAnimationMask();
			}
			
			if (this.parent == null || this.visible == false)
			{
				return;
			}
			
			UpdateHoldAnimation();
		}
		
		protected function UpdateHoldAnimation()
		{
			var delta:Number;
			var percentage:Number;
						
			
			if ((!_holdIndicator || !_holdIndicatorMask && !mcHoldAnimation) || (mcHoldAnimation && !mcHoldAnimation.visible) || !visible)
			{
				return;
			}
			
			var maxValue:Number = mcHoldAnimation ? HOLD_INT_MAX_FRAME : HOLD_INT_MAX_ANGLE;
			
			delta = maxValue / (_holdDuration / HOLD_ANIM_INTERVAL);
			_holdProgress += delta;
			percentage = Math.min(maxValue, _holdProgress);
			
			if (percentage > 0)
			{
				if (mcHoldAnimation)
				{
					mcHoldAnimation.visible = true;
					mcHoldAnimation.gotoAndStop(HOLD_INT_FIRST_FRAME + percentage);
					if (clickable && mcClickRect["mcHoldAnim"])
					{
						mcClickRect["mcHoldAnim"].gotoAndStop(HOLD_INT_FIRST_FRAME + percentage);
					}
				}
				else
				{
					_holdIndicator.visible = true;
					_holdIndicatorMask.visible = true;
					_holdIndicatorMask.graphics.clear();
					CommonUtils.drawPie(_holdIndicatorMask.graphics, _holdIndicator.width, HOLD_ANIM_STEPS_COUNT, 0, percentage);
				}
			}
			else
			{
				if (mcHoldAnimation)
				{
					mcHoldAnimation.visible = false;
				}
				else
				{
					_holdIndicator.visible = false;
					_holdIndicatorMask.visible = false;
				}
			}
		}
		
		public function handleHoldInput(event:InputEvent):void
		{
			if (!event.handled && _holdDuration > 0 && _bindingData)
			{
				var inputMgr:InputManager = InputManager.getInstance();
				var details:InputDetails = event.details;
				var keyCode:int = details.code;
				var navCode:String = details.navEquivalent;
				
				if (inputMgr.swapAcceptCancel)
				{
					if (navCode == NavigationCode.GAMEPAD_A)
					{
						navCode = NavigationCode.GAMEPAD_B;
						keyCode = KeyCode.PAD_B_CIRCLE;
					}
					else
					if (navCode == NavigationCode.GAMEPAD_B)
					{
						navCode = NavigationCode.GAMEPAD_A;
						keyCode = KeyCode.PAD_A_CROSS;
					}
				}
				
				if (navCode == _bindingData.gamepad_navEquivalent ||
					keyCode == _bindingData.keyboard_keyCode ||
					keyCode == _bindingData.gamepad_keyCode
					)
				{
					if (visible) // #J Don't handle hold events for buttons that are not visible
					{
						if (details.value == InputValue.KEY_DOWN && !_holdTimer)
						{
							startHoldAnimation();
						}
						else if (details.value == InputValue.KEY_UP && _holdTimer)
						{
							stopHoldAnimation();
						}
					}
				}
			}
		}
		
		public function getOccupiedWidth():int 
		{
			return textField.x + textField.textWidth;
		}

		override public function toString():String
		{
			return "InputFeedbackButton [" + this.name +"] _bindingData: " + _bindingData;
		}
	}
}
