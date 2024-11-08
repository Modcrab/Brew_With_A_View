/***********************************************************************
/** PANEL glossary characters main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.modules
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.AdvancedTabListItem;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3DropDownList;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import scaleform.clik.interfaces.IListItemRenderer;
	import red.game.witcher3.utils.CommonUtils;
	
	public class TabbedScrollingListModule extends CoreMenuModule
	{
		public var txtTitle:TextField;
		public var mcTabList:W3ScrollingList;
		public var mcTabListItem1:TabListItem;
		public var mcTabListItem2:TabListItem;
		public var mcTabListItem3:TabListItem;
		public var mcTabListItem4:TabListItem;
		public var mcTabListItem5:TabListItem;
		public var mcTabListItem6:TabListItem;
		public var mcTabListItem7:TabListItem;
		public var mcTabListItem8:TabListItem;
		
		public var mcLeftGamepadIcon:W3GamepadButton;
		public var mcRightGamepadIcon:W3GamepadButton;
		public var mcScrollbar:ScrollBar;
		
		public var mcSlotList:SlotsListBase;
		public var mcDropdownList:W3DropDownList;
		
		public var mcTabBackground:MovieClip;
		public var hideTabBackgroundWhenData:Boolean = false;
		
		public var _inputEnabled:Boolean = true;
		
		public var _pendingTabDataRequest:int = -1;
		
		protected var subDataDictionary:Dictionary = new Dictionary();
		
		private var _callbacksSet:Boolean = false;
		public var noDelay: Boolean = true;
		
		protected var _initialSelectedIndex : int;
		
		override protected function configUI():void
		{
			super.configUI();
			
			_initialSelectedIndex = 0;

			if (mcLeftGamepadIcon)
			{
				mcLeftGamepadIcon.navigationCode = NavigationCode.GAMEPAD_L1;
				mcLeftGamepadIcon.textField.text = "";
			}
			
			if (mcRightGamepadIcon)
			{
				mcRightGamepadIcon.navigationCode = NavigationCode.GAMEPAD_R1;
				mcRightGamepadIcon.textField.text = "";
			}
			
			if (!_callbacksSet)
			{
				_callbacksSet = true;
				
				if (_subDataProvider != CommonConstants.INVALID_STRING_PARAM)
				{
					var tabDataFuncs:Array = new Array();
					tabDataFuncs.push(handleTabDataSet1);
					tabDataFuncs.push(handleTabDataSet2);
					tabDataFuncs.push(handleTabDataSet3);
					tabDataFuncs.push(handleTabDataSet4);
					tabDataFuncs.push(handleTabDataSet5);
					tabDataFuncs.push(handleTabDataSet6);
					tabDataFuncs.push(handleTabDataSet7);
					tabDataFuncs.push(handleTabDataSet8);
					
					for (var i:int = 0; i < mcTabList.numRenderers; ++i)
					{
						dispatchEvent( new GameEvent(GameEvent.REGISTER, _subDataProvider + i.toString(), [tabDataFuncs[i]]));
					}
				}
				
				if (_setSelectedDataProvider != CommonConstants.INVALID_STRING_PARAM)
				{
					dispatchEvent( new GameEvent(GameEvent.REGISTER, _setSelectedDataProvider, [onSetTabCalled]));
				}
			}
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			if (!InputManager.getInstance().isGamepad())
			{
				setAllowSelectionHighlight(focused != 0);
			}
			
			setupTabData();
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			
			if (mcDropdownList)
			{
				_inputHandlers.push(mcDropdownList);
			}
			else if (mcSlotList)
			{
				_inputHandlers.push(mcSlotList);
			}
		}
		
		protected var _subDataProvider:String = CommonConstants.INVALID_STRING_PARAM;
		[Inspectable(defaultValue=CommonConstants.INVALID_STRING_PARAM)]
		public function get subDataProvider():String { return _subDataProvider; }
		public function set subDataProvider(value:String):void
		{
			_subDataProvider = value;
		}
		
		protected var _tabDataEventName:String = "OnTabDataRequested";
		[Inspectable(defaultValue="OnTabDataRequested")]
		public function get tabDataEventName():String { return _tabDataEventName; }
		public function set tabDataEventName(value:String):void
		{
			_tabDataEventName = value;
		}
		
		protected var _setSelectedDataProvider:String = "OnTabSelectRequested";
		[Inspectable(defaultValue="OnTabSelectRequested")]
		public function get setSelectedTabDataProvider():String { return _setSelectedDataProvider; }
		public function set setSelectedTabDataProvider(value:String):void
		{
			_setSelectedDataProvider = value;
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			
			OnFocusedChanged();
			
			fireSelectedItemTooltip();
		}
		
		protected function OnFocusedChanged():void
		{
			UpdateSelectionHighlight();
		}
		
		protected function UpdateSelectionHighlight():void
		{
			setAllowSelectionHighlight(focused != 0);
		}
		
		protected var _lastSetAllowSelectionHighlight:Boolean = true;
		protected function setAllowSelectionHighlight(allowed:Boolean):void
		{
			var i:int;
			
			if (mcTabList)
			{
				var currentTabItem:AdvancedTabListItem;
				for (i = 0; i < mcTabList.numRenderers; ++i)
				{
					currentTabItem = mcTabList.getRendererAt(i) as AdvancedTabListItem;
				
					if (currentTabItem)
					{
						currentTabItem.selectionVisible = focused;
					}
				}
			}
			
			_lastSetAllowSelectionHighlight = allowed;
			
			// #J TODO
			/*if (mcDropdownList)
			{
				mcDropdownList.getRendererAt();
				var currentListItem:IListItemRenderer
			}*/
			
			if (mcSlotList)
			{
				mcSlotList.activeSelectionVisible = allowed || !InputManager.getInstance().isGamepad();
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			setAllowSelectionHighlight(_lastSetAllowSelectionHighlight);
		}
		
		public function setNewFlagsForTabs(newFlagArray:Array):void
		{
			var currentTab : AdvancedTabListItem;
			var i:int = 0;
			
			for (i = 0; (i < newFlagArray.length && i < mcTabList.dataProvider.length); ++i)
			{
				currentTab = mcTabList.getRendererAt(i) as AdvancedTabListItem;
				if (currentTab)
				{
					currentTab.setNewFlag(newFlagArray[i]);
				}
			}
		}
		
		protected function fireSelectedItemTooltip():void
		{
			var selectedList:UIComponent = getDataShowerForCurrentTab();
			
			if ((selectedList is SlotsListBase) && enabled)
			{
				var currentSlot:SlotBase = (selectedList as SlotsListBase).getSelectedRenderer() as SlotBase;
				
				if (currentSlot)
				{
					currentSlot.showTooltip();
				}
			}
		}
		
		private var _setTabDataProvider:DataProvider;
		
		public function setTabData(data:DataProvider):void
		{
			var i:int = 0;
			
			_setTabDataProvider = data;
			setupTabData();
			
			subDataDictionary = new Dictionary();
			
			if (currentlySelectedTabIndex != -1)
			{
				updateSubData(currentlySelectedTabIndex);
			}
			else
			{
				mcTabList.selectedIndex = _initialSelectedIndex;
				mcTabList.validateNow();
			}
		}
		
		public function onSetTabCalled(tabIndex:int):void
		{
			trace("GFX -------------- onSetTabCalled ", tabIndex);
			
			if (mcTabList)
			{
				mcTabList.selectedIndex = tabIndex;
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			if (mcTabList.selectedIndex == -1 || (subDataDictionary[mcTabList.selectedIndex] != null && subDataDictionary[mcTabList.selectedIndex].length == 0))
			{
				return false;
			}
			
			return super.hasSelectableItems();
		}
		
		private var _tabDataSet:Boolean = false;
		private function setupTabData()
		{
			if (!_tabDataSet && mcTabList && _setTabDataProvider)
			{
				_tabDataSet = true;
				mcTabList.dataProvider = _setTabDataProvider;
				mcTabList.validateNow();
				mcTabList.ShowRenderers(true);
				mcTabList.tabEnabled = false;
				mcTabList.tabChildren = false;
				mcTabList.focusable = false;
				
				mcTabList.addEventListener(ListEvent.INDEX_CHANGE, onTabListItemSelected, false, 0, true);
			}
		}
		
		public var currentlySelectedTabIndex:int = -1;
		protected function onTabListItemSelected( event:ListEvent ):void
		{
			if (event.index != currentlySelectedTabIndex)
			{
				currentlySelectedTabIndex = event.index;
				
				if (event.itemRenderer && txtTitle)
				{
					txtTitle.htmlText = (event.itemRenderer as TabListItem).GetLocKey();
					txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);
				}
				
				// Used for tutorials
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnTabChanged", [currentlySelectedTabIndex]));
				
				var tablistItem:TabListItem = mcTabList.getRendererAt(event.index) as TabListItem;
				if (mcTabBackground && tablistItem.getIconData() != "")
				{
					mcTabBackground.gotoAndStop(tablistItem.getIconData());
				}
				
				if ( !noDelay && InputManager.getInstance().isGamepad() )
				{
					if ( !_updateTimer )
					{
						_updateTimer = new Timer( 350, 1 );
						_updateTimer.addEventListener( TimerEvent.TIMER, OnUpdateTimer, false, 0, true );
						_updateTimer.start();
					}
					else
					{
						_updateTimer.stop();
						_updateTimer.reset();
						_updateTimer.start();
					}
				}
				else
				{
					updateSubData(currentlySelectedTabIndex);
				}
				
			}
		}
		
		private var _updateTimer : Timer;
		private function OnUpdateTimer( event:TimerEvent ):void
		{
			updateSubData( currentlySelectedTabIndex );
		}
		
		protected var lastUpdatedSubDataIndex = -1;
		protected var subDataTweener:GTween;
		protected function handleTweenComplete(curTween:GTween):void
		{
			subDataTweener = null;
		}
		
		protected function requestTabdata(index:int):void
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, tabDataEventName, [index]) );
		}
		
		protected function enterframe_pendingTabRequest(event:Event):void
		{
			if (_pendingTabDataRequest != -1)
			{
				requestTabdata(_pendingTabDataRequest);
				_pendingTabDataRequest = -1;
			}
			
			removeEventListener(Event.ENTER_FRAME, enterframe_pendingTabRequest);
		}
		
		protected function updateSubData(index:int):void
		{
			if (subDataDictionary[index] == null)
			{
				_pendingTabDataRequest = index;
				addEventListener(Event.ENTER_FRAME, enterframe_pendingTabRequest, false, 0, true);
			}
			else
			{
				var currentSlot:SlotBase;
				var slotsListBase:SlotsListBase;
				var oldSelection:int;
				
				if (lastUpdatedSubDataIndex != index)
				{
					var targetUIComponent:UIComponent = getDataShowerForTab(lastUpdatedSubDataIndex);
					
					if (targetUIComponent)
					{
						targetUIComponent.visible = false;
						
						if (targetUIComponent is SlotsListBase)
						{
							(targetUIComponent as SlotsListBase).selectedIndex = -1;
						}
					}
					
					lastUpdatedSubDataIndex = index;
					
					targetUIComponent = getDataShowerForTab(lastUpdatedSubDataIndex);
					
					if (targetUIComponent is W3DropDownList)
					{
						(targetUIComponent as W3DropDownList).updateData(subDataDictionary[index]);
						(targetUIComponent as W3DropDownList).SetInitialSelection();
					}
					else if (targetUIComponent is SlotsListBase)
					{
						(targetUIComponent as SlotsListBase).data = subDataDictionary[index];
						targetUIComponent.validateNow();
						
						if (enabled)
						{
							(targetUIComponent as SlotsListBase).findSelection();
							targetUIComponent.validateNow();
						}
						
						if (targetUIComponent is SlotsListGrid)
						{
							(targetUIComponent as SlotsListGrid).offset = 0; // force Reset of scroll offset
						}
					}
					
					if (hideTabBackgroundWhenData && mcTabBackground)
					{
						//mcTabBackground.visible = subDataDictionary[index].length == 0;
					}
					
					if (targetUIComponent)
					{
						targetUIComponent.visible = true;
						targetUIComponent.validateNow();
						
						if (subDataTweener)
						{
							subDataTweener.paused = true;
							GTweener.removeTweens(targetUIComponent);
						}
						
						targetUIComponent.alpha = 0;
						
						var duration:Number = 0.5;
						
						subDataTweener = GTweener.to(targetUIComponent, duration, { alpha: 1 }, {onComplete:handleTweenComplete, ease:Sine.easeOut} );
					}
				}
				else
				{
					targetUIComponent = getDataShowerForTab(lastUpdatedSubDataIndex);
					
					if (targetUIComponent is W3DropDownList)
					{
						(targetUIComponent as W3DropDownList).updateData(subDataDictionary[index]);
					}
					else if (targetUIComponent is SlotsListBase)
					{
						slotsListBase = targetUIComponent as SlotsListBase;
						
						oldSelection = slotsListBase.selectedIndex;
						
						slotsListBase.data = subDataDictionary[index];
						slotsListBase.validateNow();
						
						slotsListBase.ReselectIndexIfInvalid(oldSelection);
						slotsListBase.validateNow();
						
						currentSlot = slotsListBase.getSelectedRenderer() as SlotBase;
					}
				}
				
				UpdateSelectionHighlight();
			}
		}
		
		public function getDataShowerForCurrentTab():UIComponent
		{
			return getDataShowerForTab(mcTabList.selectedIndex);
		}
		
		public function getDataShowerForTab(index:int):UIComponent
		{
			if (mcDropdownList)
			{
				return mcDropdownList;
			}
			else if (mcSlotList)
			{
				return mcSlotList;
			}
			
			return null;
		}
		
		public function handleSetSubData(data:Object):void
		{
			var tabIndex:int = data.tabIndex;
			var dataArray:Array = data.tabData;
			
			trace("GFX - handleSetSubData called for tab: " + tabIndex + ", with data:" + dataArray);
			
			if (!dataArray)
			{
				throw new Error("GFX - handleSetSubData called with invalid parameters: " + tabIndex + ", data:" + dataArray);
			}
			
			setSubData(tabIndex, dataArray);
			
			// Select first tab by default when it's data arrives
			if (currentlySelectedTabIndex == -1 && mcTabList.selectedIndex == -1 && mcTabList && mcTabList.dataProvider.length > 0)
			{
				mcTabList.selectedIndex = tabIndex;
				mcTabList.validateNow();
			}
			
			if (tabIndex == currentlySelectedTabIndex)
			{
				updateSubData(tabIndex);
			}
		}
		
		public function updateDataSurgicallyInCurrentTab(tabIndex:int, data:Array):void
		{
			var tabDataIt:int;
			var dataIt:int;
			var tabData:Array;
			var foundMatchingData:Boolean;
			
			trace("GFX - updating tab: " + tabIndex + ", with data: " + data[0]);
			
			if (subDataDictionary[tabIndex] != null)
			{
				tabData = subDataDictionary[tabIndex];
				
				for (dataIt = 0; dataIt < data.length; ++dataIt)
				{
					foundMatchingData = false;
					
					for (tabDataIt = 0; tabDataIt < tabData.length; ++tabDataIt)
					{
						if (data[dataIt].id == tabData[tabDataIt].id)
						{
							foundMatchingData = true;
							tabData[tabDataIt] = data[dataIt];
							break;
						}
					}
					
					if (!foundMatchingData)
					{
						trace("GFX - data not found to update, adding it - " + tabData[tabDataIt]);
						tabData.push(data[dataIt]);
					}
				}
			}
			/*else
			{
				throw new Error("GFX - updateDataSurgicallyInCurrentTab called with invalid tabIndex:" + tabIndex);
			}*/
		}
		
		public function removeDataSurgicallyInCurrentTab(tabIndex:int, dataIds:Array):void
		{
			var tabDataIt:int;
			var dataIt:int;
			var tabData:Array;
			var foundMatchingData:Boolean;
			
			if (subDataDictionary[tabIndex] != null)
			{
				tabData = subDataDictionary[tabIndex];
				
				for (dataIt = 0; dataIt < dataIds.length; ++dataIt)
				{
					for (tabDataIt = 0; tabDataIt < tabData.length; ++tabDataIt)
					{
						if (dataIds[dataIt] == tabData[tabDataIt].id)
						{
							tabData.splice(tabDataIt, 1);
							break;
						}
					}
				}
			}
			else
			{
				throw new Error("GFX - removeDataSurgicallyInCurrentTab called with invalid tabIndex:" + tabIndex);
			}
		}
		
		protected function setSubData(index:int, data:Array):void
		{
			subDataDictionary[index] = data;
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if (event.handled || !_inputEnabled)
			{
				return;
			}
			
			if (mcTabList)
			{
				mcTabList.handleInput(event);
			}
			
			if (!focused || event.handled)
				return;
			
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if (handler && handler.visible)
				{
					if (handler is SlotsListBase)
					{
						(handler as SlotsListBase).handleInputNavSimple(event);
					}
					else
					{
						handler.handleInput( event );
					}

					if ( event.handled )
					{
						return;
					}
				}
			}
		}
		
		protected function tabListNavEnabled():Boolean
		{
			return true;
		}
		
		protected function handleTabDataSet1(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet2(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet3(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet4(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet5(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet6(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet7(data:Object):void
		{
			handleSetSubData(data);
		}
		
		protected function handleTabDataSet8(data:Object):void
		{
			handleSetSubData(data);
		}
	}
}
