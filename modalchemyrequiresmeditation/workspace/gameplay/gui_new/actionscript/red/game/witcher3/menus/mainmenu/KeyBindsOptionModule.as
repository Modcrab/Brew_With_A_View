/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	
	public class KeyBindsOptionModule extends StaticOptionModule
	{
		private var isSettingKeycode:Boolean = false;
		
		public var mcChangingKeybindDialog:MovieClip;
		
		public var mcScrollbar:ScrollBar;
		
		public var mcResetDefaultsButtonPC:InputFeedbackButton;
		public var mcSafetiesEnabledButtonPC:InputFeedbackButton;
		
		protected static const PADDING_BUTTON:Number = 40;
		
		public var mcList:W3ScrollingList;
		public var mcItemRenderer1:KeybindItemRenderer;
		public var mcItemRenderer2:KeybindItemRenderer;
		public var mcItemRenderer3:KeybindItemRenderer;
		public var mcItemRenderer4:KeybindItemRenderer;
		public var mcItemRenderer5:KeybindItemRenderer;
		public var mcItemRenderer6:KeybindItemRenderer;
		public var mcItemRenderer7:KeybindItemRenderer;
		public var mcItemRenderer8:KeybindItemRenderer;
		public var mcItemRenderer9:KeybindItemRenderer;
		public var mcItemRenderer10:KeybindItemRenderer;
		public var mcItemRenderer11:KeybindItemRenderer;

		
		private var _rebindingRenderer:KeybindItemRenderer;
		
		public var _lastMoveWasMouse:Boolean = false;
		
		protected var _smartKeybindingEnabled:Boolean = true;
		public function get smartKeybindingEnabled():Boolean
		{
			return _smartKeybindingEnabled;
		}
		public function set smartKeybindingEnabled(value:Boolean):void
		{
			if (_smartKeybindingEnabled != value)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnSmartKeybindEnabledChanged", [value]));
			}
			
			_smartKeybindingEnabled = value;
			
			
			var finalString:String = "";
			var valueLabel:String = value ? "[[panel_mainmenu_option_value_off]]" : "[[panel_mainmenu_option_value_on]]";
			var testString:TextField = new TextField;			
			//
			testString.text = "[[smart_keybinding_enabled]]";
			finalString += testString.text;
			testString.text = valueLabel;
			finalString += " " + testString.text;
			
			mcSafetiesEnabledButtonPC.label = finalString;
			mcSafetiesEnabledButtonPC.setDataFromStage("", KeyCode.O);
			mcSafetiesEnabledButtonPC.validateNow();
			setButtonPosition();
			
			mcItemRenderer1.safetiesEnabled = value;
			mcItemRenderer2.safetiesEnabled = value;
			mcItemRenderer3.safetiesEnabled = value;
			mcItemRenderer4.safetiesEnabled = value;
			mcItemRenderer5.safetiesEnabled = value;
			mcItemRenderer6.safetiesEnabled = value;
			mcItemRenderer7.safetiesEnabled = value;
			mcItemRenderer8.safetiesEnabled = value;
			mcItemRenderer9.safetiesEnabled = value;
			mcItemRenderer10.safetiesEnabled = value;
			mcItemRenderer11.safetiesEnabled = value;
	
		}
		
		public function get lastMoveWasMouse():Boolean { return _lastMoveWasMouse; }
		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (!_lastMoveWasMouse)
			{
				if (mcList.selectedIndex == -1)
				{
					mcList.selectedIndex = 0;
				}
			}
			else
			{
				mcList.selectedIndex = _lastMouseOveredItem;
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			focusable = false;
			mcChangingKeybindDialog.visible = false;
			mcChangingKeybindDialog.mouseEnabled = false;
			mcChangingKeybindDialog.mouseChildren = false;
			
			var inputButton:InputFeedbackButton = mcChangingKeybindDialog.getChildByName("inputFeedbackBtn") as InputFeedbackButton;
			if (inputButton)
			{
				inputButton.label = "[[panel_common_cancel]]";
				inputButton.setDataFromStage("", KeyCode.ESCAPE);
			}
			
			mcResetDefaultsButtonPC.clickable = true;
			mcResetDefaultsButtonPC.label = "[[menu_option_reset_to_default]]";			
			mcResetDefaultsButtonPC.addEventListener(ButtonEvent.PRESS, handleResetDefaultPressed, false, 0, true);
			mcResetDefaultsButtonPC.setDataFromStage("", KeyCode.R);
			mcResetDefaultsButtonPC.validateNow();
			
			mcSafetiesEnabledButtonPC.clickable = true;
			mcSafetiesEnabledButtonPC.addEventListener(ButtonEvent.PRESS, smartKeybindingPressed, false, 0, true);
			mcSafetiesEnabledButtonPC.setDataFromStage("", KeyCode.O);
			mcSafetiesEnabledButtonPC.validateNow();
			
			if (mcScrollbar)
			{
				mcScrollbar.addEventListener( Event.SCROLL, handleScroll, false, 1, true) ;
			}
		
			
		}
		
		public function setButtonPosition()
		{
			mcResetDefaultsButtonPC.x  = mcSafetiesEnabledButtonPC.x + mcSafetiesEnabledButtonPC.actualWidth + PADDING_BUTTON;
		}
		
		public function showWithData(data:Array):void
		{
			var actionTextField: TextField = getChildByName("tfAction") as TextField;
			var format: TextFormat = new TextFormat();
			
			if(CoreComponent.isArabicAligmentMode)
				format.align = "right";
			else
				format.align = "left";

			actionTextField.setTextFormat(format);
			
			var preSelectedIndex:int = -1;
			var preScrollPosition:int = -1;
			if (!visible)
			{
				super.show();
				
				smartKeybindingEnabled = true;
				
				if (mcList)
				{
					if (mcList.selectedIndex == 0)
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
					}
					
					if (_lastMoveWasMouse)
					{
						mcList.selectedIndex = -1;
					}
					else
					{
						mcList.selectedIndex = 0;
					}
				}
			}
			else
			{
				preSelectedIndex = mcList.selectedIndex;
				preScrollPosition = mcList.scrollPosition;
			}
			
			mcList.dataProvider = new DataProvider(data);
			mcList.validateNow();
			
			registerMouseEvents();
			
			if (preSelectedIndex != -1 || preScrollPosition != -1)
			{
				mcList.selectedIndex = preSelectedIndex;
				mcList.scrollPosition = preScrollPosition;
				validateNow();
			}
		}
		
		override public function hide():void
		{
			super.hide();
			
			unregisteredMouseEvents();
		}
		
		protected var _mouseEventsRegistered:Boolean = false;
		public function registerMouseEvents():void
		{
			
			if (!_mouseEventsRegistered)
			{
				_mouseEventsRegistered = true;
				
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll, true, 1000, true);
				
				registerMouseEventsForItem(mcItemRenderer1);
				registerMouseEventsForItem(mcItemRenderer2);
				registerMouseEventsForItem(mcItemRenderer3);
				registerMouseEventsForItem(mcItemRenderer4);
				registerMouseEventsForItem(mcItemRenderer5);
				registerMouseEventsForItem(mcItemRenderer6);
				registerMouseEventsForItem(mcItemRenderer7);
				registerMouseEventsForItem(mcItemRenderer8);
				registerMouseEventsForItem(mcItemRenderer9);
				registerMouseEventsForItem(mcItemRenderer10);
				registerMouseEventsForItem(mcItemRenderer11);
			
			}
		}
		
		public function unregisteredMouseEvents():void
		{
			if (_mouseEventsRegistered)
			{
				_mouseEventsRegistered = false;
				
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll, false);
				
				unregisterMouseEventsForItem(mcItemRenderer1);
				unregisterMouseEventsForItem(mcItemRenderer2);
				unregisterMouseEventsForItem(mcItemRenderer3);
				unregisterMouseEventsForItem(mcItemRenderer4);
				unregisterMouseEventsForItem(mcItemRenderer5);
				unregisterMouseEventsForItem(mcItemRenderer6);
				unregisterMouseEventsForItem(mcItemRenderer7);
				unregisterMouseEventsForItem(mcItemRenderer8);
				unregisterMouseEventsForItem(mcItemRenderer9);
				unregisterMouseEventsForItem(mcItemRenderer10);
				unregisterMouseEventsForItem(mcItemRenderer11);
			
			}
		}
		
		protected function registerMouseEventsForItem(item:KeybindItemRenderer):void
		{
			item.addEventListener(MouseEvent.CLICK, onItemClicked, false, 0, true);
			item.addEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick, false, 0, true);
			item.doubleClickEnabled = true;
			item.addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver, false, 0, true);
			item.addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut, false, 0, true);
		}
		
		protected function unregisterMouseEventsForItem(item:KeybindItemRenderer):void
		{
			item.removeEventListener(MouseEvent.CLICK, onItemClicked);
			item.removeEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
			item.doubleClickEnabled = false;
			item.removeEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver);
			item.removeEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut);
		}
		
		protected function onItemClicked(event:MouseEvent):void
		{
			if (mcChangingKeybindDialog.visible)
			{
				return;
			}
			
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.MIDDLE_BUTTON)
			{
				var currentTarget:KeybindItemRenderer = event.currentTarget as KeybindItemRenderer;
				if (currentTarget && currentTarget.data)
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnClearKeybind", [uint(currentTarget.data.tag)]));
				}
			}
		}
		
		protected var _lastMouseOveredItem:int = -1;
		protected function onItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:KeybindItemRenderer = event.currentTarget as KeybindItemRenderer;
			
			if (mcChangingKeybindDialog.visible)
			{
				return;
			}
			
			_lastMouseOveredItem = mcList.getRenderers().indexOf(currentTarget);
			
			if (_lastMoveWasMouse)
			{
				mcList.selectedIndex = currentTarget.index;
			}
		}
		
		protected function onItemMouseOut(event:MouseEvent):void
		{
			if (mcChangingKeybindDialog.visible)
			{
				return;
			}
			
			_lastMouseOveredItem = -1;
			
			if (_lastMoveWasMouse)
			{
				mcList.selectedIndex = -1;
			}
		}
		
		protected function onItemDoubleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			
			if (superMouseEvent && superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				startChangingKeybind();
			}
		}
		
		private function handleScroll(e:Event) : void
		{
			mcList.validateNow();
			
			if (_lastMouseOveredItem != -1 && lastMoveWasMouse)
			{
				var currentTarget:KeybindItemRenderer  = mcList.getRendererAt(_lastMouseOveredItem) as KeybindItemRenderer;
				
				if (currentTarget)
				{
					mcList.selectedIndex = currentTarget.index;
					mcList.validateNow();
				}
			}
		}
		
		override public function handleInputNavigate(event:InputEvent):void
		{
			if (!visible)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyUp:Boolean = (details.value == InputValue.KEY_UP);
			
			if (mcChangingKeybindDialog.visible)
			{
				if ( keyUp && !InputManager.getInstance().isGamepad())
				{
					var code:uint;
					code = details.code;
					
					if (details.code == KeyCode.ESCAPE)// || details.navEquivalent == NavigationCode.GAMEPAD_B)
					{
						stopChangingKeybind();
						return;
					}
					else if (details.code == KeyCode.F7 || details.code == KeyCode.F5 || (smartKeybindingEnabled && (
							 details.code == KeyCode.ENTER || details.code == KeyCode.BACKSPACE ||
							 details.code == KeyCode.K || details.code == KeyCode.I || details.code == KeyCode.M || details.code == KeyCode.J || details.code == KeyCode.N || details.code == KeyCode.B || details.code == KeyCode.G || 
							 details.code == KeyCode.H || details.code == KeyCode.L || details.code == KeyCode.O)))
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, "OnInvalidKeybindTried", [code]));
						return;
					}
					
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnChangeKeybind", [uint(_rebindingRenderer.data.tag), code]));
					stopChangingKeybind();
				}
			}
			else
			{
				if (!event.handled && keyUp)
				{
					if ((details.code == KeyCode.ENTER || details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.E))
					{
						startChangingKeybind();
					}
					else if (details.code == KeyCode.R)
					{
						resetKeybinds();
					}
					else if (details.code == KeyCode.O)
					{
						smartKeybindingEnabled = !smartKeybindingEnabled;
					}
				}
				
				CommonUtils.convertWASDCodeToNavEquivalent(details);
				
				mcList.handleInput(event);
				
				if (!event.handled)
				{
					super.handleInputNavigate(event);
				}
			}
		}
		
		protected function onMouseScroll(event:MouseEvent):void
		{
			if (mcChangingKeybindDialog.visible)
			{
				event.stopImmediatePropagation();
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnChangeKeybind", [uint(_rebindingRenderer.data.tag), KeyCode.MOUSEZ]));
				stopChangingKeybind();
			}
		}
		
		protected function startChangingKeybind():void
		{
			if (mcChangingKeybindDialog.visible)
			{
				return;
			}
			
			_rebindingRenderer = mcList.getSelectedRenderer() as KeybindItemRenderer;
			
			if (!_rebindingRenderer || _rebindingRenderer.data == null)
			{
				return;
			}
			
			if (_rebindingRenderer.data.locked && (smartKeybindingEnabled || _rebindingRenderer.data.permaLocked))
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnLockedKeybindTried"));
			}
			else if (_rebindingRenderer.isReset)
			{
				resetKeybinds();
			}
			else
			{
				var messageTextField:TextField = mcChangingKeybindDialog.getChildByName("textField") as TextField;
				
				if (messageTextField)
				{
					messageTextField.htmlText = "[[press_any_key_to_bind_message]]";
					messageTextField.htmlText = messageTextField.htmlText +_rebindingRenderer.data.label;
					//messageTextField.htmlText.concat(": " + _rebindingRenderer.data.label);
				}
				
				mcChangingKeybindDialog.visible = true;
			}
		}
		
		protected function handleResetDefaultPressed( event : ButtonEvent ) : void
		{
			resetKeybinds();
		}
		
		protected function smartKeybindingPressed( event : ButtonEvent ) : void
		{
			smartKeybindingEnabled = !smartKeybindingEnabled;
		}
		
		protected function resetKeybinds():void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnResetKeybinds"));
		}
		
		protected function stopChangingKeybind():void
		{
			if (!mcChangingKeybindDialog.visible)
			{
				return;
			}
			
			mcChangingKeybindDialog.visible = false;
			_rebindingRenderer = null;
		}
		
		override public function onRightClick(event:MouseEvent):void
		{
			if (!mcChangingKeybindDialog.visible)
			{
				super.onRightClick(event);
			}
		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			
			if (superMouseEvent == null)
			{
				return;
			}
			
			if (mcChangingKeybindDialog.visible && _rebindingRenderer != null && _rebindingRenderer.data != null)
			{			
				var code:uint;
				
				switch (superMouseEvent.buttonIdx)
				{
					case MouseEventEx.LEFT_BUTTON:
						code = KeyCode.LEFT_MOUSE;
						break;
					case MouseEventEx.RIGHT_BUTTON:
						code = KeyCode.RIGHT_MOUSE;
						break;
					case MouseEventEx.MIDDLE_BUTTON:
						code = KeyCode.MIDDLE_MOUSE;
						break;
				}
				
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnChangeKeybind", [uint(_rebindingRenderer.data.tag), code]));
				
				stopChangingKeybind();
			}
		}
	}
}