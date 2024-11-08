package red.game.witcher3.menus.common_menu
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3Background;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.controls.W3UILoader;

	/**
	 * Common top menu
	 * @author Getsevich Yaroslav
	 */
	public class MenuCommon extends CoreMenu
	{
		protected static const SUBMENU_CLASS_REF:String = "SubMenuRef";
		
		public var mcCloseBtn:ConditionalCloseButton;
		public var mcMenuHub:MenuHub;
		public var mcPlayerDetails:MenuPlayerStats;
		public var txtTabName:TextField;
		public var mcInpuFeedback:ModuleInputFeedback;
		public var mcBlackBackground:W3Background;
		public var mcMeditationBackground : MovieClip;
		public var mcMenuBackgroundContainer:MovieClip;
		
		protected var _changePageInputFeedback:int = 1;
		protected var _changeTabInputFeedback:int = 2;
		protected var _exitInputFeedback:int = 3;
		
		protected var _cachedIsGamepad:Boolean;
		protected var _navigationEnabled:Boolean;
		protected var _blockBackNav:Boolean;
		public var visibleScreenRect:Rectangle;
		
		public function MenuCommon()
		{
			_enableInputValidation = true;
			_navigationEnabled = true;
			_loadAssets = false;
			_blockBackNav = false;
			
			super();
			
			_enableMouse = false;
			mcMenuHub.refInputFeedback = mcInpuFeedback;
			mcInpuFeedback.clickable = false;
		}

		override public function toString():String
		{
			return "MenuCommon [" + this.name + "]";
		}

		override protected function get menuName():String
		{
			return "CommonMenu";
		}

		override protected function configUI():void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.setup', [initMenuTabs]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'common.input.feedback.setup', [handleSetupBindings]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'common.input.navigation.enabled', [setNavigationEnabled]));

			//mcMenuTabs.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChange, false, 0, true);
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 2, true);
			mcInpuFeedback.buttonAlign = "center";
			
			mcMenuHub.addEventListener(MenuHub.OpenMenuCalled, onOpenMenuReq, false, 0, true);
			
			if (mcCloseBtn)
			{
				mcCloseBtn.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
			}

			if (!Extensions.isScaleform)
			{
				displayDebugData();
			}
			
			if (mcMeditationBackground)
			{
				mcMeditationBackground.visible = false;
			}
			
			if (txtTabName)
			{
				txtTabName.visible = false;
			}
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			visibleScreenRect = CommonUtils.getScreenRect();
			setBackgroundPosition();

		}
		public function setBackgroundPosition():void
		{
			mcMenuBackgroundContainer.x = visibleScreenRect.x;
		}
		public function blockBackNavigation():void
		{
			_blockBackNav = true;
		}
		
		public function updateMenuBackgroundImage(path:String):void
		{
			var imgloader:W3UILoader = mcMenuBackgroundContainer.getChildByName("mcImageLoader") as W3UILoader;
			
				if (imgloader)
				{
					imgloader.source = path;
				}
		}

		override public function setControllerType(isGamePad:Boolean):void
		{
			super.setControllerType(isGamePad);
			_cachedIsGamepad = isGamePad;
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleCtrlChanged, false, 0, true);
		}

		protected function handleCtrlChanged(event:ControllerChangeEvent):void
		{
			if (_cachedIsGamepad != event.isGamepad)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnControllerChanged', [ event.isGamepad ] ));
				_cachedIsGamepad = event.isGamepad;
			}
		}

		protected function displayDebugData():void
		{
			var testButtons:Array = [];
			var btn1:KeyBindingData = new KeyBindingData();
			btn1.gamepad_navEquivalent = "escape-gamepad_B";
			btn1.keyboard_keyCode = 27;
			btn1.label = "Some button 1";
			testButtons.push(btn1);
			var btn2:KeyBindingData = new KeyBindingData();
			btn2.gamepad_navEquivalent = "enter-gamepad_A";
			btn2.keyboard_keyCode = 113;
			btn2.label = "Some button 2";
			testButtons.push(btn2);
			handleSetupBindings(testButtons);

			var subItem1:Object = { visible:true, enabled:true, id:0, name:"PreparationMenu", label:"Sub 1", state:"" };
			var subItem2:Object = { visible:true, enabled:true, id:1, name:"MeditationMenu", label:"Sub 2", state:"" };
			var ddSubMenu:Array = [ subItem1, subItem2 ];
			var tabObj:Object = { visible:true, enabled:true, id:0, icon:"InventoryMenu", label:"Main Tab", subItems:ddSubMenu };
			var tabObj2:Object = { visible:true, enabled:true, id:1, icon:"MapMenu", label:"Map Menu", subItems:ddSubMenu };
			initMenuTabs([tabObj, tabObj2]);
		}

		override protected function showAnimation():void
		{
			visible = true;
		}

		protected function onOpenMenuReq(event:Event):void
		{
			var targetTab:MenuHubTabListItem = mcMenuHub.currentlySelectedMenu();

			if (targetTab)
			{
				callMenuOpen(targetTab.data.id, targetTab.data.state);
			}
			else if (_cachedMenuID != uint.MAX_VALUE)
			{
				callMenuOpen(_cachedMenuID, _cachedMenuState);
			}
		}
		
		public function blockMenuClosing(value:Boolean):void // WS
		{
			mcMenuHub.blockMenuClosing = value;
			
			if (mcCloseBtn && mcMenuHub.currentState == MenuHub.State_Hidden)
			{
				mcCloseBtn.visible = !value;
			}
		}
		
		public function blockHubClosing(value:Boolean):void //WS
		{
			mcMenuHub.blockHubClosing = value;
			
			if (mcCloseBtn && mcMenuHub.currentState != MenuHub.State_Hidden)
			{
				mcCloseBtn.visible = !value;
			}
		}
		
		public function SetInputFeedbackVisibility(value:Boolean):void //WS
		{
			mcInpuFeedback.setVisibility( value );
		}
		
		public function updateTabEnabled(menuId:uint, menuState:String, enabled:Boolean)
		{
			mcMenuHub.updateTabDataEnabled(menuId, menuState, enabled);
		}
		
		public function setMeditationBackgroundMode(value:Boolean):void //WS
		{
			if (mcMeditationBackground && mcBlackBackground)
			{
				mcMeditationBackground.visible = value;
				mcBlackBackground.visible = !value;
				mcMenuHub.mcTabBackground.visible = !value;
			}
		}

		override public function SetInitialPanelXOffset( value : int )
		{
			return;
		}

		/*
		 * 	API
		 */

		private var _tabsInited:Boolean = false;
		public function initMenuTabs(tabsList:Array):void
		{
			_tabsInited = true;
			mcMenuHub.setTabdata(tabsList);

			if (_cachedMenuID != uint.MAX_VALUE)
			{
				mcMenuHub.selectMenu(_cachedMenuID, _cachedMenuState);
			}

			if (_cachedEnterMenyCalled)
			{
				mcMenuHub.hide(true);
			}
		}

		public function handleForceNextTab():void
		{
		}

		public function handleForcePriorTab():void
		{
		}


		public function setShopInventory( value : Boolean ) : void
		{
			mcMenuHub.isShopInventory = value;
		}
		
		private var _cachedMenuID:uint = uint.MAX_VALUE;
		private var _cachedMenuState:String = "";
		public function setSelectedTab(menuId:uint, menuState:String):void
		{
			if (_tabsInited)
			{
				mcMenuHub.selectMenu(menuId, menuState);
			}
			else
			{
				_cachedMenuID = menuId;
				_cachedMenuState = menuState;
			}
		}

		protected var _cachedEnterMenyCalled:Boolean = false;
		public function enterCurrentlySelectedTab():void
		{
			if (_tabsInited)
			{
				mcMenuHub.hide(true);
			}
			else
			{
				_cachedEnterMenyCalled = true;
			}
		}

		public function selectMenuTab(tabId:uint, menuState:String):void
		{
		}

		public function selectSubMenuTab(tabId:uint, menuState:String):void
		{
		}

		public function onSubMenuClosed():void
		{
			mcMenuHub.handleUp();
			_requestedMenuId = 0;
			_requestedMenuState = "";
		}
		
		public function onChildMenuConfigured():void
		{
			mcMenuHub.hide(true);
		}
		
		public function lockOpenTabNavigation(locked:Boolean):void
		{
			mcMenuHub.rblbenabled = !locked;
		}
		
		public function setPlayerDetailsVisible(value:Boolean):void
		{
			mcPlayerDetails.visible = value;
		}
		
		public function hubHiddenBegin():void
		{
			if (mcCloseBtn)
			{
				mcCloseBtn.visible = !mcMenuHub.blockMenuClosing;
			}
		}
		
		public function hubHiddenEnd():void
		{
			if (mcCloseBtn)
			{
				mcCloseBtn.visible = !mcMenuHub.blockHubClosing;
			}
		}

		/*
		 *  Update stats
		 */
		public function updatePlayerLevel(level:Number, exp:Number, targetExp:Number):void
		{
			mcPlayerDetails.setLevel(level, exp, targetExp);
		}

		public function updateWeight(value:Number, maxValue:Number) :void
		{
			mcPlayerDetails.setWeight(value, maxValue);
		}

		public function updateMoney(value:Number):void
		{
			mcPlayerDetails.setMoney(value);
		}

		/*
		 * Core
		 */
		
		protected function handleSetupBindings(bindingsList:Object):void
		{
			mcInpuFeedback.handleSetupButtons(bindingsList);
		}
		
		protected function handleIndexChange(event:ListEvent):void
		{
		}
		
		protected function createSubPanel(subItemsList:Array, sourceTab:MenuTab, parentId:int):void
		{
		}
		
		protected function removeSubPanel():void
		{
		}
		
		protected function handleSubIndexChange(event:ListEvent):void
		{
		}
		
		protected var _requestedMenuId:uint = 0;
		protected var _requestedMenuState:String = "";
		protected function callMenuOpen(menuId:uint, menuState:String = ""):void
		{
			trace("GFX callMenuOpenFromParent ", menuId, menuState);
			if (!(_requestedMenuId == menuId && _requestedMenuState == menuState))
			{
				_requestedMenuId = menuId;
				_requestedMenuState = menuState;
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestMenu', [menuId, menuState] ) );
			}
		}
		
        protected function setNavigationEnabled(value:Boolean):void
        {
			_navigationEnabled = value;
			mcMenuHub.navigationEnabled = value;
        }
		
		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			if (_blockBackNav)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHideChildMenu' ) );
			}
			else
			{
				tryAndNavigateBack();
			}
		}
		
		protected function tryAndNavigateBack():void
		{
			if (!mcMenuHub.blockMenuClosing)
			{
				if (mcMenuHub.currentState == MenuHub.State_TopTab)
				{
					closeMenu();
				}
				else if (mcMenuHub.currentState == MenuHub.State_BotTab)
				{
					mcMenuHub.handleUp();
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHideChildMenu' ) );
				}
			}
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			//trace("GFX <MenuCommon> handleInputNavigate  ", details.value, details.navEquivalent);
			
			//super.handleInput(event); // #J We don't want CoreMenu's behavior is MenuCommon
			var details:InputDetails = event.details;
			
			// Handle only down state to avoid jumping
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			
			if (!event.handled && _navigationEnabled)
			{
				switch (details.navEquivalent)
				{
				case NavigationCode.GAMEPAD_B:
					if (keyDown)
					{
						if (mcMenuHub.currentState == MenuHub.State_TopTab || mcMenuHub.currentState == MenuHub.State_Init)
						{
							closeMenu();
							return;
						}
					}
					break;
				case NavigationCode.START:
					if (keyUp && ( !_enableInputValidation || ( isNavEquivalentValid(details.navEquivalent) || isKeyCodeValid(details.code) ) ) )
					{
						closeMenu();
					}
					break;
				default:
					if (keyUp)
					{
						if ( !_blockBackNav && (details.code == KeyCode.NUMBER_2 || details.code == KeyCode.NUMPAD_2) )
						{
							tryAndNavigateBack();
						}
					}
					break;
				}
			}
			
			//#J last second hacky solution....
			if (keyUp && !event.handled)
			{
				var code:uint;
				code = details.code;
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHotkeyTriggered', [code] ) );
			}
		}
	}
}
