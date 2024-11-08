package red.game.witcher3.menus.preparation_menu 
{
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.CoreMenu;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	// #J Should rename but to save time just changing base class
	public class PreparationDropdownMenu extends CoreMenuModule
	{
		public var mcTabList      : W3ScrollingList;
		public var mcTabListItem1 : TabListItem;
		public var mcTabListItem2 : TabListItem;
		public var mcTabListItem3 : TabListItem;
		public var mcTabListItem4 : TabListItem;
		public var txtTabName     : TextField;
		
		public var mcGridSlots    : SlotsListGrid;
		public var mcScrollBar    : ScrollBar;
		
		protected var tabData:Array = null;
		
		private var _leftStickNavigation:Boolean = false;
		private var _lastSelectedRow:int = 0;
		private var _fromLeft:Boolean = false;
		
		private var _inputSymbolIDA:int = -1;
		private var _inputSymbolIDPad:int = -1;
		
		public var canEquipSteelOil:Boolean = true;
		public var canEquipSilverOil:Boolean = true;
		
		override protected function configUI():void 
		{
			super.configUI();
			
			if (mcTabList)
			{
				// #J the order of this list should match EPreporationItemType in witcherscript
				mcTabList.dataProvider = new DataProvider( [ { icon:"Bombs", locKey:"[[panel_inventory_paperdoll_slotname_petards]]", categoryName:"pertard" }, 
															 { icon:"Potion", locKey:"[[panel_inventory_paperdoll_slotname_potions]]", categoryName:"potion" },
															 { icon:"Oils", locKey:"[[panel_inventory_paperdoll_slotname_oils]]", categoryName:"oil" }, 
															 { icon: "Mutagens", locKey:"[[panel_inventory_paperdoll_slotname_mutagen]]", categoryName:"mutagen" } ] );
				mcTabList.validateNow();
				mcTabList.ShowRenderers(true);
				mcTabList.addEventListener(ListEvent.INDEX_CHANGE, onTabListItemSelected, false, 0, true);
				mcGridSlots.addEventListener(ListEvent.INDEX_CHANGE, onGridItemSelected, false, 0, true);
				mcTabList.tabEnabled = false;
				mcTabList.tabChildren = false;
				mcTabList.focusable = false;
			}
			
			if (mcGridSlots)
			{
				_inputHandlers.push(mcGridSlots);
				mcGridSlots.focusable = false;
				mcGridSlots.handlesRightJoystick = true;
				mcGridSlots.handleScrollBar = true;
			}
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'preparation.slot.silversword.locked', [ updateCanEquipSilverOil ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'preparation.slot.steelsword.locked', [ updateCanEquipSteelOil ] ) );
			
			intitializeTabData();
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'preparations.items.list', [handleListData]));
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}
		
		override public function hasSelectableItems():Boolean
		{
			if (mcGridSlots.getSelectedRenderer() == null || (mcGridSlots.getSelectedRenderer() as SlotBase).data == null)
			{
				return false;
			}
			
			return true;
		}
		
		protected function updateCanEquipSilverOil(value:Boolean):void
		{
			canEquipSilverOil = !value;
		}
		
		protected function updateCanEquipSteelOil(value:Boolean):void
		{
			canEquipSteelOil = !value;
		}
		
		private var _lastTabSelected:int = -1;
		private function onTabListItemSelected( event:ListEvent ):void
		{
			if (_lastTabSelected == event.index)
			{
				return;
			}
			
			_lastTabSelected = event.index;
			
			if (event.itemRenderer)
			{
				txtTabName.text = (event.itemRenderer as TabListItem).GetLocKey();
			}
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnTabChanged", [event.index]));
			
			udpdateGrid(event.index);
			HandleNewTabFirstSelection(event.index);
		}
		
		protected function HandleNewTabFirstSelection(index:int):void
		{
			trace("GFX - Triggered New Tab Selection, leftjoy?: ", _leftStickNavigation, ", lastRow: ", _lastSelectedRow, ", fromLeft?: ", _fromLeft);
			
			if (_leftStickNavigation && _lastSelectedRow >= 0)
			{
				_leftStickNavigation = false;
				
				var numColumns:int = mcGridSlots.numColumns;
				var numElements:int = tabData[index].length;
				
				if (!_fromLeft)
				{
					mcGridSlots.selectedIndex = Math.min(Math.floor(tabData[index].length / numColumns), _lastSelectedRow) * numColumns;
				}
				else
				{
					var currentSearchIndex:int = (_lastSelectedRow + 1) * numColumns - 1;
					
					while (currentSearchIndex > 0)
					{
						var currentRenderer:SlotBase = mcGridSlots.getRendererAt(currentSearchIndex) as SlotBase;
						
						if (currentRenderer && (currentRenderer.data != null || !currentRenderer.isEmpty()))
						{
							mcGridSlots.selectedIndex = currentSearchIndex;
							break;
						}
						
						currentSearchIndex -= numColumns;
					}
					
					if (currentSearchIndex < 0)
					{
						mcGridSlots.findSelection();
					}
				}
			}
			else
			{
				mcGridSlots.findSelection();
			}
			mcGridSlots.validateNow();
			
			trace("GFX - Resulting selected index: ", mcGridSlots.selectedIndex);
		}
		
		private function onGridItemSelected( event:ListEvent ):void
		{
			var currentSlot:SlotInventoryGrid = mcGridSlots.getRendererAt(event.index) as SlotInventoryGrid;
			if (currentSlot)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectInventoryItem", [currentSlot.data.id, currentSlot.data.slotType]));
			}
			
			SetItemSlotTooltip();
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			
			if (mcGridSlots.selectedIndex != -1)
			{
				(mcGridSlots.getSelectedRenderer() as SlotBase).showTooltip();
			}
			
			if (focused && _inputSymbolIDPad == -1)
			{
				_inputSymbolIDPad = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_DPAD_LR, -1, "panel_button_common_change_tab"); // #J for pc, could put arrow keys but keycode not currently supported
			}
			else if (!focused && _inputSymbolIDPad != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDPad);
				_inputSymbolIDPad = -1;
			}
			
			// #J Note because of SetItemSlotTooltip(), we don't need to call InputFeedbackManager.updateButtons(this); directly, if you remove it please add the call
			
			var currentSlot:SlotBase = mcGridSlots.getSelectedRenderer() as SlotBase;
			
			if (currentSlot)
			{
				currentSlot.activeSelectionEnabled = value;
			}
			
			SetItemSlotTooltip();
		}
		
		public function SetItemSlotTooltip()
		{
			if (_inputSymbolIDA != -1) 
			{ 
				InputFeedbackManager.removeButton(this, _inputSymbolIDA); 
				_inputSymbolIDA = -1;
			}
			
			if (focused)
			{
				var currentItem:SlotInventoryGrid = mcGridSlots.getSelectedRenderer() as SlotInventoryGrid;
				
				if (currentItem && canEquip(currentItem))
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, -1, "panel_button_inventory_equip"); // #J not sure what PC control will be (if any)
				}
			}
			
			InputFeedbackManager.updateButtons(this);
		}
		
		public function canEquip(sourceSlot:SlotInventoryGrid):Boolean
		{
			if ((sourceSlot.data.steelOil == false || canEquipSteelOil) &&
				(sourceSlot.data.silverOil == false || canEquipSilverOil))
			{
				return true;
			}
			
			return false;
		}
		
		private function udpdateGrid(index:uint):void
		{
			if (index > tabData.length)
			{
				throw new Error("GFX - PreparationDropdownMenu tried to updrade grid with an unknown index: " + index + " when tab data length: " + tabData.length);
			}
			
			var dataArray:Array = tabData[index];
			
			// Some data manipulation for this menu so that they are always positioned optimally
			dataArray.sortOn("id");
			
			for (i = 0; i < dataArray.length; ++i)
			{
				dataArray[i].gridPosition = i;
			}
			
			mcGridSlots.data = dataArray;
			mcGridSlots.validateNow();
			
			var currentSlot:SlotInventoryGrid;
			
			for (var i:int = 0; i < mcGridSlots.getRenderersCount(); ++i)
			{
				currentSlot = mcGridSlots.getRendererAt(i) as SlotInventoryGrid;
				if (currentSlot)
				{
					currentSlot.useContextMgr = false;
				}
			}
			
			if (focused == 1 && (mcGridSlots.getSelectedRenderer() == null || (mcGridSlots.getSelectedRenderer() as SlotBase).data == null))
			{
				stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE, false, false));
			}
			
			mcGridSlots.validateNow();
			
			currentSlot = mcGridSlots.getSelectedRenderer() as SlotInventoryGrid;
			
			if (currentSlot != null && currentSlot.data != null)
			{
				currentSlot.activeSelectionEnabled = this.focused;
			}
		}
		
		private function intitializeTabData():void
		{
			var i:int;
			
			// #J tabData should be the same length as the tab list data provider
			if (!tabData)
			{
				tabData = new Array();
				
				
				for (i = 0; i < mcTabList.dataProvider.length; ++i)
				{
					tabData.push(new Array());
				}
			}
			else
			{
				for (i = 0; i < mcTabList.dataProvider.length; ++i)
				{
					tabData[i].length = 0;
				}
			}
		}
		
		public function handleListData( gameData:Object ):void
		{
			intitializeTabData();
			
			var dataArray:Array = gameData as Array;
			
			if (!dataArray)
				return;
			
			var i:int;
			
			for (i = 0; i < dataArray.length; ++i)
			{
				if (dataArray[i].prepItemType > tabData.length || dataArray[i].prepItemType < 1)
				{
					throw new Error("GFX - PreparationDropdownMenu Unsupported prepItemType sent from witcher script!!!!!!!!!!");
				}
				else
				{
					dataArray[i].actionType = 0; // #J fastest way to turn off the automatic action system, too busy to do it clean
					dataArray[i].gridPosition = tabData[dataArray[i].prepItemType - 1].length;
					tabData[dataArray[i].prepItemType - 1].push(dataArray[i]);
				}
			}
			
			if (mcTabList.selectedIndex == -1)
			{
				mcTabList.selectedIndex = 0;
				stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE, false, false));
			}
			else
			{
				udpdateGrid(mcTabList.selectedIndex);
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{	
			if (event.handled)
			{
				return;
			}
			
			mcTabList.handleInput(event);
			
			if (!focused || event.handled)
				return;
			
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if (handler)
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
						event.stopImmediatePropagation();
						return;
					}
				}
			}
		}
	}

}
