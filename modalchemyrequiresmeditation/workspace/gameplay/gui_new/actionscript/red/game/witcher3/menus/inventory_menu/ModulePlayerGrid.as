/***********************************************************************
/** Inventory Player grid module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
 * 				Yaroslav Getsevich
/***********************************************************************/
package red.game.witcher3.menus.inventory_menu
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.InventoryFilterType;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.ItemDragEvent;
	import red.game.witcher3.interfaces.IAbstractItemContainerModule;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.common.ModuleCommonPlayerGrid;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.utils.CommonUtils;

	public class ModulePlayerGrid extends ModuleCommonPlayerGrid implements IAbstractItemContainerModule
	{
		private static const INVENTORY_FILTERS_ORDER:Vector.<int> = Vector.<int>( [
			InventoryFilterType.WEAPONS, InventoryFilterType.POTIONS,
			InventoryFilterType.INGREDIENTS, InventoryFilterType.QUEST_ITEMS,
			InventoryFilterType.DEFAULT
		] );

		private static const INVENTORY_FILTERS_LOCALIZATION:Vector.<String> = Vector.<String>( [
			"[[panel_inventory_filter_type_weapons]]",
			"[[panel_inventory_filter_type_alchemy_items]]",
			"[[panel_inventory_filter_type_ingredients]]",
			"[[panel_inventory_filter_type_quest_items]]",
			"[[panel_inventory_filter_type_default]]"
		] );

		private static const HORSE_FILTERS_ORDER:Vector.<int> = Vector.<int>( [
			InventoryFilterType.PLAYER_ITEMS,
			InventoryFilterType.HORSE_ITEMS
		] );

		private static const HORSE_FILTERS_LOCALIZATION:Vector.<String> = Vector.<String>( [
			"[[panel_inventory_filter_type_geralt]]",
			"[[panel_inventory_filter_type_horse]]"
		] );

		protected static const INVALIDATE_FILTER:String = "invalidate_filter";

		public var mcTabList      : W3ScrollingList;
		public var mcTabListItem1 : TabListItem;
		public var mcTabListItem2 : TabListItem;
		public var mcTabListItem3 : TabListItem;
		public var mcTabListItem4 : TabListItem;
		public var mcTabListItem5 : TabListItem;

		public var mcHorseTabList	   : W3ScrollingList;
		public var mcHorseTabListItem1 : TabListItem;
		public var mcHorseTabListItem2 : TabListItem;
		public var maskClip:MovieClip;

		public var tfCurrentState : TextField;

		protected var _gridRenderHeight:int = 520;
		protected var m_defaultPosition:Number;

		protected var _currentInventoryFilterIndex:int = -1;
		protected var filterEventName : String = "OnInventoryFilterSelected";

		protected var _currentFiltersOrders : Vector.<int>;
		protected var _currentFiltersLocalization : Vector.<String>;
		protected var _currentFiltersControl : W3ScrollingList;
		protected var _currentState : String;
		protected var _disableFilters : Boolean;

		public function ModulePlayerGrid()
		{
			super();
			dataBindingKey = "inventory.grid.player";
			autoGridFocus = false;
		}

		public function disableFilters(value:Boolean):void
		{
			_disableFilters = value;
			if (_disableFilters)
			{
				mcTabList.ShowRenderers(false);
				mcHorseTabList.ShowRenderers(false);
				mcTabList.removeEventListener(ListEvent.INDEX_CHANGE, onTabListItemClick);
				mcHorseTabList.removeEventListener(ListEvent.INDEX_CHANGE, onTabListItemClick);
			}
			else
			{
				applyCurrentState();
			}
		}

		protected override function configUI():void
		{
			super.configUI();

			maskClip = parent.getChildByName("mcGridMask") as MovieClip;
			if (maskClip)
			{
				trace("GFX - updating list height from mask to: ", maskClip.height);
				_gridRenderHeight = maskClip.height;
			}

			if (mcPlayerGrid)
			{
				m_defaultPosition = mcPlayerGrid.y;
				mcPlayerGrid.handlesRightJoystick = false;
			}

			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + ".name", [handleGridNameSet]));
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			initControls();
		}

		protected override function initControls():void
		{
			super.initControls();

			if (mcTabList && mcHorseTabList)
			{
				//mcTabList.dataProvider = new DataProvider( [ { icon:"WEAPONS" }, { icon:"POTIONS" }, { icon: "INGREDIENTS" } , { icon: "QUEST_ITEMS" }, { icon: "DEFAULT" } ] );
				mcTabList.dataProvider = new DataProvider( [ { icon:"INGREDIENTS" }, { icon:"QUEST_ITEMS" }, { icon: "DEFAULT" } , { icon: "POTIONS" }, { icon: "WEAPONS" } ] );
				mcHorseTabList.dataProvider = new DataProvider( [ { icon:"HORSE_ITEMS" }, { icon:"PLAYER_ITEMS" } ] );
				mcTabList.validateNow();
				mcHorseTabList.validateNow();
				mcTabList.ShowRenderers(false);
				mcHorseTabList.ShowRenderers(false);
			}
			mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE, handleSlotChanged, false, 0 , true);
		}

		public function get currentState():String { return _currentState }
		public function set currentState(value:String):void
		{
			trace("GFX currentState; _currentState: ", _currentState, "; value: ", value);

			if (_currentState != value)
			{
				_currentInventoryFilterIndex = -1;
				_currentState = value;
				applyCurrentState();
			}
		}

		protected function applyCurrentState():void
		{
			switch (_currentState)
			{
				case MenuInventory.STATE_CHARACTER:
					mcPlayerGrid.ignoreGridPosition = false;
					setPlayerFiltrers();
					break;
				case MenuInventory.STATE_HORSE:
					mcPlayerGrid.ignoreGridPosition = true;
					setHorseFilters();
					break;
			}
		}

		protected function setPlayerFiltrers():void
		{
			if (_disableFilters) return;

			mcTabList.addEventListener(ListEvent.INDEX_CHANGE, onTabListItemClick, false, 0, true);
			mcTabList.ShowRenderers(true);
			mcHorseTabList.ShowRenderers(false);
			mcHorseTabList.removeEventListener(ListEvent.INDEX_CHANGE, onTabListItemClick);
			_currentFiltersControl = mcTabList;
			_currentFiltersLocalization = INVENTORY_FILTERS_LOCALIZATION;
			_currentFiltersOrders = INVENTORY_FILTERS_ORDER;

			// #Y TODO: Get saved position
			mcTabList.selectedIndex = 0;
			selectInventoryFilterIndex(mcTabList.selectedIndex);
		}

		protected function setHorseFilters():void
		{
			if (_disableFilters) return;

			mcHorseTabList.ShowRenderers(true);
			mcHorseTabList.addEventListener(ListEvent.INDEX_CHANGE, onTabListItemClick, false, 0, true);
			mcTabList.ShowRenderers(false);
			mcTabList.removeEventListener(ListEvent.INDEX_CHANGE, onTabListItemClick);
			_currentFiltersControl = mcHorseTabList;
			_currentFiltersLocalization = HORSE_FILTERS_LOCALIZATION;
			_currentFiltersOrders = HORSE_FILTERS_ORDER;

			// #Y TODO: Get saved position
			mcHorseTabList.selectedIndex = 0;
			selectInventoryFilterIndex(mcHorseTabList.selectedIndex);
		}

		public function SetOverburdened(value:Boolean):void
		{
			var i:int;
			var curRenderer:SlotInventoryGrid;

			for (i = 0; i < mcPlayerGrid.getRenderersLength(); i += 1)
			{
				curRenderer = mcPlayerGrid.getRendererAt(i) as SlotInventoryGrid;

				if (curRenderer)
				{
					curRenderer.setOverburdened(value);
				}
			}
		}

		// transfer data to context managers
		protected function handleSlotChanged(event:ListEvent):void
		{
			if (focused > 0)
			{
				var currentSlot:SlotBase = event.itemRenderer as SlotBase;

				//updateActiveContext(currentSlot);
				invalidate(INVALIDATE_CONTEXT);

				if (currentSlot)
				{
					var curScrollValue:Number = mcPlayerGrid.scrollBar.position;
					var itemY:int = currentSlot.y;
					var itemHeight:int = currentSlot.getSlotRect().height;

					if (((itemY + itemHeight) > _gridRenderHeight + curScrollValue))
					{
						// to bottom edge
						mcPlayerGrid.scrollBar.position = itemY + itemHeight - _gridRenderHeight;
					}
					else if (itemY < curScrollValue)
					{
						// to top edge
						mcPlayerGrid.scrollBar.position = itemY;
					}
				}
			}
		}

		override public function set focused(value:Number):void
		{
			// #Y hide tooltips; warning: may be a problem with kb/mouse!
			// mcPlayerGrid.enabled = value > 0;

			super.focused = value;

			invalidate(INVALIDATE_CONTEXT);
		}

		override protected function handleModuleSelected():void
		{
			super.handleModuleSelected();
			if (mcPlayerGrid.selectedIndex < 0)
			{
				mcPlayerGrid.findSelection();
			}
			invalidate(INVALIDATE_CONTEXT);
		}

		override protected function updateActiveContext(currentSlot:SlotBase):void
		{
			var slotType:uint = 0;
			var targetId:uint = 0;
			var targetPoint:Point = new Point();

			if (currentSlot && enabled)
			{
				var slotData:ItemDataStub = currentSlot.data as ItemDataStub;
				if (slotData)
				{
					targetId = slotData.id;
					slotType = slotData.slotType;
				}
				var targetX:Number = currentSlot.x + currentSlot.getSlotRect().width;
				var targetY:Number = currentSlot.y + currentSlot.getSlotRect().height;
				targetPoint = currentSlot.parent.localToGlobal(new Point(targetX, targetY));
			}
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectInventoryItem", [targetId, slotType, targetPoint.x, targetPoint.y]));
		}

		protected override function handleStartDrag(event:ItemDragEvent):void
		{
			var itemData:ItemDataStub = event.targetItem.getDragData() as ItemDataStub;
			var dargTarget:SlotBase = event.targetItem as SlotBase;
			if (dargTarget && dargTarget.owner != mcPlayerGrid)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSetInventoryGridFilter", [itemData.id]));
			}
		}

		/*
		 * 							-Witcher Script-
		 */

		public function forceSelectTab( filterType : int ):void
		{
			for ( var i : int = 0; i < _currentFiltersOrders.length; i++ )
			{
				if (_currentFiltersOrders[i] == filterType )
				{
					selectInventoryFilterIndex(i);
				}
			}
		}

		public function forceSelectItem( itemPosition : int ) : void // #B
		{
			if ( mcPlayerGrid )
			{
				mcPlayerGrid.selectedIndex = itemPosition;
			}
		}

		protected function handleGridNameSet( name : String ):void
		{
			if (tfCurrentState)
			{
				_moduleDisplayName = name;
				tfCurrentState.htmlText = name;
			}
		}

		protected function applyFilter(currentFilterType:int):void
		{
			if (!_disableFilters)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, filterEventName, [currentFilterType]));
				invalidate(INVALIDATE_CONTEXT);
			}
		}

		/*
		 * 								- Core -
		 */

		override protected function draw():void
		{
			super.draw();
			if (isInvalid(INVALIDATE_FILTER))
			{
				updateFilter();
			}
			if (isInvalid(INVALIDATE_CONTEXT))
			{
				var curSlot:SlotBase = mcPlayerGrid.getRendererAt(mcPlayerGrid.selectedIndex) as SlotBase;
				updateActiveContext(curSlot);
			}
		}

		private function onTabListItemClick( event:ListEvent ):void
		{
			_currentFiltersControl.selectedIndex = event.index;
			selectInventoryFilterIndex(event.index);
		}

		protected function selectInventoryFilterIndex( filterIndex:int ):void
		{
			if ( _currentInventoryFilterIndex != filterIndex )
			{
				_resetSelectionOnNextHandleData = true;
				_currentInventoryFilterIndex = filterIndex;
				invalidate(INVALIDATE_FILTER);
			}
		}

		protected function updateFilter():void
		{
			if (_currentInventoryFilterIndex > -1)
			{
				var currentFilterType:int = _currentFiltersOrders[ _currentInventoryFilterIndex ];
				if (tfCurrentState)
				{
					tfCurrentState.htmlText = _currentFiltersLocalization[ _currentInventoryFilterIndex ];
					tfCurrentState.htmlText = CommonUtils.toUpperCaseSafe(tfCurrentState.htmlText);
				}
				_currentInventoryFilterIndex = _currentInventoryFilterIndex;
				if (_currentFiltersControl)
				{
					_currentFiltersControl.selectedIndex = _currentInventoryFilterIndex;
				}
				applyFilter(currentFilterType);
			}
		}

		override public function handleInput(event:InputEvent):void
		{
			if (event.handled)
			{
				return;
			}
			
			// Handle the filters even if they don't have controls
			if (_currentFiltersControl)
			{
				_currentFiltersControl.handleInput(event);
			}
			
			if (!focused)
			{
				return;
			}
			
			if (!event.handled)
			{
				mcPlayerGrid.handleInputNavSimple(event);
			}
			
			if (!event.handled)
			{
				super.handleInput(event);
			}
		}

		/*
		* 								- Utils -
		*/

		override public function toString():String
		{
			return "[W3 ModulePlayerGrid]"
		}
	}
}
