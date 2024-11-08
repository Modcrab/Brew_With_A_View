package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.KeyboardKeys;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.managers.InputDelegate;
	
	/**
	 * red.game.witcher3.controls.HintButton
	 * Simple input feedback button, used in ControlsFeedback HUD module
	 * @author Getsevich Yaroslav
	 */
	public class HintButton extends UIComponent
	{
		protected const ICON_PADDING:Number = 5;
		protected const BACKGROUND_PADDING:Number = 25;
		protected const BACKGROUND_MIN_SIZE:Number = 120;
		
		public var mcBackground:MovieClip;
		public var textField:TextField;
		
		public var mcIconSteam:MovieClip;
		public var mcIconXbox:MovieClip;
		public var mcIconPS:MovieClip;
		public var mcMouseIcon1:KeyboardButtonMouseIcon;
		public var mcMouseIcon2:KeyboardButtonMouseIcon;
		public var mcKeyboardIcon1:KeyboardButtonIcon;
		public var mcKeyboardIcon2:KeyboardButtonIcon;
		
		protected var _label:String;
		protected var _isInvalid:Boolean;
		protected var _icons:Vector.<MovieClip>;
		protected var _keyBinding:KeyBindingData;
		
		public function HintButton()
		{
			_isInvalid = false;
			_icons = new Vector.<MovieClip>;
			
			visible = false;
			if (mcIconXbox) mcIconXbox.visible = false;
			if (mcIconPS) mcIconPS.visible = false;
			if (mcIconSteam) mcIconSteam.visible = false;
			if (mcMouseIcon1) mcMouseIcon1.visible = false;
			if (mcMouseIcon2) mcMouseIcon2.visible = false;
			if (mcKeyboardIcon1) mcKeyboardIcon1.visible = false;
			if (mcKeyboardIcon2) mcKeyboardIcon2.visible = false;
		}
		
		public function get label():String { return _label }
		public function set label(value:String):void
		{
			_label = value;
			textField.htmlText = _label;
			
			//textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			//textField.x = - textField.textWidth;
			
			mcBackground.width = Math.max(BACKGROUND_MIN_SIZE, (textField.textWidth + ICON_PADDING));
		}
		
		public function get keyBinding():KeyBindingData { return _keyBinding }
		public function set keyBinding(value:KeyBindingData):void
		{
			_keyBinding = value;
			populateData();
		}
		
		protected function populateData():void
		{
			cleanup();
			
			if (!_keyBinding)
			{
				trace("GFX HintButton [", this, "] no data to populate");
				return;
			}
			
			var inputMgr:InputManager = InputManager.getInstance();
			var isGamepad:Boolean = inputMgr.isGamepad();
			var isSucceed:Boolean = false;
			
			if (isGamepad)
			{
				isSucceed = setupGamepadIcon();
			}
			else
			{
				isSucceed = setupKeyboardIcon();
			}
			
			_isInvalid = !isSucceed;
			visible = isSucceed;
			
			if (isSucceed)
			{
				alignIcons();
			}
		}
		
		protected function setupGamepadIcon():Boolean
		{
			var inputMgr:InputManager = InputManager.getInstance();
			var isPlayStation:Boolean = inputMgr.isPsPlatform() || inputMgr.isPsGamepad();
			var targetIcon:MovieClip =  getCurrentPadIcon();
			var targetLabel:String;
			
			if (keyBinding.gamepad_navEquivalent)
			{
				targetLabel = getPadIconFrameLabel(keyBinding.gamepad_navEquivalent)
			}
			else
			if (keyBinding.gamepad_keyCode)
			{
				var curGpadNavCode:String = InputDelegate.getInstance().inputToNav( "key", keyBinding.gamepad_keyCode );
				targetLabel = getPadIconFrameLabel(curGpadNavCode);
			}
			else
			{
				return false;
			}
			
			if (targetLabel)
			{
				targetIcon.gotoAndStop(targetLabel);
				targetIcon.visible = true;
				_icons.push(targetIcon);
			}
			else
			{
				return false;
			}
			
			return true;
		}
		
		protected function getCurrentPadIcon():MovieClip
		{
			var curGamepadType:uint = InputManager.getInstance().gamepadType;
			
			switch (curGamepadType)
			{
				case EInputDeviceType.IDT_PS4:
				case EInputDeviceType.IDT_PS5:
					return mcIconPS;
				case EInputDeviceType.IDT_Xbox1:
					return mcIconXbox;
				case EInputDeviceType.IDT_Steam:
					return mcIconSteam;
				default:
					return mcIconXbox;
			}
		}
		
		protected function setupKeyboardIcon():Boolean
		{
			addKeyboardIcon(keyBinding.keyboard_keyCode);
			
			if (keyBinding.altKeyCode)
			{
				addKeyboardIcon(keyBinding.altKeyCode, true);
			}
			
			return true;
		}
		
		protected function addKeyboardIcon(keyCode:uint, isAdditional:Boolean = false):void
		{
			if (isMouseKey(keyCode))
			{
				var targetMouseIcon:KeyboardButtonMouseIcon = isAdditional ? mcMouseIcon1 : mcMouseIcon2;
				
				targetMouseIcon.keyCode = keyCode;
				targetMouseIcon.visible = true;
				_icons.push(targetMouseIcon);
			}
			else
			{
				var keyLabel:String = KeyboardKeys.getKeyLabel(keyCode);
				var targetKbIcon:KeyboardButtonIcon = isAdditional ? mcKeyboardIcon1 : mcKeyboardIcon2;
				
				targetKbIcon.label = keyLabel;
				targetKbIcon.visible = true;
				_icons.push(targetKbIcon);
			}
		}
		
		protected function cleanup():void
		{
			while (_icons.length)
			{
				_icons.pop().visible = false;
			}
		}
		
		protected function alignIcons():void
		{
			var curWidth:Number = 0;
			var len:int = _icons.length;
			
			for (var i:int = 0; i < len; i++ )
			{
				var targetIcon:MovieClip = _icons[i];
				var hitArea:Sprite = targetIcon["viewrect"] as Sprite;
				
				if (hitArea)
				{
					targetIcon.x = curWidth + hitArea.width / 2;
					curWidth += (hitArea.width + ICON_PADDING);
				}
				else
				{
					targetIcon.x = curWidth;
					curWidth += (targetIcon.width + ICON_PADDING);
				}
			}
		}
		
		private function getPadIconFrameLabel(navLabel:String):String
		{
			return navLabel;
			
			/*
			 *  Don't need it now for HUD
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
			*/
		}
		
		private function isMouseKey(keyCode:uint):Boolean
		{
			return keyCode >= KeyCode.LEFT_MOUSE && keyCode <= KeyCode.MIDDLE_MOUSE || keyCode == KeyCode.MOUSE_WHEEL_UP || keyCode == KeyCode.MOUSE_WHEEL_DOWN || keyCode == KeyCode.MOUSE_PAN || keyCode == KeyCode.MOUSE_SCROLL;
		}
		
		
	}
}
