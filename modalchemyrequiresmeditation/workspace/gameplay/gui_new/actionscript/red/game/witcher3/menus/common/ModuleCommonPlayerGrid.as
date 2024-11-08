/***********************************************************************
/** Player grid module : Base Version common for repair and Inventory
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreHudModule;
	import red.core.CoreMenu;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.DebugDataProvider;
	import red.game.witcher3.constants.InventoryFilterType;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.ItemDragEvent;
	import red.game.witcher3.interfaces.IAbstractItemContainerModule;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotDragAvatar;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotsTransferManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
		
	public class ModuleCommonPlayerGrid extends CoreMenuModule implements IAbstractItemContainerModule
	{	
		public var mcPlayerGrid   : SlotsListGrid;
		public var mcScrollBar 	  : ScrollBar;
		
		public var autoGridFocus  : Boolean = true;
		
		protected var _dragManager:SlotsTransferManager;
		protected var _moduleDisplayName : String = "";
		
		private var dataSetOnce:Boolean = false;
		
		protected var _resetSelectionOnNextHandleData:Boolean = false;
		
		override public function hasSelectableItems():Boolean
		{
			if (mcPlayerGrid.getSelectedRenderer() == null || (mcPlayerGrid.getSelectedRenderer() as SlotBase).data == null)
			{
				return false;
			}
			
			return true;
		}
		
		public function ModuleCommonPlayerGrid()
		{
			super();
			dataBindingKey= "repair.grid.player";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleDataSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + ".itemUpdate", [handleItemUpdate]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + ".itemsUpdate", [handleItemsUpdate]));
			addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			initControls();
		}
		
		protected function initControls():void
		{
			if (!Extensions.isScaleform)
			{
				initDebugMode();
			}
			mcPlayerGrid.focusable = false;
			_dragManager = SlotsTransferManager.getInstance();
			_dragManager.addEventListener(ItemDragEvent.START_DRAG, handleStartDrag, false, 0, true);
			_dragManager.addEventListener(ItemDragEvent.STOP_DRAG, handleStopDrag, false, 0, true);
		}
		
		protected function handleStopDrag(event:ItemDragEvent):void	{}
		protected function handleStartDrag(event:ItemDragEvent):void{}
		
		public function inventoryRemoveItem( itemId:int ):void
		{
			mcPlayerGrid.removeItem(itemId);
		}
		
		protected function handleDataSet( gameData:Object, index:int ):void
		{	
			if (gameData) 
			{
				var oldSelectedIndex:int = mcPlayerGrid.selectedIndex;
				
				mcPlayerGrid.data = gameData as Array;
				mcPlayerGrid.validateNow();
				
				if (!_resetSelectionOnNextHandleData)
				{
					mcPlayerGrid.ReselectIndexIfInvalid(oldSelectedIndex);
				}
				_resetSelectionOnNextHandleData = false;
				
				invalidate(INVALIDATE_CONTEXT);
				//updateActiveContext(mcPlayerGrid.getSelectedRenderer() as SlotBase);
			}
			
			if (!dataSetOnce || 
				(focused == 1 && (mcPlayerGrid.getSelectedRenderer() == null || (mcPlayerGrid.getSelectedRenderer() as SlotBase).data == null)))
			{
				dataSetOnce = true;
				stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE, false, false));
			}
			
			mcPlayerGrid.validateNow();
			
			var currentSlot:SlotBase = mcPlayerGrid.getSelectedRenderer() as SlotBase;
			
			if (currentSlot != null && currentSlot.data != null)
			{
				currentSlot.activeSelectionEnabled = this.focused != 0;
			}
		}
		
		protected function updateActiveContext(currentSlot:SlotBase):void {}
		
		protected function handleItemUpdate( itemData:Object ):void
		{
			var tstDataObj:ItemDataStub = itemData as ItemDataStub;
			mcPlayerGrid.updateItemData(itemData);
			invalidate(INVALIDATE_CONTEXT);
		}
		
		public function handleItemRemoved( itemId:int ):void
		{
			mcPlayerGrid.removeItem(itemId);
			invalidate(INVALIDATE_CONTEXT);
		}
		
		protected function handleItemsUpdate(itemsList:Array):void
		{
			trace("GFX handleItemsUpdate ", itemsList);
			
			mcPlayerGrid.updateItems(itemsList);
			invalidate(INVALIDATE_CONTEXT);
		}
		
		protected function bindInventory():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetCurrentPlayerGrid', [dataBindingKey] ) ); // ?
		}
		
		/*
		 * 								- Core -
		 */
						
		
		override public function set focused(value:Number):void
		{
			if (value > 0 && value != _focused)
			{
				bindInventory();
			}
			
			super.focused = value;
			
			if (autoGridFocus)
			{
				mcPlayerGrid.focused = _focused;
			}
			else if (mcPlayerGrid.selectedIndex < 0)
			{
				mcPlayerGrid.findSelection();
			}
			
			var currentSlot:SlotBase = mcPlayerGrid.getSelectedRenderer() as SlotBase;
			
			if (currentSlot)
			{
				currentSlot.activeSelectionEnabled = value != 0;
			}
		}
		
		/*
		* 								- Utils -
		*/
		
		public function get CurrentItemDataStub():ItemDataStub
		{
			return null;
		}
		
		private function initDebugMode():void
		{
			handleDataSet(DebugDataProvider.GetGridDebugData(), 0);
		}
		
		override public function toString():String
		{
			return "[W3 ModuleCommonPlayerGrid]"
		}
	}
}
