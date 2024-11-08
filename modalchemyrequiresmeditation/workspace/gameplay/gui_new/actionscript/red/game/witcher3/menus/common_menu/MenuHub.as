/***********************************************************************
/** The master of all that is and ever was hub related ish.
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.InvisibleComponent;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.controls.W3ListSelectionTracker;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.FiniteStateMachine;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.utils.CommonUtils;
	
	public class MenuHub extends UIComponent
	{
		public static const OpenMenuCalled:String = "onOpenMenu";
				
		private static const IFB_ACTIVATE:int = 100;
		private static const IFB_NAVIGATE:int = 101;
		private static const IFB_NEXT_MENU:int = 102;
		private static const IFB_PRIOR_MENU:int = 103;
		private static const IFB_CLOSE:int = 1001;
		
		private static const TITLE_BTN_PADDING : int = 35;
		
		// ------------------------------------------------------
		// Open Menu Data
		public var mcOpenMenuDataHolder:MovieClip;
		public var mcLeftPCButton:ConditionalButton;
		public var mcLeftGamepadButton:InputFeedbackButton;
		public var mcRightPCButton:ConditionalButton;
		public var mcRightGamepadButton:InputFeedbackButton;
		public var txtTabName:TextField;
		public var txtPrevTabName:W3TextArea;
		public var txtNextTabName:W3TextArea;
		public var mcSelectionTracker:W3ListSelectionTracker;
		protected var _selectLastChild:Boolean = false;
		protected var _allItemsList:Vector.<Object>;
		// ===============================================================

		public var mcOpenHubDataContainer:MovieClip;
		
		/// input feedback
		public var refInputFeedback:ModuleInputFeedback;
		private var _blockMenuClosing:Boolean;
		private var _blockHubClosing:Boolean;
		private var _showOpenButton:Boolean;
		private var _showNavigateButton:Boolean;
		private var _showBackButton:Boolean;
		private var _showExitButton:Boolean;
		
		// ------------------------------------------------------
		// Top items
		public var mcTopTabHolder:MovieClip;
		public var mcGridLine:MovieClip;
		public var txtTopMainDesc:W3TextArea;
		public var txtTabNewDesc:W3TextArea;
		public var txtBottomDesc:W3TextArea;

		public var mcItemsHistory : ItemsHistory;
		public var mcTrackedQuestDisplay : TrackedQuestInfo;
		public var mcGlossaryEntriesInfo : TextInfoContainer;
		public var mcAlchemyEntriesInfo : TextInfoContainer;
		public var mcSkillsEntriesInfo : TextInfoContainer;
		public var mcMapEntriesInfo : TextInfoContainerMap;
		private var currnetHubInfoTabName : String;

		public var mcTopTabList:W3ScrollingList;
		public var mcTopTabListItem1:MenuHubTabListItem;
		public var mcTopTabListItem2:MenuHubTabListItem;
		public var mcTopTabListItem3:MenuHubTabListItem;
		public var mcTopTabListItem4:MenuHubTabListItem;
		public var mcTopTabListItem5:MenuHubTabListItem;
		public var mcTopTabListItem6:MenuHubTabListItem;
		public var mcTopTabListItem7:MenuHubTabListItem;

		private static const TopTabAnimDuration:Number = 0.2;
		private static const TopTabUnfocusedAlpha:Number = 0.5;
		private static const TopTabUnfocusedScale:Number = 0.85;
		private static const TopTabYOffset:Number = -100;
		private var topHolderStartingY:Number;
		// ===============================================================

		// ------------------------------------------------------
		// Top items
		public var mcBotTabHolder:MovieClip;

		public var mcBotTabList:W3ScrollingList;
		public var mcBotTabListItem1:MenuHubTabListItem;
		public var mcBotTabListItem2:MenuHubTabListItem;
		public var mcBotTabListItem3:MenuHubTabListItem;
		public var mcBotTabListItem4:MenuHubTabListItem;
		public var mcBotTabListItem5:MenuHubTabListItem;
		public var mcBotTabListItem6:MenuHubTabListItem;

		private static const BotTabAnimDuration:Number = 0.2;
		private static const BotHolderXOffset:Number = 0;
		private static const BotHolderYOffset:Number = -75;
		private static const BotUnfocusedYOffset:Number = 50;
		private static const BotFocusedAlpha:Number = 1.0;
		private static const BotUnfocusedAlpha:Number = 0.85;
		private static const BotFocusedScale:Number = 1.0;
		private static const BotUnfocusedScale:Number = 0.85;
		private var botHolderStartingY:Number;
		private var botHolderStartingX:Number;
		// ===============================================================

		// ------------------------------------------------------
		// Background
		public var mcTabBackground:MovieClip;
		private static const TabBackgroundTopAlpha : Number = 0.85;
		private static const TabBackgroundBotAlpha : Number = 1;
		private static const TabBackgroundBotOffset : Number = -100;
		private var tabBackgroundStartingY:Number;
		// ===============================================================

		protected var stateMachine:FiniteStateMachine;

		public static const State_Init : String = "Init";
		public static const State_TopTab : String = "TopTab";
		public static const State_BotTab : String = "BotTab";
		public static const State_Hidden : String = "Hidden";
		public static const State_Transition : String = "Trans";

		public var navigationEnabled:Boolean = true;
		public var isShopInventory:Boolean = false;

		protected var ignoreNextTabChange : Boolean = false;
		
		public var rblbenabled:Boolean = true;

		override protected function configUI():void
		{
			super.configUI();
			
			mcBotTabListItem1.isSmallTab = true;
			mcBotTabListItem2.isSmallTab = true;
			mcBotTabListItem3.isSmallTab = true;
			mcBotTabListItem4.isSmallTab = true;
			mcBotTabListItem5.isSmallTab = true;
			mcBotTabListItem6.isSmallTab = true;
			
			grabInitialValues();
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.newestitems", [handleItemsHistoryDataSet] ));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.quests", [handleTrackedQuestInfoDataSet] ));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.map", [populateMapInfoDataSet] ));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.skills", [populateSkillsInfoDataSet] ));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.glossary", [populateGlossaryInfoDataSet] ));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.alchemy", [populateAlchemyInfoDataSet] ));
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 10, true);
			mcTopTabList.addEventListener(ListEvent.INDEX_CHANGE, handleTopIndexChange, false, 0, true);
			mcBotTabList.addEventListener(ListEvent.INDEX_CHANGE, handleBotIndexChange, false, 0, true);
			
			tabEnabled = tabChildren = false;
			setupTabContainers();
			
			setupStateMachine();
			
			if (mcLeftPCButton)
			{
				mcLeftPCButton.addEventListener(ButtonEvent.PRESS, handlePrevButtonPress, false, 0, true);
			}
			if (mcLeftGamepadButton)
			{
				mcLeftGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_L1, -1);
			}
			if (mcRightPCButton)
			{
				mcRightPCButton.addEventListener(ButtonEvent.PRESS, handleNextButtonPress, false, 0, true);
			}
			if (mcRightGamepadButton)
			{
				mcRightGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_R1, -1);
			}

			if (txtTabName)
			{
				txtTabName.text = "";
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 100, true);
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			//if (mcLeftGamepadButton) { mcLeftGamepadButton.visible = InputManager.getInstance().isGamepad(); }
			//if (mcRightGamepadButton) { mcRightGamepadButton.visible = InputManager.getInstance().isGamepad(); }
			//dispatchEvent(new GameEvent(GameEvent.REGISTER, "panel.main.panelinfo.numbered", [handleItemsNumberSet] ));
			
		}


		protected function handleItemsHistoryDataSet( gameData:Object, index:int ):void
		{
			mcItemsHistory.handleDataSet( gameData, index );
			ForceUpdateHubInfo();
		}

		protected function handleTrackedQuestInfoDataSet( gameData:Object, index:int ):void
		{
			mcTrackedQuestDisplay.handleDataSet( gameData, index );
			ForceUpdateHubInfo();
		}

		protected function populateMapInfoDataSet( gameData:Object, index:int ):void
		{
			mcMapEntriesInfo.handleDataSet( gameData, index );
			ForceUpdateHubInfo();
		}

		protected function populateSkillsInfoDataSet( gameData:Object, index:int ):void
		{
			mcSkillsEntriesInfo.handleDataSet( gameData, index );
			ForceUpdateHubInfo();
		}

		protected function populateGlossaryInfoDataSet( gameData:Object, index:int ):void
		{
			mcGlossaryEntriesInfo.handleDataSet( gameData, index );
			ForceUpdateHubInfo();
		}

		protected function populateAlchemyInfoDataSet( gameData:Object, index:int ):void
		{
			mcAlchemyEntriesInfo.handleDataSet( gameData, index );
			ForceUpdateHubInfo();
		}

		protected function ForceUpdateHubInfo():void
		{
			var tabName : String = currnetHubInfoTabName;
			currnetHubInfoTabName = "";
			UpdateHubInfo( tabName );
		}

		public function set currentState(value:String):void
		{
			stateMachine.ChangeState(value);
		}

		public function get currentState():String
		{
			if (isStateAnimationPlaying())
			{
				return State_Transition;
			}
			else
			{
				return stateMachine.currentState;
			}
		}
		
		public function get blockMenuClosing():Boolean { return _blockMenuClosing }
		public function set blockMenuClosing(value:Boolean):void
		{
			_blockMenuClosing = value;
			updateInputFeedback();
		}
		
		public function get blockHubClosing():Boolean { return _blockHubClosing }
		public function set blockHubClosing(value:Boolean):void
		{
			_blockHubClosing = value;
			updateInputFeedback();
		}
		
		private var hideRequested:Boolean = false;
		private var hideImmediately:Boolean = false;
		public function hide(immediately:Boolean = false):void
		{
			hideRequested = true;
			hideImmediately = immediately;
			stateMachine.ChangeState(State_Hidden);
		}

		protected function setupStateMachine():void
		{
			stateMachine = new FiniteStateMachine();

			stateMachine.AddState(State_Init,   state_Init_begin,       state_Init_update, 	null);
			stateMachine.AddState(State_TopTab,	state_TopTab_begin, 	null, 				null);
			stateMachine.AddState(State_BotTab,	state_BotTab_begin,		null, 				null);
			stateMachine.AddState(State_Hidden, state_Hidden_begin,		null, 				state_Hidden_end);
		}

		protected function grabInitialValues():void
		{
			if (mcTopTabHolder)
			{
				topHolderStartingY = mcTopTabHolder.y;
			}

			if (mcTabBackground)
			{
				tabBackgroundStartingY = mcTabBackground.y;
			}

			if (mcBotTabHolder)
			{
				botHolderStartingX = mcBotTabHolder.x;
				botHolderStartingY = mcBotTabHolder.y;
			}
		}

		protected function setupTabContainers():void
		{
			addToOpenMenuContainer(mcLeftGamepadButton);
			addToOpenMenuContainer(mcRightGamepadButton);
			addToOpenMenuContainer(txtTabName);
			addToOpenMenuContainer(mcSelectionTracker);
			addToOpenMenuContainer(txtPrevTabName);
			addToOpenMenuContainer(txtNextTabName);
			addToOpenMenuContainer(mcLeftPCButton);
			addToOpenMenuContainer(mcRightPCButton);


			// #J temp disabling of text for focus test
			txtTopMainDesc.visible = false;
			txtTabNewDesc.visible = false;
			txtBottomDesc.visible = false;
			mcItemsHistory.visible = false;
			mcGlossaryEntriesInfo.visible = false;
			mcAlchemyEntriesInfo.visible = false;
			mcSkillsEntriesInfo.visible = false;
			mcTrackedQuestDisplay.visible = false;
			mcMapEntriesInfo.visible = false;

			addToOpenHubListContainer(txtTopMainDesc);
			addToOpenHubListContainer(txtTabNewDesc);

			addToTopListContainer(mcGridLine);
			addToTopListContainer(mcTopTabList);
			addToTopListContainer_Item(mcTopTabListItem1);
			addToTopListContainer_Item(mcTopTabListItem2);
			addToTopListContainer_Item(mcTopTabListItem3);
			addToTopListContainer_Item(mcTopTabListItem4);
			addToTopListContainer_Item(mcTopTabListItem5);
			addToTopListContainer_Item(mcTopTabListItem6);
			addToTopListContainer_Item(mcTopTabListItem7);

			addToBotListContainer(mcBotTabList);
			addToBotListContainer_Item(mcBotTabListItem1);
			addToBotListContainer_Item(mcBotTabListItem2);
			addToBotListContainer_Item(mcBotTabListItem3);
			addToBotListContainer_Item(mcBotTabListItem4);
			addToBotListContainer_Item(mcBotTabListItem5);
			addToBotListContainer_Item(mcBotTabListItem6);
			addToBotListContainer(mcItemsHistory);
			addToBotListContainer(mcGlossaryEntriesInfo);
			addToBotListContainer(mcAlchemyEntriesInfo);
			addToBotListContainer(mcSkillsEntriesInfo);
			addToBotListContainer(mcMapEntriesInfo);
			addToBotListContainer(mcTrackedQuestDisplay);
			addToBotListContainer(txtBottomDesc);
		}

		public function selectMenu(menuId:uint, menuState:String):void
		{
			var topTabIT:int;
			var botTabIT:int;

			var subTabArray:Array;

			var topTabCloseIndex:int = -1;
			var botTabCloseIndex:int = -1;

			var dataToModify:Object = null;

			var currentTab:MenuHubTabListItem;

			trace("GFX - Trying to select hub tab with id: " + menuId + " and state: " + menuState);

			for (topTabIT = 0; topTabIT < mcTopTabList.dataProvider.length; ++topTabIT)
			{
				currentTab = mcTopTabList.getRendererAt(topTabIT) as MenuHubTabListItem;

				if (currentTab && currentTab.data && currentTab.enabled)
				{
					subTabArray = currentTab.data.subItems;
					for (botTabIT = 0; botTabIT < subTabArray.length; ++botTabIT)
					{
						if (subTabArray[botTabIT].id == menuId)
						{
							if (subTabArray[botTabIT].state == menuState || menuState == "")
							{
								trace("GFX - setting selected indexes to: " + topTabIT + ", " + botTabIT);
								ignoreNextTabChange = true;
								mcTopTabList.selectedIndex = topTabIT;
								mcTopTabList.validateNow();

								ignoreNextTabChange = false;
								mcBotTabList.selectedIndex = botTabIT;
								mcBotTabList.validateNow();
								return;
							}
							else if (topTabCloseIndex == -1 || botTabCloseIndex == -1)
							{
								topTabCloseIndex = topTabIT;
								botTabCloseIndex = botTabCloseIndex;
								dataToModify = subTabArray[botTabIT];
							}
						}
					}

					if (currentTab.data.id == menuId)
					{
						if (currentTab.data.state == menuState)
						{
							trace("GFX - setting selected indexes to: " + topTabIT);
							mcTopTabList.selectedIndex = topTabIT;
							mcTopTabList.validateNow();
							return;
						}
						else if (topTabCloseIndex == -1)
						{
							topTabCloseIndex = topTabIT;
							dataToModify = currentTab.data;
						}
					}
				}
			}

			if (topTabCloseIndex != -1)
			{
				mcTopTabList.selectedIndex = topTabCloseIndex;
				mcTopTabList.validateNow();

				trace("GFX - setting selected indexes (BACKUP) to: " + topTabCloseIndex + ", " + botTabCloseIndex + ", state:" + menuState);

				if (botTabCloseIndex != -1)
				{
					mcBotTabList.selectedIndex = botTabCloseIndex;
					mcBotTabList.validateNow();
				}

				if (dataToModify && menuState != "")
				{
					dataToModify.state = menuState;
				}

				return;
			}

			trace("GFX --==[WARNING]==-- was unable to set selection to the menu with id:" + menuId + " and menuState: " + menuState);
			// Find first selectable tab
			for (topTabIT = 0; topTabIT < mcTopTabList.dataProvider.length; ++topTabIT)
			{
				currentTab = mcTopTabList.getRendererAt(topTabIT) as MenuHubTabListItem;
				
				if (currentTab && currentTab.data && currentTab.data.enabled)
				{
					mcTopTabList.selectedIndex = topTabIT;
					break;
				}
			}
		}
		
		public function updateTabDataEnabled(menuId:uint, menuState:String, enabled:Boolean)
		{
			var topTabIT:int;
			var botTabIT:int;

			var subTabArray:Array;

			var currentTab:MenuHubTabListItem;
			var newData:Object = null;
			var newDataArray:Array = new Array();
			
			trace("GFX - Trying to select hub tab with id: " + menuId + " and state: " + menuState);

			for (topTabIT = 0; topTabIT < mcTopTabList.dataProvider.length; ++topTabIT)
			{
				currentTab = mcTopTabList.getRendererAt(topTabIT) as MenuHubTabListItem;
				
				if (currentTab && currentTab.data && currentTab.data.id == menuId)
				{
					newData = currentTab.data;
					newData.enabled = enabled;
					currentTab.setData(newData);
					
					subTabArray = currentTab.data.subItems;
					/*for (botTabIT = 0; botTabIT < subTabArray.length; ++botTabIT)
					{
						newData = subTabArray[botTabIT].data;
						newData.enabled = enabled;
						subTabArray[botTabIT].setData(newData);
					}*/
					
					if (mcTopTabList.selectedIndex == topTabIT && !enabled)
					{
						mcTopTabList.moveUp(true);
					}
					
					trace("GFX - Successfully updated enabled state for menu with id: " + menuId + ", and enabled:" + enabled);
				}
				
				newDataArray.push(currentTab.data);
			}
			
			mcTopTabList.validateNow();
			setupAllItemsList(newDataArray);
			updateTabName(currentlySelectedMenu());
		}

		public function setTabdata(data:Array):void
		{
			if (!data)
			{
				return;
			}

			mcTopTabList.dataProvider = new DataProvider(data);

			mcTopTabList.validateNow();
			mcTopTabList.selectedIndex = data.length / 2;

			setupAllItemsList(data);
		}

		protected function setupAllItemsList(data:Array):void
		{
			var i:int;
			var j:int;
			
			_allItemsList = new Vector.<Object>();

			for (i = 0; i < data.length; ++i)
			{
				var currentObj:Object = data[i];
				var subItems:Array = currentObj.subItems as Array;

				if (currentObj.enabled)
				{
					if (subItems == null || subItems.length == 0)
					{
						_allItemsList.push(currentObj);
					}
					else if (currentObj.enabled)
					{
						for (j = 0; j < subItems.length; ++j)
						{
							_allItemsList.push(subItems[j]);
						}
					}
				}
			}

			if (mcSelectionTracker)
			{
				mcSelectionTracker.numElements = _allItemsList.length;
				mcSelectionTracker.selectedIndex = mcTopTabList.selectedIndex;
			}
		}

		protected function getIndexOfItem(targetObject:Object):int
		{
			return _allItemsList.indexOf(targetObject);
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			if (event.isGamepad)
			{
				_lastMoveWasMouse = false;
			}
		}
		
		protected var _lastMoveWasMouse:Boolean = false;
		protected var _lastMouseOveredItem:MenuHubTabListItem;
		protected function handleMouseMove(event:MouseEvent):void
		{
			if (!_lastMoveWasMouse)
			{
				_lastMoveWasMouse = true;
				if (stateMachine.currentState == State_BotTab)
				{
					AnimateToTopTab_State();
				}
				
				if (_lastMouseOveredItem != null)
				{
					var botIndex:int = mcBotTabList.getRenderers().indexOf(_lastMouseOveredItem);
					
					if (botIndex != -1)
					{
						mcBotTabList.selectedIndex = botIndex;
					}
					else
					{
						var topIndex:int = mcTopTabList.getRenderers().indexOf(_lastMouseOveredItem);
						
						if (topIndex != -1)
						{
							mcTopTabList.selectedIndex = topIndex;
						}
					}
				}
			}
		}

		public function currentlySelectedMenu():MenuHubTabListItem
		{
			var currentTopTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (currentTopTab)
			{
				if (currentTopTab.data && currentTopTab.data.subItems.length == 0)
				{
					return currentTopTab;
				}
				else
				{
					var currentBotTab:MenuHubTabListItem = mcBotTabList.getSelectedRenderer() as MenuHubTabListItem;

					return currentBotTab;
				}
			}

			return null;
		}

		protected function isStateAnimationPlaying():Boolean
		{
			return topTabHolderTweener != null || botTabHolderTweener != null;
		}

		protected var topTabHolderTweener:GTween;
		protected function handleTopTabHolderTweenComplete(curTween:GTween = null):void
		{
			topTabHolderTweener = null;
		}
		protected function handleTopTabHolderHideTweenComplete(curTween:GTween = null):void
		{
			topTabHolderTweener = null;
			mcTopTabHolder.y = -2000;
		}

		protected var botTabHolderTweener:GTween;
		protected function handleBotTabHolderTweenComplete(curTween:GTween = null):void
		{
			botTabHolderTweener = null;
		}
		protected function handleBotTabHolderHideTweenComplete(curTween:GTween = null):void
		{
			botTabHolderTweener = null;
			mcBotTabHolder.y = -2000;
		}

		protected var backgroundImageTweener:GTween;
		protected function handleBackgroundImageTweenComplete(curTween:GTween = null):void
		{
			backgroundImageTweener = null;
		}

		protected var openTabImageTweener:GTween;
		protected function handleOpenTabImageTweenComplete(curTween:GTween = null):void
		{
			openTabImageTweener = null;

			if (mcOpenMenuDataHolder && mcOpenMenuDataHolder.alpha == 0)
			{
				mcOpenMenuDataHolder.visible = false;
				updateNavigationInputFeedback();
			}
		}

		protected function state_Init_begin():void
		{
			var startAnimDuration:Number = 0.5;
			if (mcTopTabHolder)
			{
				mcTopTabHolder.y = topHolderStartingY - 200;
				mcTopTabHolder.alpha = 0;

				topTabHolderTweener = GTweener.to(mcTopTabHolder, startAnimDuration, { alpha:1, y:topHolderStartingY }, {onComplete:handleTopTabHolderTweenComplete, ease:Sine.easeOut} );
			}

			if (mcBotTabHolder)
			{
				mcBotTabHolder.y = botHolderStartingY - 200;
				mcBotTabHolder.alpha = 0;

				botTabHolderTweener = GTweener.to(mcBotTabHolder, startAnimDuration, { alpha:BotUnfocusedAlpha, y:(botHolderStartingY + BotUnfocusedYOffset), scaleX:BotUnfocusedScale, scaleY:BotUnfocusedScale }, {onComplete:handleBotTabHolderTweenComplete, ease:Sine.easeOut} );
			}

			if (mcOpenMenuDataHolder)
			{
				mcOpenMenuDataHolder.visible = false;
			}

			if (mcOpenHubDataContainer)
			{
				mcOpenHubDataContainer.visible = true;
			}

			var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
			if ( selectedTab )
			{
				UpdateHubInfo(selectedTab.data.name);
			}
			
			updateNavigationInputFeedback();
		}

		protected function state_Init_update():void
		{
			if (hideRequested)
			{
				stateMachine.ChangeState(State_Hidden);
			}
			else
			{
				var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
				if ( selectedTab )
				{
					UpdateHubInfo(selectedTab.data.name);
				}
				stateMachine.ChangeState(State_TopTab);
				if ( selectedTab )
				{
					UpdateHubInfo(selectedTab.data.name);
				}
			}
		}
		
		protected function AnimateToTopTab_State():void
		{
			trace("GFX -------------- animating to top tab state ---------------------");
			if (mcTopTabHolder)
			{
				if (topTabHolderTweener)
				{
					topTabHolderTweener.paused = true;
					GTweener.removeTweens(mcTopTabHolder);
				}

				topTabHolderTweener = GTweener.to(mcTopTabHolder, TopTabAnimDuration, { alpha:1, scaleX:1, scaleY:1, y:topHolderStartingY }, {onComplete:handleTopTabHolderTweenComplete, ease:Sine.easeOut} );
			}

			if (mcBotTabHolder)
			{
				if (botTabHolderTweener)
				{
					botTabHolderTweener.paused = true;
					GTweener.removeTweens(mcBotTabHolder);
				}

				botTabHolderTweener = GTweener.to(mcBotTabHolder, TopTabAnimDuration, { alpha:BotUnfocusedAlpha, x:botHolderStartingX, y:(botHolderStartingY + BotUnfocusedYOffset), scaleX:BotUnfocusedScale, scaleY:BotUnfocusedScale }, {onComplete:handleBotTabHolderTweenComplete, ease:Sine.easeOut} );
			}

			if (mcTabBackground)
			{
				if (backgroundImageTweener)
				{
					backgroundImageTweener.paused = true;
					GTweener.removeTweens(mcTabBackground);
				}

				backgroundImageTweener = GTweener.to(mcTabBackground, TopTabAnimDuration, { alpha:TabBackgroundTopAlpha, y:tabBackgroundStartingY }, {onComplete:handleBackgroundImageTweenComplete, ease:Sine.easeOut} );
			}
		}
		
		protected function AnimateToBotTab_State():void
		{
			trace("GFX -------------- animating to bot tab state ---------------------");
			if (mcTopTabHolder)
			{
				if (topTabHolderTweener)
				{
					topTabHolderTweener.paused = true;
					GTweener.removeTweens(mcTopTabHolder);
				}

				topTabHolderTweener = GTweener.to(mcTopTabHolder, BotTabAnimDuration, { alpha:TopTabUnfocusedAlpha, scaleX:TopTabUnfocusedScale, scaleY:TopTabUnfocusedScale, y:(topHolderStartingY + TopTabYOffset) }, {onComplete:handleTopTabHolderTweenComplete, ease:Sine.easeOut} );
			}

			if (mcBotTabHolder)
			{
				if (botTabHolderTweener)
				{
					botTabHolderTweener.paused = true;
					GTweener.removeTweens(mcBotTabHolder);
				}

				botTabHolderTweener = GTweener.to(mcBotTabHolder, BotTabAnimDuration, { alpha:BotFocusedAlpha, x:(botHolderStartingX + BotHolderXOffset), y:(botHolderStartingY + BotHolderYOffset), scaleX:BotFocusedScale, scaleY:BotFocusedScale }, {onComplete:handleBotTabHolderTweenComplete, ease:Sine.easeOut} );
			}

			if (mcTabBackground)
			{
				if (backgroundImageTweener)
				{
					backgroundImageTweener.paused = true;
					GTweener.removeTweens(mcTabBackground);
				}

				backgroundImageTweener = GTweener.to(mcTabBackground, BotTabAnimDuration, { alpha:TabBackgroundBotAlpha, y:(tabBackgroundStartingY + TabBackgroundBotOffset) }, {onComplete:handleBackgroundImageTweenComplete, ease:Sine.easeOut} );
			}
		}

		protected function state_TopTab_begin():void
		{
			if (refInputFeedback)
			{
				_showOpenButton = true;
				_showNavigateButton = true;
				_showBackButton = false;
				_showExitButton = true;
				updateInputFeedback();
			}
			
			AnimateToTopTab_State();
			
			var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
			if ( selectedTab )
			{
				UpdateHubInfo(selectedTab.data.name);
			}
		}

		protected function state_BotTab_begin():void
		{
			if (InputManager.getInstance().isGamepad() || !_lastMoveWasMouse)
			{
				AnimateToBotTab_State();
			}
			else
			{
				AnimateToTopTab_State();
			}
				
			if (refInputFeedback)
			{
				_showOpenButton = true;
				_showNavigateButton = true;
				_showBackButton = true;
				_showExitButton = false;
				updateInputFeedback();
			}
			
			var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
			if ( selectedTab )
			{
				UpdateHubInfo(selectedTab.data.name);
			}
		}

		protected function state_Hidden_begin():void
		{
			var animDuration:Number = 0.3;
			
			var parentMenu:MenuCommon = this.parent as MenuCommon;
			if (parentMenu)
			{
				parentMenu.hubHiddenBegin();
			}

			if (mcTopTabHolder)
			{
				if (topTabHolderTweener)
				{
					topTabHolderTweener.paused = true;
					GTweener.removeTweens(mcTopTabHolder);
				}
				
				/*if (!hideImmediately)
				{
					topTabHolderTweener = GTweener.to(mcTopTabHolder, animDuration, { alpha:0, y:(topHolderStartingY - 200) }, { onComplete:handleTopTabHolderHideTweenComplete, ease:Sine.easeOut } );
				}
				else
				{*/
					mcTopTabHolder.alpha = 0;
					mcTopTabHolder.y = topHolderStartingY - 200;
					handleTopTabHolderHideTweenComplete();
				//}
			}

			if (mcBotTabHolder)
			{
				if (botTabHolderTweener)
				{
					botTabHolderTweener.paused = true;
					GTweener.removeTweens(mcBotTabHolder);
				}

				/*if (!hideImmediately)
				{
					botTabHolderTweener = GTweener.to(mcBotTabHolder, animDuration, { alpha:0, y:(botHolderStartingY - 200) }, { onComplete:handleBotTabHolderHideTweenComplete, ease:Sine.easeOut } );
				}
				else
				{*/
					mcBotTabHolder.alpha = 0;
					mcBotTabHolder.y = botHolderStartingY - 200;
					handleBotTabHolderHideTweenComplete();
				//}
			}

			if (mcTabBackground)
			{
				if (backgroundImageTweener)
				{
					backgroundImageTweener.paused = true;
					GTweener.removeTweens(mcTabBackground);
				}

				/*if (!hideImmediately)
				{
					backgroundImageTweener = GTweener.to(mcTabBackground, animDuration, { alpha:0 }, { onComplete:handleBackgroundImageTweenComplete, ease:Sine.easeOut } );
				}
				else
				{*/
					mcTabBackground.alpha = 0;
					handleBackgroundImageTweenComplete();
				//}
			}

			if (mcOpenMenuDataHolder)
			{
				mcOpenMenuDataHolder.visible = true;

				if (openTabImageTweener)
				{
					openTabImageTweener.paused = true;
					GTweener.removeTweens(mcOpenMenuDataHolder);
				}

				/*if (!hideImmediately)
				{
					openTabImageTweener = GTweener.to(mcOpenMenuDataHolder, 0.4, { alpha:1 }, { onComplete:handleOpenTabImageTweenComplete, ease:Sine.easeOut } );
				}
				else
				{*/
					mcOpenMenuDataHolder.alpha = 1;
				//}
			}

			if (mcOpenHubDataContainer)
			{
				mcOpenHubDataContainer.visible = false;
			}

			dispatchEvent( new Event(OpenMenuCalled) );
			
			hideImmediately = false;
			if (refInputFeedback)
			{
				_showOpenButton = false;
				_showNavigateButton = false;
				_showBackButton = true;
				_showExitButton = false;
				updateInputFeedback();
			}
			UpdateHubInfo("ciastko");
			txtTopMainDesc.visible = false;
			
			updateNavigationInputFeedback();
		}

		protected function state_Hidden_end():void
		{
			if (mcOpenMenuDataHolder)
			{
				if (openTabImageTweener)
				{
					openTabImageTweener.paused = true;
					GTweener.removeTweens(mcOpenMenuDataHolder);
				}

				openTabImageTweener = GTweener.to(mcOpenMenuDataHolder, 0.4, { alpha:0 }, {onComplete:handleOpenTabImageTweenComplete, ease:Sine.easeOut} );
			}
			
			var parentMenu:MenuCommon = this.parent as MenuCommon;
			if (parentMenu)
			{
				parentMenu.hubHiddenEnd();
			}

			if (mcTopTabHolder && topTabHolderTweener == null) // #J (No need to do this if it never finished the hide animation)
			{
				mcTopTabHolder.y = topHolderStartingY - 200;
			}

			if (mcBotTabHolder && botTabHolderTweener == null)
			{
				mcBotTabHolder.y = botHolderStartingY - 200;
			}
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnRefreshHubInfo", [true] ));
			var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
			if ( selectedTab )
			{
				UpdateHubInfo(selectedTab.data.name);
			}

			if (mcOpenHubDataContainer)
			{
				mcOpenHubDataContainer.visible = true;
			}
			
			updateNavigationInputFeedback();
		}

		private var _lastUpdatedTopTabIndex:int = -1;
		protected function handleTopIndexChange(event:ListEvent):void
		{
			if (mcTopTabList.selectedIndex == -1)
			{
				return;
			}
			
			updateTopTabIndexSelection(mcTopTabList.selectedIndex);
		}
		
		protected function updateTopTabIndexSelection(index:int):void
		{
			if (index != _lastUpdatedTopTabIndex)
			{
				trace("GFX ------- Updating Top Index to: " +index + ", from: " + _lastUpdatedTopTabIndex);
				_lastUpdatedTopTabIndex = index;
				
				var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
				
				if (selectedTab && selectedTab.data)
				{
					updateTabBackgroundImage();
					
					if (txtTopMainDesc) { txtTopMainDesc.text = selectedTab.data.tabDesc; }
					if (txtTabNewDesc) { txtTabNewDesc.text = selectedTab.data.tabNewDesc; }
					
					mcBotTabList.dataProvider = new DataProvider(selectedTab.data.subItems);
					mcBotTabList.validateNow();
					
					if (selectedTab.data.subItems.length == 0)
					{
						updateTabName(selectedTab);
					}
					else
					{
						if (_selectLastChild)
						{
							mcBotTabList.selectedIndex = selectedTab.data.subItems.length - 1;
						}
						else
						{
							mcBotTabList.selectedIndex = 0;
						}
						mcBotTabList.validateNow();
						
						var selectedChild:MenuHubTabListItem = mcBotTabList.getSelectedRenderer() as MenuHubTabListItem;
						
						if (selectedChild)
						{
							updateTabName(selectedChild);
						}
					}
					
					_selectLastChild = false;
				}
			}
		}
		
		protected function updateTabBackgroundImage():void
		{
			if (mcTabBackground)// && stateMachine.currentState != State_Hidden)
			{
				var selectedTab:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
				
				if (backgroundImageTweener)
				{
					backgroundImageTweener.paused = true;
					GTweener.removeTweens(mcTabBackground);
				}
				
				mcTabBackground.alpha = 0;
				//mcTabBackground.gotoAndStop(selectedTab.data.icon);
				
				var imageLoader:W3UILoader = mcTabBackground.getChildByName("mcImageLoader") as W3UILoader;
				
				if (imageLoader)
				{
					imageLoader.source = "img://icons/menuhub/img_background_" + selectedTab.data.icon + ".png";
				}
				
				var parentAnchor:InvisibleComponent = mcTabBackground.getChildByName("mc" + selectedTab.data.icon + "Anchor") as InvisibleComponent;
				if (parentAnchor)
				{
					imageLoader.x = parentAnchor.x;
					imageLoader.y = parentAnchor.y;
				}
				
				var alpha:Number = 0;
				var yTarget:Number = tabBackgroundStartingY;
				
				switch (stateMachine.currentState)
				{
				case State_TopTab:
					alpha = TabBackgroundTopAlpha;
					break;
				case State_BotTab:
					alpha = TabBackgroundBotAlpha;
					yTarget = tabBackgroundStartingY + TabBackgroundBotOffset;
					break;
				}
				
				backgroundImageTweener = GTweener.to(mcTabBackground, 0.2, { alpha: alpha, y:yTarget }, {onComplete:handleBackgroundImageTweenComplete, ease:Sine.easeOut} );
			}
		}

		protected function handleBotIndexChange(event:ListEvent):void
		{
			var selectedParent:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
			var selectedChild:MenuHubTabListItem = mcBotTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedChild && selectedParent.data.subItems.length > 0)
			{
				updateTabName(selectedChild);
			}
		}

		protected function updateTabName(targetTab:MenuHubTabListItem):void
		{
			if (txtTabName)
			{
				txtTabName.htmlText = targetTab.data.label;
				txtTabName.htmlText = CommonUtils.toUpperCaseSafe(txtTabName.htmlText);
				UpdateHubInfo(targetTab.data.name);
				//txtTabName.validateNow();
				
				mcSelectionTracker.x = txtTabName.x +  txtTabName.width/2 -  mcSelectionTracker.getVisibleWidth()/2;

				var currentIndex:int = getIndexOfItem(targetTab.data);
				mcSelectionTracker.selectedIndex = currentIndex;

				if (_allItemsList.length < 2 || currentIndex == -1)
				{
					if (mcRightGamepadButton)
					{
						mcRightGamepadButton.visible = false;
					}

					if (mcLeftGamepadButton)
					{
						mcLeftGamepadButton.visible = false;
					}
					
					if (mcRightPCButton)
					{
						mcRightPCButton.visible = false;
					}
					
					if (mcLeftPCButton)
					{
						mcLeftPCButton.visible = false;
					}

					if (txtNextTabName)
					{
						txtNextTabName.visible = false;
					}

					if (txtPrevTabName)
					{
						txtPrevTabName.visible = false;
					}
					
				}
				else
				{
					var gamepadBaseOffset:int = 15;
					var gamepadIconWidth:int = 45;
					
					if (mcLeftGamepadButton)
					{
						mcLeftGamepadButton.visible = true;
						//trace("GFX >>>>>>>>>>>>>>>>>>>>>>>>>>>"+ "txtTabName="+ txtTabName.width +">>>>txtNextTabName.textField.textWidth="+  txtNextTabName.textField.textWidth);
						mcLeftGamepadButton.x = txtTabName.x + (txtTabName.width - txtTabName.textWidth )/2 - mcLeftGamepadButton.getViewWidth() -  TITLE_BTN_PADDING;
					}

					if (mcRightGamepadButton)
					{
						mcRightGamepadButton.visible = true;
						mcRightGamepadButton.x = txtTabName.x + txtTabName.width/2 + txtTabName.textWidth/ 2 + mcLeftGamepadButton.getViewWidth();
					}
					
					if (mcLeftPCButton)
					{
						mcLeftPCButton.visible = true;
						mcLeftPCButton.x = txtTabName.x + (txtTabName.width - txtTabName.textWidth ) /2 - TITLE_BTN_PADDING;
					}
					if (mcRightPCButton)
					{
						mcRightPCButton.visible = true;
						mcRightPCButton.x = txtTabName.x + (txtTabName.width + txtTabName.textWidth )/2 + TITLE_BTN_PADDING;
					}

					if (txtNextTabName)
					{
						txtNextTabName.visible = true;
						//txtNextTabName.x = txtTabName.x + txtTabName.textField.textWidth + gamepadBaseOffset + gamepadIconWidth;

						if ((currentIndex + 1) >= _allItemsList.length)
						{
							txtNextTabName.uppercase = true;
							txtNextTabName.htmlText = _allItemsList[0].label;
							
						}
						else
						{
							txtNextTabName.uppercase = true;
							txtNextTabName.htmlText = _allItemsList[currentIndex + 1].label;
						}
					}

					if (txtPrevTabName)
					{
						txtPrevTabName.visible = true;

						if (currentIndex == 0)
						{
							txtPrevTabName.uppercase = true;
							txtPrevTabName.htmlText = _allItemsList[_allItemsList.length - 1].label;
						}
						else
						{
							txtPrevTabName.uppercase = true;
							txtPrevTabName.htmlText = _allItemsList[currentIndex - 1].label;
						}
					}
				}
				
				updateNavigationInputFeedback()
			}

			if (stateMachine.currentState == State_Hidden)
			{
				if (!ignoreNextTabChange)
				{
					dispatchEvent( new Event(OpenMenuCalled) );
				}
				else
				{
					ignoreNextTabChange = false;
				}
			}
		}
		
		protected function updateNavigationInputFeedback():void
		{
			/*
			if (!refInputFeedback) return;
			
			refInputFeedback.removeButton(IFB_NEXT_MENU, false);
			refInputFeedback.removeButton(IFB_PRIOR_MENU, false);
			if (!mcOpenHubDataContainer.visible && _allItemsList.length > 1)
			{
				//refInputFeedback.appendButton(IFB_NEXT_MENU, NavigationCode.GAMEPAD_R1, KeyCode.PAGE_UP, "[[panel_button_common_next_menu]]", false);
				//refInputFeedback.appendButton(IFB_PRIOR_MENU, NavigationCode.GAMEPAD_L1, KeyCode.PAGE_DOWN, "[[panel_button_common_prior_menu]]", false);
				//refInputFeedback.appendButton(IFB_PRIOR_MENU, NavigationCode.GAMEPAD_RBLB, -1, "[[panel_button_common_change_page]]", false);
				//refInputFeedback.refreshButtonList();
			}
			*/
		}

		protected function addToOpenHubListContainer(component:MovieClip):void
		{
			var xOffset:Number;
			var yOffset:Number;

			if (mcOpenHubDataContainer && component)
			{
				xOffset = component.x - mcOpenHubDataContainer.x;
				yOffset = component.y - mcOpenHubDataContainer.y;

				mcOpenHubDataContainer.addChild(component);

				component.x = xOffset;
				component.y = yOffset;
			}
		}
		
		protected function addToTopListContainer_Item(component:MovieClip):void
		{
			if (component)
			{
				component.addEventListener(MouseEvent.CLICK, onTopTabItemClicked, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OVER, onTopTabItemMouseOver, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OUT, onTopTabItemMouseOut, false, 0, true);
			}
			
			addToTopListContainer(component);
		}

		protected function addToTopListContainer(component:MovieClip):void
		{
			var xOffset:Number;
			var yOffset:Number;

			if (mcTopTabHolder && component)
			{
				xOffset = component.x - mcTopTabHolder.x;
				yOffset = component.y - mcTopTabHolder.y;

				mcTopTabHolder.addChild(component);

				component.x = xOffset;
				component.y = yOffset;
			}
		}
		
		protected function addToBotListContainer_Item(component:MovieClip):void
		{
			if (component)
			{
				component.addEventListener(MouseEvent.CLICK, onBotTabItemClicked, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OVER, onBotTabItemMouseOver, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OUT, onBotTabItemMouseOut, false, 0, true);
			}
			
			addToBotListContainer(component);
		}

		protected function addToBotListContainer(component:MovieClip):void
		{
			var xOffset:Number;
			var yOffset:Number;

			if (mcBotTabHolder && component)
			{
				xOffset = component.x - mcBotTabHolder.x;
				yOffset = component.y - mcBotTabHolder.y;

				mcBotTabHolder.addChild(component);

				component.x = xOffset;
				component.y = yOffset;
			}
		}

		protected function addToOpenMenuContainer(component: DisplayObject ):void
		{
			var xOffset:Number;
			var yOffset:Number;

			if (mcOpenMenuDataHolder && component)
			{
				xOffset = component.x - mcOpenMenuDataHolder.x;
				yOffset = component.y - mcOpenMenuDataHolder.y;

				mcOpenMenuDataHolder.addChild(component);

				component.x = xOffset;
				component.y = yOffset;
			}
		}

		public function handleDown():void
		{
			if (stateMachine.currentState == State_TopTab)
			{
				var selectedParent:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
				
				if (mcBotTabList.dataProvider.length > 0)
				{
					if (selectedParent)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOpenSubPanel', [selectedParent.data.id] ) );
					}
					stateMachine.ChangeState(State_BotTab);
				}
				else if (selectedParent.data.enabled)
				{
					stateMachine.ChangeState(State_Hidden);
				}
			}
			else if (stateMachine.currentState == State_BotTab)
			{
				// Add in code to call open menu here
				stateMachine.ChangeState(State_Hidden);
			}
		}

		public function handleUp():void
		{
			var selectedTopItem:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;
			
			if (stateMachine.currentState == State_BotTab)
			{
				var closingPanelId:uint = 0;
				if (selectedTopItem)
				{
					closingPanelId = selectedTopItem.data.id;
				}
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseSubPanel', [closingPanelId] ) );
				stateMachine.ChangeState(State_TopTab);
			}
			else if (stateMachine.currentState == State_Hidden)
			{
				if (mcTopTabHolder)
				{
					mcTopTabHolder.alpha = 0;
					mcTopTabHolder.y = topHolderStartingY - 200;
				}
				
				if (mcBotTabHolder)
				{
					mcBotTabHolder.alpha = 0;
					mcBotTabHolder.y = botHolderStartingY - 200;
				}
				
				if (selectedTopItem && selectedTopItem.data.subItems.length > 0 && (InputManager.getInstance().isGamepad() || !_lastMoveWasMouse))
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOpenSubPanel', [selectedTopItem.data.id] ) );
					stateMachine.ChangeState(State_BotTab);
				}
				else
				{
					stateMachine.ChangeState(State_TopTab);
				}
			}
		}

		protected function selectPrevTabItem():void
		{
			var selectedParent:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedParent)
			{
				// #J WARNING this code assumes there is no disabled indexes in children, sooooo DONT add sublist items that can't be opened
				if (stateMachine.currentState == State_Hidden && mcTopTabList.dataProvider.length > 1 && (selectedParent.data.subItems.length == 0 || mcBotTabList.selectedIndex == 0))
				{
					_selectLastChild = true;
					mcTopTabList.moveUp(true);
				}
				else
				{
					mcBotTabList.moveUp(true);
				}
			}
		}

		protected function selectNextTabItem():void
		{
			var selectedParent:MenuHubTabListItem = mcTopTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedParent)
			{
				if (mcTopTabList.dataProvider.length > 1 && (selectedParent.data.subItems.length == 0 || mcBotTabList.selectedIndex == (selectedParent.data.subItems.length - 1)))
				{
					mcTopTabList.moveDown(true);
				}
				else
				{
					mcBotTabList.moveDown(true);
				}
			}
		}

		protected function UpdateHubInfo( tabName : String )
		{
			if ( tabName == currnetHubInfoTabName )
			{
				return;
			}
			currnetHubInfoTabName = tabName;
			ShowInventoryInfo( false );
			ShowJournalInfo( false );
			ShowGlossaryInfo( false );
			ShowAlchemyInfo(false);
			ShowSkillsInfo( false );
			ShowMapInfo( false );
			switch(tabName)
			{
				case 'CraftingMenu' :
					if ( !isShopInventory )
					{
						ShowGlossaryInfo( true );
					}
				case 'CraftingParent' :
				case 'BlacksmithParent' :
				case 'BlacksmithMenu' :
					////txtTopMainDesc.visible = true;
					//txtTopMainDesc.htmlText = "[[panel_hub_crafting_manage]]";
					break;
				case 'AlchemyMenu' :
					ShowAlchemyInfo(true);
					break;
				case 'MeditationMenu' :
				case 'MeditationClockMenu' :
				case 'MeditationParent' :
					//txtTopMainDesc.visible = true;
					//txtTopMainDesc.htmlText = "[[panel_hub_meditation_manage]]";
					break;
				case 'InventoryMenu' :
				case 'InventoryParent' :
					ShowInventoryInfo( true );
					break;
				case 'JournalQuestMenu' :
				case 'JournalParent' :
				case 'JournalMonsterHuntingMenu' :
				case 'JournalTreasureHuntingMenu' :
					ShowJournalInfo( true );
					break;
				case 'GlossaryParent' :
				case 'GlossaryBestiaryMenu' :
				case 'GlossaryTutorialsMenu' :
				case 'GlossaryStorybookMenu' :
				case 'GlossaryBooksMenu':
				case 'CraftingMenu' :
				case 'GlossaryEncyclopediaMenu' :
					ShowGlossaryInfo( true );
					break;
				case 'CharacterMenu' :
					ShowSkillsInfo( true );
					break;
				case 'MapMenu' :
					ShowMapInfo( true );
					break;
			}
		}

		public function ShowInventoryInfo( show : Boolean )
		{
			if ( !mcItemsHistory.IsAnyItemToDisplay() )
			{
				show = false;
			}
			mcItemsHistory.visible = show;
			//txtTabNewDesc.visible = show;
			txtBottomDesc.visible = show;

			//txtTopMainDesc.visible = true;
			if ( isShopInventory )
			{
				//txtTopMainDesc.htmlText = "[[panel_hub_shop_manage]]";
			}
			else
			{
				//txtTopMainDesc.htmlText = "[[panel_hub_inventory_manage]]";
			}

			if ( show )
			{
				txtBottomDesc.htmlText = "[[panel_hub_inventory_new_items]]";
				//txtTabNewDesc.htmlText = ""; // newItemsNumbered;
			}
			else
			{
				txtBottomDesc.htmlText = "";
			}
		}

		public function ShowJournalInfo( show : Boolean )
		{
			if ( !mcTrackedQuestDisplay.IsAnyItemToDisplay() )
			{
				show = false;
			}
			mcTrackedQuestDisplay.visible = show;
			//txtTabNewDesc.visible = show;
			txtBottomDesc.visible = show;

			//txtTopMainDesc.visible = true;
			txtTopMainDesc.htmlText = "[[panel_hub_journal_main]]";

			if ( show )
			{
				txtBottomDesc.htmlText = "[[panel_hub_journal_tracked]]";
				txtTabNewDesc.htmlText = "";
			}
			else
			{
				txtBottomDesc.htmlText = "";
			}
		}

		public function ShowGlossaryInfo( show : Boolean )
		{
			if ( !mcGlossaryEntriesInfo.IsAnyItemToDisplay() )
			{
				show = false;
			}
			mcGlossaryEntriesInfo.visible = show;
			//txtTabNewDesc.visible = show;
			txtBottomDesc.visible = show;

			//txtTopMainDesc.visible = true;
			//txtTopMainDesc.htmlText = "[[panel_hub_glossary_main]]";

			if ( show )
			{
				txtBottomDesc.htmlText = "[[panel_hub_glossary_newest_entries]]";
				txtTabNewDesc.htmlText = "";
			}
			else
			{
				txtBottomDesc.htmlText = "";
			}
		}

		public function ShowAlchemyInfo( show : Boolean )
		{
			if ( !mcAlchemyEntriesInfo.IsAnyItemToDisplay() )
			{
				show = false;
			}
			mcAlchemyEntriesInfo.visible = show;
			//txtTabNewDesc.visible = show;
			txtBottomDesc.visible = show;

			//txtTopMainDesc.visible = true;
			//txtTopMainDesc.htmlText = "[[panel_hub_alchemy_manage]]";

			if ( show )
			{
				txtBottomDesc.htmlText = "[[panel_hub_alchemy_newest_entries]]";
				//txtTabNewDesc.htmlText = "";
			}
			else
			{
				txtBottomDesc.htmlText = "";
			}
		}

		public function ShowSkillsInfo( show : Boolean )
		{
			if ( !mcSkillsEntriesInfo.IsAnyItemToDisplay() )
			{
				show = false;
			}
			mcSkillsEntriesInfo.visible = show;

			//txtTabNewDesc.visible = show;
			txtBottomDesc.visible = show;

			//txtTopMainDesc.visible = true;
			//txtTopMainDesc.htmlText = "[[panel_hub_skills_main]]";

			if ( show )
			{
				txtBottomDesc.htmlText = "[[panel_hub_skills_last_unlocked]]";
				txtTabNewDesc.htmlText = "";//"[[panel_hub_skills_main_new]]";
			}
			else
			{
				txtBottomDesc.htmlText = "";
			}
		}

		public function ShowMapInfo( show : Boolean )
		{
			if ( !mcMapEntriesInfo.IsAnyItemToDisplay() )
			{
				show = false;
			}
			mcMapEntriesInfo.visible = show;
			//txtTabNewDesc.visible = show;
			txtBottomDesc.visible = show;

			//txtTopMainDesc.visible = true;
			//txtTopMainDesc.htmlText = "[[panel_hub_map_main]]";

			if ( show )
			{
				txtBottomDesc.htmlText = "[[panel_hub_map_last_discovered]]";
				txtTabNewDesc.htmlText = "";
			}
			else
			{
				txtBottomDesc.htmlText = "";
			}
		}
		
		private function getNumEnabledTabs():int
		{
			var topTabIT:int;
			var botTabIT:int;
			var currentTab:MenuHubTabListItem;
			var currentSubTabData:Object;
			var numEnabled:int = 0;
			
			for (topTabIT = 0; topTabIT < mcTopTabList.dataProvider.length; ++topTabIT)
			{
				currentTab = mcTopTabList.getRendererAt(topTabIT) as MenuHubTabListItem;
				
				if (currentTab.data)
				{
					if (currentTab.data.enabled)
					{
						++numEnabled;
					}
					
					if (currentTab.data.subItems)
					{
						for (botTabIT = 0; botTabIT < currentTab.data.subItems.length; ++botTabIT)
						{
							currentSubTabData = currentTab.data.subItems[botTabIT];
							
							if (currentSubTabData && currentSubTabData.enabled)
							{
								++numEnabled;
							}
						}
					}
				}
			}
			
			return numEnabled;
		}

		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);

			//trace("GFX <MenuHub> handleInput ", event.handled, event.details.navEquivalent, navigationEnabled);

			if (event.handled || !navigationEnabled)
			{
				return;
			}

			if (stateMachine.currentState == State_TopTab)
			{
				mcTopTabList.handleInput(event);
			}
			else if (stateMachine.currentState == State_BotTab)
			{
				mcBotTabList.handleInput(event);
			}
			
			var inputDetails:InputDetails = event.details as InputDetails;
			CommonUtils.convertWASDCodeToNavEquivalent(inputDetails);
			
			if (inputDetails.navEquivalent == NavigationCode.UP || inputDetails.navEquivalent == NavigationCode.DOWN || inputDetails.navEquivalent == NavigationCode.LEFT || inputDetails.navEquivalent == NavigationCode.RIGHT)
			{
				_lastMoveWasMouse = false;
			}

			if (!event.handled)
			{
				var isKeyUp:Boolean = inputDetails.value == InputValue.KEY_UP;
				var isKeyDown:Boolean = inputDetails.value == InputValue.KEY_DOWN;
				var isKeyHold:Boolean = inputDetails.value == InputValue.KEY_HOLD;
				
				var allowInput:Boolean = true;
				var parentMenu:MenuCommon = this.parent as MenuCommon;
				if (parentMenu)
				{
					allowInput = isKeyDown || !parentMenu.isInputValidationEnabled() || ( parentMenu.isNavEquivalentValid(inputDetails.navEquivalent) || parentMenu.isKeyCodeValid(inputDetails.code) ) ;
				}
				
				// WASD support
				
				switch (inputDetails.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
						if (allowInput && isKeyUp && stateMachine.currentState != State_Hidden)
						{
							handleDown();
						}
						break;
					case NavigationCode.DOWN:
						if (allowInput && (isKeyDown || isKeyHold) && stateMachine.currentState != State_Hidden)
						{
							handleDown();
						}
						break;
					case NavigationCode.GAMEPAD_B:
						if (allowInput && (isKeyDown || isKeyHold) && stateMachine.currentState != State_Hidden)
						{
							handleUp();
						}
						break;
					case NavigationCode.UP:
						if (allowInput && isKeyDown && stateMachine.currentState != State_Hidden)
						{
							handleUp();
						}
						break;
					case NavigationCode.GAMEPAD_L1:
						if (allowInput && isKeyUp && stateMachine.currentState == State_Hidden && rblbenabled)
						{
							selectPrevTabItem();
						}
						break;
					case NavigationCode.GAMEPAD_R1:
						if (allowInput && isKeyUp && stateMachine.currentState == State_Hidden && rblbenabled)
						{
							selectNextTabItem();
						}
						break;
					default:
						if (allowInput && inputDetails.code == KeyCode.E && (isKeyDown || isKeyHold) && stateMachine.currentState != State_Hidden)
						{
							handleDown();
						}
						else if (allowInput && isKeyUp && stateMachine.currentState == State_Hidden && rblbenabled)
						{
							if (inputDetails.code == KeyCode.NUMBER_1 || inputDetails.code == KeyCode.NUMPAD_1 || inputDetails.code == KeyCode.PAGE_DOWN)
							{
								trySelectedPrevTabItem();
							}
							else if (inputDetails.code == KeyCode.NUMBER_3 || inputDetails.code == KeyCode.NUMPAD_3 || inputDetails.code == KeyCode.PAGE_UP)
							{
								trySelectNextTabItem();
							}
						}
						break;
				}
			}
		}
		
		protected function handlePrevButtonPress( event : ButtonEvent ) : void
		{
			trySelectedPrevTabItem();
		}
		
		protected function handleNextButtonPress( event : ButtonEvent ) : void
		{
			trySelectNextTabItem();
		}
		
		protected function trySelectedPrevTabItem():void
		{
			if (stateMachine.currentState == State_Hidden && rblbenabled && navigationEnabled )
			{
				selectPrevTabItem();
			}
		}
		
		protected function trySelectNextTabItem():void
		{
			if (stateMachine.currentState == State_Hidden && rblbenabled && navigationEnabled )
			{
				selectNextTabItem();
			}
		}
		
		private function updateInputFeedback():void
		{
			refInputFeedback.removeButton(IFB_ACTIVATE, false);
			refInputFeedback.removeButton(IFB_NAVIGATE, false);
			refInputFeedback.removeButton(IFB_CLOSE, false);
			
			if (_showOpenButton && getNumEnabledTabs() > 0)
			{
				refInputFeedback.appendButton(IFB_ACTIVATE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_open_menu]]", false);
			}
			if (_showNavigateButton && getNumEnabledTabs() > 1)
			{
				refInputFeedback.appendButton(IFB_NAVIGATE, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", false);
			}
			if (_showBackButton && !blockMenuClosing)
			{
				refInputFeedback.appendButton(IFB_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", false);
			}
			else
			if (_showExitButton && !blockHubClosing)
			{
				refInputFeedback.appendButton(IFB_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_button_common_exit]]", false);
			}
			refInputFeedback.refreshButtonList();
		}
		
		protected function onTopTabItemMouseOver(event:MouseEvent):void
		{
			_lastMouseOveredItem = event.currentTarget as MenuHubTabListItem;
			
			if (InputManager.getInstance().isGamepad() || !_lastMoveWasMouse)
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			//if (stateMachine.currentState == State_TopTab)
			//{
				mcTopTabList.selectedIndex = mcTopTabList.getRenderers().indexOf(currentTarget);
			//}
		}
		
		protected function onTopTabItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = null;
			
			if (InputManager.getInstance().isGamepad() || !_lastMoveWasMouse)
			{
				return;
			}
			
			event.stopImmediatePropagation();
			
			/*if (stateMachine.currentState == State_BotTab)
			{
				if (_lastUpdatedTopTabIndex != -1)
				{
					mcTopTabList.selectedIndex = _lastUpdatedTopTabIndex;
				}
				else
				{
					mcTopTabList.selectedIndex = 0; // Glossary
				}
			}*/
		}
		
		protected function onTopTabItemClicked(event:MouseEvent):void
		{
			if (InputManager.getInstance().isGamepad())
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
			{
				/*if (stateMachine.currentState == State_BotTab)
				{
					handleUp();
					mcTopTabList.selectedIndex = mcTopTabList.getRenderers().indexOf(currentTarget);
					mcTopTabList.validateNow();
					updateTopTabIndexSelection(mcTopTabList.selectedIndex);
				}
				else*/
				{
					mcTopTabList.selectedIndex = mcTopTabList.getRenderers().indexOf(currentTarget);
					mcTopTabList.validateNow();
					handleDown();
				}
			}
		}
		
		protected function onBotTabItemMouseOver(event:MouseEvent):void
		{
			_lastMouseOveredItem = event.currentTarget as MenuHubTabListItem;
			
			if (InputManager.getInstance().isGamepad() || !_lastMoveWasMouse)
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			//if (stateMachine.currentState == State_BotTab)
			//{
				mcBotTabList.selectedIndex = mcBotTabList.getRenderers().indexOf(currentTarget);
			//}
		}
		
		protected function onBotTabItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = null;
		}
		
		protected function onBotTabItemClicked(event:MouseEvent):void
		{
			if (InputManager.getInstance().isGamepad() || !_lastMoveWasMouse)
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
			{
				mcBotTabList.selectedIndex = mcBotTabList.getRenderers().indexOf(currentTarget);
				mcBotTabList.validateNow();
				handleDown();
				stateMachine.ForceUpdateState();
				handleDown();
			}
		}
	}
}
