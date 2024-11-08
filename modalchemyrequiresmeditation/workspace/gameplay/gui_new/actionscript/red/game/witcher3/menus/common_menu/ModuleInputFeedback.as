package red.game.witcher3.menus.common_menu
{
	import com.gskinner.motion.easing.Back;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	/**
	 * red.game.witcher3.menus.common_menu.ModuleInputFeedback
	 * Input feedback; Common menu module
	 * @author Yaroslav Getsevich
	 */
	public class ModuleInputFeedback extends UIComponent
	{
		protected static const BUTTON_CONTENT_REF:String = "InputFeedbackButtonRef";
		protected static const BUTTONS_PADDING:Number = 15;
		
		protected var _hotkeyMap:Object;
		protected var _gpadSortMap:Vector.<String>;
		protected var _kbSortMap:Vector.<int>;
		protected var _buttonsList:Vector.<InputFeedbackButton>;
		protected var _data:Array;
		protected var _isGamepad:Boolean;
		protected var _isAcceptCancelSwapped:Boolean;
		protected var _platform:uint;
		protected var _commonButtons:Array;
		protected var _canvas:Sprite;
		protected var _cachedWidth:Number;
		protected var _buttonAlign:String;
		protected var _directWsCall:Boolean = true;
		protected var _emulateInputEvent:Boolean = true;
		protected var _lowercaseLabels:Boolean = false;
		protected var _clickable:Boolean = true;
		
		protected var _isVisible:Boolean;
		protected var _isActualVisibility:Boolean;
		protected var _coloringButtons:Boolean;
		protected var _showBackground:Boolean;
		
		public var filterKeyCodeFunction:Function;
		public var filterNavCodeFunction:Function;
		public var mcInputBackground:MovieClip;
		
		public function ModuleInputFeedback()
		{
			_hotkeyMap = { };
			_canvas = new Sprite();
			_commonButtons = [];
			_buttonsList = new Vector.<InputFeedbackButton>;
			_cachedWidth = this.width;
			addChild(_canvas);
			initSortMaps();
			
			tabEnabled = tabChildren = false;
			_isVisible = true;
			
			visible = false;
		}
		
		public function get buttonsContainer():Sprite { return _canvas };
		
		public function addHotkey(originKey:uint, additionalKey:uint):void
		{
			var curLinks:Array = _hotkeyMap[originKey];
			if (curLinks && curLinks.indexOf(additionalKey) < 0)
			{
				curLinks.push(additionalKey);
			}
			else
			{
				_hotkeyMap[originKey] = [additionalKey];
			}
		}
		
		public function setVisibility(value:Boolean):void
		{
			_isVisible = value;
			updateVisibility();
		}
		
		override public function set visible(value:Boolean):void
		{
			_isActualVisibility = value;
			updateVisibility();
		}
		
		protected function updateVisibility():void
		{
			super.visible = _isActualVisibility && _isVisible;
		}
		
		public function get clickable():Boolean { return _clickable }
		public function set clickable(value:Boolean):void
		{
			_clickable = value;
		}
		
		public function get lowercaseLabels():Boolean { return _lowercaseLabels }
		public function set lowercaseLabels(value:Boolean):void
		{
			_lowercaseLabels = value;
		}
		
		public function get emulateInputEvent():Boolean { return _emulateInputEvent }
		public function set emulateInputEvent(value:Boolean):void
		{
			_emulateInputEvent = value;
		}
		
		[Inspectable(defaultValue = "true")]
		/**
		 * If true call WS directly
		 */
		public function get directWsCall():Boolean { return _directWsCall }
		public function set directWsCall(value:Boolean):void
		{
			_directWsCall = value;
		}
		
		[Inspectable(defaultValue="center", enumeration="left,right,center")]
        public function get buttonAlign():String { return _buttonAlign; }
        public function set buttonAlign(value:String):void {
            if (value == _buttonAlign) { return; }
            _buttonAlign = value;
            repositionButtons();
        }
		
		public function get coloringButtons():Boolean
		{
			return _coloringButtons;
		}
		
		public function set coloringButtons(value:Boolean):void
		{
			_coloringButtons = value;
		}
		
		public function get showBackground():Boolean { return _showBackground; }
		public function set showBackground(value:Boolean):void
		{
			_showBackground = value;
			updateBackgroundVisibility();
		}

		public function handleSetupButtons(gameData:Object):void
		{
			_data = gameData as Array;
			populateData(false);
		}
		
		public function appendButton(actionId:int, gpadCode:String, kbCode:int, label:String, update:Boolean = false, contextId:int = -1):void
		{
			var newButton  : KeyBindingData = new KeyBindingData();
			var isExist	   : Boolean;
			var needUpdate : Boolean;
			var len 	   : int = _commonButtons.length;
			
			newButton.actionId = actionId;
			newButton.level = 0;
			newButton.gamepad_navEquivalent = gpadCode;
			newButton.keyboard_keyCode = kbCode;
			newButton.label = label;
			newButton.contextId = contextId;
			
			for (var i = 0; i < len; i++)
			{
				var curBinding:KeyBindingData = _commonButtons[i];
				if (curBinding.actionId == actionId && (curBinding.contextId == contextId || contextId == -1))
				{
					_commonButtons[i] = newButton;
					
					var buttonsCount:int = _buttonsList.length;
					var curButton:InputFeedbackButton = getButtonByData(curBinding);
					if (curButton)
					{
						curButton.setData(newButton, InputManager.getInstance().isGamepad() );
						tryApplyButtonColor(curButton);
						curButton.validateNow();
					}
					
					needUpdate = false;
					isExist = true;
					break;
				}
			}
			
			if (!isExist)
			{
				_commonButtons.push(newButton);
				createButton(newButton);
				needUpdate = true;
			}
			
			if (update)
			{
				repositionButtons();
				
				if (needUpdate)
				{
					populateData();
				}
			}
		}

		public function removeButton(actionId:int, update:Boolean = false, contextId:int = -1):Boolean
		{
			var len:int = _commonButtons.length;
			var needUpdate:Boolean = false;
			
			for (var i:int = 0; i < len; i++)
			{
				var curBinding:KeyBindingData = _commonButtons[i];
				
				if (curBinding.actionId == actionId && (curBinding.contextId == contextId || contextId == -1))
				{
					_commonButtons.splice(i, 1);
					
					var buttonsCount:int = _buttonsList.length;
					
					for (var j:int = 0; j < buttonsCount; j++)
					{
						var curButton:InputFeedbackButton = _buttonsList[j];
						
						if (curButton && curButton.getBindingData().actionId == actionId)
						{
							curButton.removeEventListener( MouseEvent.CLICK, handleButtonClick);
							_canvas.removeChild(curButton);
							_buttonsList.splice(j, 1);
							needUpdate = true;
							
							break;
						}
					}
					break;
				}
			}
			if (update && needUpdate)
			{
				repositionButtons();
			}
			
			return needUpdate;
		}
		
		public function disableButton(actionId:int, value:Boolean, contextId:int = -1):void
		{
			var len : int = _commonButtons.length;
			for (var i = 0; i < len; i++)
			{
				var curBinding:KeyBindingData = _commonButtons[i];
				if (curBinding.actionId == actionId && (curBinding.contextId == contextId || contextId == -1))
				{
					curBinding.disabled = value;
					break;
				}
			}
			populateData();
		}
		
		public function removeAllContextButtons(contextId:int):void
		{
			var i:int = 0;
			while (i < _commonButtons.length)
			{
				
				var curBinding:KeyBindingData = _commonButtons[i];
				//trace("GFX --- removeAllContextButtons ", contextId, curBinding.contextId, "[ ", i, "]");
				if (curBinding.contextId == contextId)
				{
					_commonButtons.splice(i, 1);
				}
				else
				{
					i++;
				}
			}
			
			populateData();
		}
		
		public function refreshButtonList():void
		{
			populateData();
		}
		
		public function clearAllButtons():void
		{
			_commonButtons.length = 0;
		}
		
		public function cleanupButtons():void
		{
			var len:int = _buttonsList.length;
			for (var i:int = 0; i < len; i++)
			{
				_canvas.removeChild(_buttonsList[i]);
			}
			_buttonsList.length = 0;
		}

		override protected function configUI():void
		{
			super.configUI();
			
			_isAcceptCancelSwapped = InputManager.getInstance().swapAcceptCancel;
			_platform = InputManager.getInstance().getPlatform();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			if (!Extensions.isScaleform)
			{
				showDebugData();
			}
		}

		// #Y Constants?
		private function initSortMaps():void
		{
			_gpadSortMap = new Vector.<String>;
			_kbSortMap = new Vector.<int>;
			
			_gpadSortMap.push(NavigationCode.GAMEPAD_START);
			_gpadSortMap.push(NavigationCode.GAMEPAD_BACK);
			_gpadSortMap.push(NavigationCode.GAMEPAD_B);
			_gpadSortMap.push(NavigationCode.GAMEPAD_RBLB);
			_gpadSortMap.push(NavigationCode.GAMEPAD_RTLT);
			_gpadSortMap.push(NavigationCode.GAMEPAD_R1);
			_gpadSortMap.push(NavigationCode.GAMEPAD_L1);
			_gpadSortMap.push(NavigationCode.GAMEPAD_R2);
			_gpadSortMap.push(NavigationCode.GAMEPAD_L2);
			_gpadSortMap.push(NavigationCode.GAMEPAD_R3);
			_gpadSortMap.push(NavigationCode.GAMEPAD_L3);
			_gpadSortMap.push(NavigationCode.GAMEPAD_LSTICK_HOLD);
			_gpadSortMap.push(NavigationCode.GAMEPAD_RSTICK_HOLD);
			_gpadSortMap.push(NavigationCode.GAMEPAD_RSTICK_SCROLL);
			_gpadSortMap.push(NavigationCode.GAMEPAD_RSTICK_TAB);
			_gpadSortMap.push(NavigationCode.GAMEPAD_LSTICK_SCROLL);
			_gpadSortMap.push(NavigationCode.GAMEPAD_LSTICK_TAB);
			_gpadSortMap.push(NavigationCode.DPAD_DOWN);
			_gpadSortMap.push(NavigationCode.DPAD_LEFT);
			_gpadSortMap.push(NavigationCode.DPAD_RIGHT);
			_gpadSortMap.push(NavigationCode.DPAD_UP);
			_gpadSortMap.push(NavigationCode.GAMEPAD_Y);
			_gpadSortMap.push(NavigationCode.GAMEPAD_X);
			_gpadSortMap.push(NavigationCode.GAMEPAD_A);
			
			_kbSortMap.push(KeyCode.ESCAPE);
			_kbSortMap.push(KeyCode.PAGE_DOWN);
			_kbSortMap.push(KeyCode.PAGE_UP);
			_kbSortMap.push(KeyCode.UP);
			_kbSortMap.push(KeyCode.DOWN);
			_kbSortMap.push(KeyCode.LEFT);
			_kbSortMap.push(KeyCode.RIGHT);
			_kbSortMap.push(KeyCode.ENTER);
		}
		
		protected function populateData(hardReset:Boolean = true):void
		{
			if (!_data && (_commonButtons.length <= 0))
			{
				visible = false;
				InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, handleInput, false);
				return;
			}
			try
			{
				var dataArray:Array = _data as Array;
				var finalList:Array;
				
				_isGamepad = InputManager.getInstance().isGamepad();
				finalList = prepareButtonsList(dataArray, _commonButtons, _isGamepad);
				
				if (_isGamepad)
				{
					finalList.sort(sortForGPad);
				}
				else
				{
					finalList.sort(sortForKeyboard);
				}
				
				if (hardReset)
				{
					cleanupButtons();
					respawnButtons(finalList);
				}
				else
				{
					updateButtons(finalList);
				}
				
				repositionButtons();
				visible = _buttonsList.length > 0;
				if (visible)
				{
					InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 10, true);
				}
				else
				{
					InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, handleInput, false);
				}
			}
			catch (er:Error)
			{
				// ignore all errors to avoid menu opening interruption
				trace("GFX WARNING: Can't create InputFeedback module in " + parent + "! ", er.message);
				visible = false;
				InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, handleInput, false);
			}
		}
		
		// after hard reset only
		protected function respawnButtons(dataList:Array):void
		{
			var len:int = dataList.length;
			for (var i:int = 0; i < len; i++)
			{
				var curData:KeyBindingData = dataList[i] as KeyBindingData;
				createButton(curData);
			}
		}
		
		// update existing buttons list
		protected function updateButtons(dataList:Array):void
		{
			var len:int = dataList.length;
			var updatedButtons:Dictionary = new Dictionary(true);
			
			for (var i:int = 0; i < len; i++)
			{
				var curData:KeyBindingData = dataList[i] as KeyBindingData;
				var existedButton:InputFeedbackButton = getButtonByData(curData);
				
				if (existedButton)
				{
					existedButton.setData(curData, _isGamepad);
					existedButton.label = curData.label;
					existedButton.validateNow();
					tryApplyButtonColor(existedButton);
					
					updatedButtons[existedButton] = true;
				}
				else
				{
					updatedButtons[createButton(curData)] = true;
				}
			}
			
			len = _buttonsList.length;
			for (var j:int = 0; j < len; j++)
			{
				var curButton:InputFeedbackButton = _buttonsList[j];
				if (curButton && !updatedButtons[curButton])
				{
					curButton.removeEventListener( MouseEvent.CLICK, handleButtonClick);
					_canvas.removeChild(curButton);
					_buttonsList.splice(j, 1);
					
					j--;
					len--;
				}
			}
		}
		
		protected function createButton(targetData:KeyBindingData):InputFeedbackButton
		{
			var ClassRef:Class = getDefinitionByName(BUTTON_CONTENT_REF) as Class;
			var mcButton:InputFeedbackButton = new ClassRef() as InputFeedbackButton;
			
			mcButton.clickable = clickable;
			mcButton.setData(targetData, _isGamepad);
			mcButton.lowercaseLabels = _lowercaseLabels;
			mcButton.addEventListener( MouseEvent.CLICK, handleButtonClick, false, 10, true);
			
			if (targetData.disabled)
			{
				mcButton.enabled = false;
			}
			
			tryApplyButtonColor(mcButton);
			_canvas.addChild(mcButton);
			_buttonsList.push(mcButton);
			
			
			return mcButton;
		}
		
		protected function tryApplyButtonColor(button:InputFeedbackButton):void
		{
			if (coloringButtons)
			{
				var curData:KeyBindingData = button.getBindingData();
				
				if (curData)
				{
					var textColor:Number = getColorByNavCode(curData.gamepad_navEquivalent);
					
					if (textColor != -1)
					{
						button.overrideTextColor = textColor;
					}
					else
					{
						button.overrideTextColor = -1;
					}
					
					button.invalidateData();
				}
			}
		}

		protected function prepareButtonsList(sourceList:Array, commonButtons:Array, isGamepad:Boolean):Array
		{
			var sourceCopy:Array = [];
			var resultArray:Array = [];
			var keyField:String = isGamepad ? "gamepad_navEquivalent" : "keyboard_keyCode";
			var originListCount:int = sourceList ? sourceList.length : 0;
			var i:int;

			for (i = 0; i <  originListCount; i++)
			{
				sourceCopy.push(sourceList[i]);
			}
			for (i = 0; i < commonButtons.length; i++)
			{
				sourceCopy.push(commonButtons[i]);
			}
			
			while (sourceCopy.length > 0)
			{
				var curData:KeyBindingData = sourceCopy.pop() as KeyBindingData;
				var curKeyValue:* = curData[keyField];
				
				if (curKeyValue && curKeyValue != -1)
				{
					i = 0;
					while (i < sourceCopy.length)
					{
						var subItem:KeyBindingData = sourceCopy[i] as KeyBindingData;
						
						if ( ( curKeyValue == subItem[keyField] ) && ( curData.hasHoldPrefix == subItem.hasHoldPrefix ) )
						{
							if (curData.level < subItem.level)
							{
								curData = subItem;
							}
							else
							if (curData.level == subItem.level && curData.actionId < subItem.actionId)
							{
								curData = subItem;
							}
							sourceCopy.splice(i, 1);
						}
						else
						{
							i++;
						}
					}
					if (curData)
					{
						resultArray.push(curData);
						curData = null;
					}
				}
			}
			return resultArray;
		}

		protected function sortForGPad(a:Object, b:Object):int
		{
			var idxA:int = _gpadSortMap.indexOf(a.gamepad_navEquivalent);
			var idxB:int = _gpadSortMap.indexOf(b.gamepad_navEquivalent);

			// If don't find, make it last element
			if (idxA == -1) idxA = _gpadSortMap.length + 1;
			if (idxB == -1)	idxB = _gpadSortMap.length + 1;

			if (idxA > idxB)
			{
				return 1;
			}
			else if (idxA < idxB)
			{
				return -1;
			}
			return 0;
		}

		protected function sortForKeyboard(a:Object, b:Object):int
		{
			var idxA:int = _kbSortMap.indexOf(a.keyboard_keyCode);
			var idxB:int = _kbSortMap.indexOf(b.keyboard_keyCode);

			// If don't find, make it last element
			if (idxA == -1) idxA = _kbSortMap.length + 1;
			if (idxB == -1)	idxB = _kbSortMap.length + 1;

			if (idxA > idxB)
			{
				return 1;
			}
			else if (idxA < idxB)
			{
				return -1;
			}
			return 0;
		}

		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			if ( ( _isGamepad != event.isGamepad || _isAcceptCancelSwapped != InputManager.getInstance().swapAcceptCancel || _platform != InputManager.getInstance().getPlatform() ) && (_data || _commonButtons.length) )
			{
				_isAcceptCancelSwapped = InputManager.getInstance().swapAcceptCancel;
				populateData();
			}
		}
		
		protected function repositionButtons() : void
		{
			var curPosX:Number = 0;
			var len:int = _buttonsList.length;
			var buttonsSize:Number = 0;
			
			for (var i:int = 0; i < len; i++)
			{
				var curButton:InputFeedbackButton = _buttonsList[i];
				
				curButton.validateNow();
				curPosX += (-curButton.getViewWidth() - (i != 0 ? BUTTONS_PADDING : 0));
				curButton.x = curPosX;
				
				buttonsSize += (curButton.getViewWidth() + (i != 0 ? BUTTONS_PADDING : 0));
			}

			switch( _buttonAlign )
			{
				case "center" :
					_canvas.x = - ((_cachedWidth - buttonsSize) / 2);
					break;
				case "left" :
					_canvas.x = -_cachedWidth + buttonsSize;
					break;
				case "right" :
					_canvas.x = 0;
					break;
			}
			
			updateBackgroundVisibility();
		}
		
		protected function updateBackgroundVisibility():void
		{
			if( mcInputBackground )
			{
				if ( _buttonsList.length && _showBackground)
				{
					var containerBounds:Rectangle = _canvas.getBounds( this );
					
					mcInputBackground.x = containerBounds.x;
					mcInputBackground.y = containerBounds.y;
					mcInputBackground.width = containerBounds.width;
					mcInputBackground.height = containerBounds.height;
					mcInputBackground.visible = true;
				}
				else
				{
					mcInputBackground.visible = false;
				}
			}
		}
		
		protected function getButtonByData(buttonData:KeyBindingData):InputFeedbackButton
		{
			var len:int = _buttonsList.length;
			var keyField:String = _isGamepad ? "gamepad_navEquivalent" : "keyboard_keyCode";
			var targetKeyValue:* = buttonData[keyField];
			
			for (var i:int = 0; i < len; i++ )
			{
				var curButton:InputFeedbackButton = _buttonsList[i];
				var curData:KeyBindingData = curButton.getBindingData();
				var curKeyValue:* = curData[keyField];
				
				if ( curData && ( targetKeyValue == curKeyValue ) && ( buttonData.hasHoldPrefix == curData.hasHoldPrefix ) )
				{
					return curButton;
				}
			}
			
			return null;
		}

		protected function handleButtonClick(event:MouseEvent):void
		{
			if (!_isGamepad)
			{
				var mcButton:InputFeedbackButton = event.currentTarget as InputFeedbackButton;
				var bindingData:KeyBindingData = mcButton.getBindingData();
				if (bindingData && mcButton.clickable)
				{
					activateButton(bindingData, null, true);
					if (_emulateInputEvent)
					{
						var fakeInputDetails:InputDetails = new InputDetails("key", bindingData.keyboard_keyCode, InputValue.KEY_UP, bindingData.gamepad_navEquivalent);
						var fakeInputEvent:InputEvent = new InputEvent(InputEvent.INPUT, fakeInputDetails);
						InputDelegate.getInstance().dispatchEvent(fakeInputEvent);
					}
				}
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			
			var details:InputDetails = event.details;
			var keyUp:Boolean = (details.value == InputValue.KEY_UP);
			
			if (filterKeyCodeFunction != null && filterNavCodeFunction != null)
			{
				if (!filterKeyCodeFunction(details.code) || !filterNavCodeFunction(details.navEquivalent))
				{
					return;
				}
			}
			
			//trace("GFX [", this, "] handleInput ", details.navEquivalent, details.code, keyUp);
			if ((details.navEquivalent || details.code) && keyUp)
			{
				var curBindingData:KeyBindingData = getBindingData(details.navEquivalent, details.code);
				if (curBindingData)
				{
					activateButton(curBindingData);
					InputManager.getInstance().reset();
				}
			}
		}
		
		protected function activateButton(keyBinding:KeyBindingData, inputEvent:InputEvent = null, isMouseEvent:Boolean = false):void
		{
			//trace("GFX activateButton ", keyBinding, _directWsCall);
			if (_directWsCall)
			{
				var actionId:uint = keyBinding.actionId ? keyBinding.actionId : 0;
				var kbCode:int = keyBinding.keyboard_keyCode ? keyBinding.keyboard_keyCode : 0;
				
				var finNavEquivalent:String = keyBinding.gamepad_navEquivalent;
				var finKbCode:uint = kbCode;
				if (InputManager.getInstance().swapAcceptCancel)
				{
					if (finNavEquivalent == NavigationCode.GAMEPAD_A)
					{
						finNavEquivalent == NavigationCode.GAMEPAD_B;
						finKbCode = KeyCode.PAD_B_CIRCLE;
					}
					else
					if (finNavEquivalent == NavigationCode.GAMEPAD_B)
					{
						finNavEquivalent == NavigationCode.GAMEPAD_A;
						finKbCode = KeyCode.PAD_A_CROSS;
					}
					
				}
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnInputHandled', [keyBinding.gamepad_navEquivalent, finKbCode, actionId] ) );
			}
			
			// bubble it!
			var inputFeedbackEvent:InputFeedbackEvent = new InputFeedbackEvent(InputFeedbackEvent.USER_ACTION, true, false);
			inputFeedbackEvent.inputEventRef = inputEvent;
			inputFeedbackEvent.actionId = keyBinding.actionId;
			inputFeedbackEvent.isMouseEvent = isMouseEvent;
			dispatchEvent(inputFeedbackEvent);
		}
		
		protected function getBindingData(navEq:String = "", navCode:int = 0):KeyBindingData
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			var len:int = _buttonsList.length;
			var curBindingData:KeyBindingData;
			
			for (var i:int = 0; i < len; i++)
			{
				curBindingData = _buttonsList[i].getBindingData();
				if (curBindingData)
				{
					var curLinks:Array = _hotkeyMap[curBindingData.keyboard_keyCode];
					var hotkeyLinkExist:Boolean = false;
					if (curLinks)
					{
						hotkeyLinkExist = curLinks.indexOf(navCode) > -1;
					}
					
					if ((isGamepad && curBindingData.gamepad_navEquivalent == navEq) ||
						(!isGamepad && (hotkeyLinkExist || curBindingData.keyboard_keyCode == navCode)))
					{
						return curBindingData;
					}
				}
			}
			
			// binding not found, if it is GPAD_B / Esc — pass it anyway
			if (navEq == NavigationCode.GAMEPAD_B || navCode == KeyCode.ESCAPE)
			{
				curBindingData = new KeyBindingData();
				curBindingData.gamepad_navEquivalent = NavigationCode.GAMEPAD_B;
				curBindingData.keyboard_keyCode = KeyCode.ESCAPE;
				return curBindingData;
			}
			return null;
		}
		
		override public function toString():String
		{
			return "[W3 ButtonContainerModule]<", this, ">";
		}
		
		protected function showDebugData():void
		{
			appendButton(0, NavigationCode.GAMEPAD_RSTICK_HOLD, -1, "Ok", false);
			appendButton(1, NavigationCode.GAMEPAD_LSTICK_HOLD, -1, "Cancel", false);
			visible = true;
		}
		
		protected function getColorByNavCode(navCode:String):Number
		{
			var res:Number = -1;
			
			switch(navCode)
			{
			   case NavigationCode.GAMEPAD_A:
				   res = 0x1c971c;
				   break;
			   case NavigationCode.GAMEPAD_B:
				   res = 0x9e2828;
				   break;
			}
		
		   return res;
		}
		
	}

}
