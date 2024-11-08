/***********************************************************************
/** PANEL glossary characters main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.modules
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.plugins.ColorTransformPlugin;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.AdvancedTabListItem;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3DropDownList;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.FiniteStateMachine;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.WrappingMode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;

	public class CollapsableTabbedListModule extends TabbedScrollingListModule
	{
		protected var stateMachine:FiniteStateMachine;
		protected static const State_Colapsed : String = "collapsed";
		protected static const State_Open : String = "open";
		
		protected static const ClosedListAlpha : Number = 1;
		protected static const ClosedListScale : Number = 1; //0.85;
		
		public var _isFirstTabSelection:Boolean = true;
		
		public var mcListContainer:MovieClip;
		
		public var openedCallback:Function;
		public var closedCallback:Function;
		
		protected var _inputSymbolIDA:int = -1;
		protected var _inputSymbolIDB:int = -1;
		protected var lastSelection:int = -1;
		
		protected var _hideInputFeedback:Boolean;
		
		protected var bToCloseEnabled:Boolean = false;
		
		override protected function configUI():void
		{
			setupStateMachine();
			super.configUI();

			addToListContainer(mcSlotList);
			addToListContainer(mcDropdownList);
			addToListContainer(mcScrollbar);
			addToListContainer(mcTabBackground);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 100, true);
			
			if (mcTabList)
			{
				mcTabList.addEventListener(ListEvent.ITEM_CLICK, onTabListItemClick, false, 1, true);
			}
		}
		
		protected var _tabsAutoAlign:Boolean = false;
		public function get tabsAutoAlign():Boolean { return _tabsAutoAlign }
		public function set tabsAutoAlign(value:Boolean):void
		{
			_tabsAutoAlign = value;
		}
		
		protected function addToListContainer(component:MovieClip):void
		{
			var xOffset:Number;
			var yOffset:Number;
			
			if (mcListContainer && component)
			{
				xOffset = component.x - mcListContainer.x;
				yOffset = component.y - mcListContainer.y;
				
				mcListContainer.addChild(component);
				
				component.x = xOffset;
				component.y = yOffset;
			}
		}

		protected function setupStateMachine():void
		{
			stateMachine = new FiniteStateMachine();

			stateMachine.AddState(State_Colapsed, 	state_colapsed_begin, 	null, null);
			stateMachine.AddState(State_Open, 		state_Open_begin, 		null, null);
		}

		public function get isOpen():Boolean
		{
			return stateMachine.currentState == State_Open;
		}

		public function open():void
		{
			// Can't open empty tabs ><
			if (stateMachine.currentState != State_Open &&
				((mcTabList.selectedIndex != -1 && subDataDictionary[mcTabList.selectedIndex] != null && subDataDictionary[mcTabList.selectedIndex].length > 0) ))
			{
				stateMachine.ChangeState(State_Open);
			}
		}

		public function forceOpen():void
		{
			if (stateMachine.currentState != State_Open)
			{
				stateMachine.ChangeState(State_Open);
			}
		}

		public function close():void
		{
			if (stateMachine.currentState != State_Colapsed)
			{
				stateMachine.ChangeState(State_Colapsed);
			}
		}
		
		// #Y skip opening animation for mouse click
		protected var _handledItemClick:Boolean = false;
		protected function onTabListItemClick( event:ListEvent ):void
		{
			_handledItemClick = true;
			dispatchEvent(new Event(EVENT_MOUSE_FOCUSE));
		}

		override protected function onTabListItemSelected( event:ListEvent ):void
		{
			super.onTabListItemSelected(event);
			
			lastSelection = -1;
			
			if (!isOpen)
			{
				if (_handledItemClick && !_isFirstTabSelection)
				{
					open();
				}
				else
				{
					if (mcTabBackground)
					{
						mcTabBackground.visible = true;// focused != 0;
					}
				}
			}
			
			_isFirstTabSelection = false;
			updateSelectedTabSelection();
		}

		protected var containerTweener:GTween;
		protected function handleContainerTweenComplete(curTween:GTween):void
		{
			containerTweener = null;
		}
		
		protected function state_colapsed_begin():void
		{
			mcTabList.UpAction = 37;
			mcTabList.DownAction = 39;
			mcTabList.PCUpAction = KeyCode.A;
			mcTabList.PCDownAction = KeyCode.D;
			
			var viewerComponent:UIComponent = getDataShowerForCurrentTab();

			if (viewerComponent)
			{
				viewerComponent.enabled = false;
			}

			if (mcLeftGamepadIcon)
			{
				mcLeftGamepadIcon.visible = false;
			}

			if (mcRightGamepadIcon)
			{
				mcRightGamepadIcon.visible = false;
			}

			var currentDataComponent:UIComponent = getDataShowerForCurrentTab();

			if (currentDataComponent)
			{
				if (currentDataComponent is SlotsListBase)
				{
					lastSelection = (currentDataComponent as SlotsListBase).selectedIndex;
					(currentDataComponent as SlotsListBase).selectedIndex = -1;
				}
				else if (currentDataComponent is W3DropDownList)
				{
					(currentDataComponent as W3DropDownList).selectedIndex = -1;
				}
			}

			if (mcListContainer)
			{

				if (containerTweener)
				{
					containerTweener.paused = true;
					GTweener.removeTweens(mcListContainer);
				}

				containerTweener = GTweener.to(mcListContainer, 0.2, { alpha: ClosedListAlpha, scaleX: ClosedListScale, scaleY:ClosedListScale }, { onComplete:handleContainerTweenComplete, ease:Sine.easeOut } );
			}

			ApplyCloseAnimationToMask();

			updateInputFeedback();
			
			setAllowSelectionHighlight(false);

			mcTabList.wrapping = WrappingMode.NORMAL;

			updateSelectedTabSelection();

			if (closedCallback != null)
			{
				closedCallback();
			}
		}

		protected function state_Open_begin():void
		{
			mcTabList.UpAction = 107;
			mcTabList.DownAction = 109;
			mcTabList.PCUpAction = KeyCode.NUMPAD_4;
			mcTabList.PCDownAction = KeyCode.NUMPAD_6;

			var viewerComponent:UIComponent = getDataShowerForCurrentTab();
			if (viewerComponent)
			{
				viewerComponent.enabled = true;
			}

			if (mcLeftGamepadIcon)
			{
				mcLeftGamepadIcon.visible = true;
			}

			if (mcRightGamepadIcon)
			{
				mcRightGamepadIcon.visible = true;
			}
			
			if (focused)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
			}

			updateSelectedTabSelection();

			updateInputFeedback();

			mcTabList.wrapping = WrappingMode.WRAP;

			var currentDataComponent:UIComponent = getDataShowerForCurrentTab();

			if (currentDataComponent)
			{
				if (currentDataComponent is SlotsListBase)
				{
					var slotBase:SlotBase = (currentDataComponent as SlotsListBase).getSelectedRenderer() as SlotBase;
					if (slotBase)
					{
						slotBase.showTooltip();
					}
				}

				if (currentDataComponent is SlotsListBase)
				{
					if (lastSelection != -1)
					{
						(currentDataComponent as SlotsListBase).selectedIndex = lastSelection;
						currentDataComponent.validateNow();
					}
				}
				else if (currentDataComponent is W3DropDownList)
				{
					(currentDataComponent as W3DropDownList).SetInitialSelection();
				}
			}

			if (mcListContainer)
			{
				if (containerTweener)
				{
					containerTweener.paused = true;
					GTweener.removeTweens(mcListContainer);
				}
				
				if (_handledItemClick)
				{
					mcListContainer.scaleX = mcListContainer.scaleY = 1;
					mcListContainer.alpha = 1;
					_handledItemClick = false;
				}
				else
				{
					containerTweener = GTweener.to(mcListContainer, 0.2, { alpha: 1, scaleX: 1, scaleY:1 }, { onComplete:handleContainerTweenComplete, ease:Sine.easeOut } );
				}
			}

			ApplyOpenAnimationToMask();

			setAllowSelectionHighlight(focused != 0);

			if (openedCallback != null)
			{
				openedCallback();
			}
		}

		override public function removeDataSurgicallyInCurrentTab(tabIndex:int, dataIds:Array):void
		{
			super.removeDataSurgicallyInCurrentTab(tabIndex, dataIds);

			closeIfEmpty();
		}

		protected function closeIfEmpty():void
		{
			if (isOpen)
			{
				var currentTabData:Array = subDataDictionary[mcTabList.selectedIndex];

				if (currentTabData == null || currentTabData.length == 0)
				{
					close();
				}
			}
		}

		protected function ApplyCloseAnimationToMask(){}
		protected function ApplyOpenAnimationToMask(){}

		protected function updateSelectedTabSelection()
		{
			var currentTabItem:TabListItem = mcTabList.getSelectedRenderer() as TabListItem;
			if (currentTabItem)
			{
				if (stateMachine.currentState == State_Open)
				{
					currentTabItem.setIsOpen(true);
				}
				else
				{
					currentTabItem.setIsOpen(false);
				}
			}
		}

		override public function hasSelectableItems():Boolean
		{
			return mcTabList != null && mcTabList.dataProvider.length > 0;
		}

		override protected function updateSubData(index:int):void
		{
			super.updateSubData(index);

			var currentDataComponent:UIComponent = getDataShowerForCurrentTab();

			if (currentDataComponent)
			{
				if (stateMachine.currentState != State_Open)
				{
					if (!focused)
					{
						// #Y disable for test
						//currentDataComponent.visible = false;
					}
				}
			}

			UpdateSelectionHighlight();
			
			if (subDataDictionary[index] != null) // Don't do this if we don't even have the data yet
			{
				if (stateMachine.currentState == State_Colapsed && subDataDictionary[index].length > 0 && _lastMoveWasMouse)
				{
					open();
				}
				else
				{
					closeIfEmpty();
				}
			}
			
			updateInputFeedback();
		}
		
		//private var _firstFocused:Boolean = true;
		override public function set focused(value:Number):void
		{
			super.focused = value;

			updateInputFeedback();

			if (stateMachine.currentState != State_Open)
			{
				var currentDataComponent:UIComponent = getDataShowerForCurrentTab();

				/*if (currentDataComponent)
				{
					currentDataComponent.visible = value != 0;
					if (mcTabBackground)
					{
						mcTabBackground.visible = value != 0;
					}
				}*/

				/*if (value != 0 && !_firstFocused)
				{
					if (!_firstFocused)
					{
						mcTabList.selectedIndex = mcTabList.dataProvider.length - 1;
					}
					else
					{
						_firstFocused = false;
					}
				}*/
			}
		}
		
		public function get hideInputFeedback():Boolean { return _hideInputFeedback; }
		public function set hideInputFeedback(value:Boolean):void
		{
			_hideInputFeedback = value;
			
			updateInputFeedback();
		}
		
		override protected function UpdateSelectionHighlight():void
		{
			setAllowSelectionHighlight(isOpen && focused);
		}

		override public function setTabData(data:DataProvider):void
		{
			super.setTabData(data);
			
			/*
			 * align
			 */
			
			if (_tabsAutoAlign)
			{
				const tabPadding:Number = 11;
				
				var tabsList:Vector.<IListItemRenderer> = mcTabList.getRenderers();
				var activeTabsCount:uint = 0;
				var len:int = 0;
				var i:int = 0;
				var rendererWidth:Number = -1;
				var curItem:TabListItem;
				
				len = tabsList.length;
				
				for (i = 0; i < len; ++i)
				{
					curItem = tabsList[i] as TabListItem;
					
					if (curItem && curItem.visible && curItem.hasData())
					{
						activeTabsCount++;
						
						if (rendererWidth < 0)
						{
							rendererWidth = curItem.getRendererWidth();
						}
					}
				}
				
				var allTabsWidth:Number = activeTabsCount * rendererWidth + (activeTabsCount - 1) * tabPadding;
				var initPosition:Number = mcTabList.x - allTabsWidth / 2;
				var curPosition:Number = initPosition;
				
				for (i = 0; i < len; ++i)
				{
					curItem = tabsList[i] as TabListItem;
					
					if (curItem && curItem.visible && curItem.hasData())
					{
						curItem.x = initPosition + rendererWidth / 2;
						initPosition += (rendererWidth + tabPadding);
					}
				}
				
			}
			
			
			/*
			 * #Y disable for test
			 *
			if (!focused)
			{
				mcTabList.selectedIndex = 0;
				mcTabList.validateNow();
				var currentTabItem:AdvancedTabListItem = mcTabList.getSelectedRenderer() as AdvancedTabListItem;

				if (currentTabItem)
				{
					currentTabItem.selectionVisible = false;
				}
			}
			*/
		}

		override protected function fireSelectedItemTooltip():void
		{
			if (isOpen)
			{
				super.fireSelectedItemTooltip();
			}
		}
		
		protected var _lastMoveWasMouse:Boolean = false;
		protected function handleMouseMove(event:MouseEvent):void
		{
			if (!_lastMoveWasMouse)
			{
				_lastMoveWasMouse = true;
				open();
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			var inputDetails:InputDetails = event.details as InputDetails;
			
			CommonUtils.convertWASDCodeToNavEquivalent(inputDetails);
			
			if (inputDetails.navEquivalent == NavigationCode.UP || inputDetails.navEquivalent == NavigationCode.DOWN || inputDetails.navEquivalent == NavigationCode.LEFT || inputDetails.navEquivalent == NavigationCode.RIGHT)
			{
				_lastMoveWasMouse = false;
			}
			
			if (event.handled || !_inputEnabled)
			{
				return;
			}
			
			var validNavigationCode:Boolean = inputDetails.value == InputValue.KEY_HOLD || inputDetails.value == InputValue.KEY_DOWN;
			
			if (stateMachine.currentState == State_Colapsed)
			{
				if (inputDetails.value == InputValue.KEY_UP)
				{
					//if (inputDetails.navEquivalent == NavigationCode.GAMEPAD_L2 ||
					//	(inputDetails.navEquivalent == NavigationCode.GAMEPAD_A && focused))
					if (inputDetails.navEquivalent == NavigationCode.GAMEPAD_A && focused)
					{
						open();
						event.handled = true;
						return;
					}
				}

				if (focused)
				{
					mcTabList.handleInput(event);

					if (validNavigationCode && (inputDetails.navEquivalent == NavigationCode.DOWN || inputDetails.code == KeyCode.S))
					{
						open();
						event.handled = true;
						return;
					}
					
					if (inputDetails.value == InputValue.KEY_DOWN)
					{
						switch (inputDetails.navEquivalent)
						{
							case NavigationCode.RIGHT_STICK_DOWN:
								open();
								event.handled = true;
								break;
						}
					}
				}
			}
			else if (stateMachine.currentState == State_Open)
			{
				if (focused)
				{
					if (inputDetails.value == InputValue.KEY_UP)
					{
						//if (inputDetails.navEquivalent == NavigationCode.GAMEPAD_L2 || inputDetails.navEquivalent == NavigationCode.GAMEPAD_B)
						if (inputDetails.navEquivalent == NavigationCode.GAMEPAD_B && bToCloseEnabled)
						{
							close();
							event.handled = true;
							return;
						}
					}
					
					if (inputDetails.value == InputValue.KEY_DOWN)
					{
						switch (inputDetails.navEquivalent)
						{
							case NavigationCode.RIGHT_STICK_UP:
								close();
								event.handled = true;
								break;
						}
					}
				}
				
				super.handleInput(event);

				if (event.handled == false && focused && validNavigationCode && (inputDetails.navEquivalent == NavigationCode.UP || inputDetails.code == KeyCode.A ))
				{
					close();
					event.handled = true;
					return;
				}
			}
			else
			{
				// for keyboard nav
				super.handleInput(event);
			}
		}

		protected function updateInputFeedbackButtons():void
		{
			if (_inputSymbolIDB != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDB);
				_inputSymbolIDB = -1;
			}
			
			if (_inputSymbolIDA != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDA);
				_inputSymbolIDA = -1;
			}
			
			if (_hideInputFeedback)
			{
				return;
			}
			
			if (stateMachine.currentState == State_Colapsed)
			{
				if (_focused && enabled && mcTabList.selectedIndex != -1 && subDataDictionary[mcTabList.selectedIndex] != null && subDataDictionary[mcTabList.selectedIndex].length > 0)
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, -1, "inputfeedback_common_open_grid");
				}
			}
			else if (stateMachine.currentState == State_Open)
			{
				_inputSymbolIDB = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_B, -1, "inputfeedback_common_close_grid");
			}
		}

		override protected function tabListNavEnabled():Boolean
		{
			return stateMachine.currentState == State_Colapsed;
		}

		protected function updateInputFeedback():void
		{
			updateInputFeedbackButtons();

			InputFeedbackManager.updateButtons(this);
		}
		
		public function refreshButtons():void
		{
			updateInputFeedback();
		}
	}
}
