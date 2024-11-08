package red.game.witcher3.menus.inventory_menu
{
	import flash.display.MovieClip;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotDragAvatar;
	import scaleform.clik.events.ListEvent;
	
	/**
	 * Grid module for shop/container
	 * @author Getsevich Yaroslav
	 */
	public class ModuleContainer extends ModulePlayerGrid implements IDropTarget
	{
		public var mcStateDropTarget:MovieClip;
		
		public function ModuleContainer()
		{
			super();
			dataBindingKey = "inventory.grid.container";
			filterEventName = "OnContainerFilterSelected";
			
			mcPlayerGrid.dropEnabled = false;
			mcStateDropTarget.visible = false;
		}

		override public function hasSelectableItems():Boolean
		{
			if (mcPlayerGrid.getSelectedRenderer() == null || (mcPlayerGrid.getSelectedRenderer() as SlotBase).data == null)
			{
				mcPlayerGrid.ReselectIndexIfInvalid();
				if (mcPlayerGrid.getSelectedRenderer() == null || (mcPlayerGrid.getSelectedRenderer() as SlotBase).data == null)
					return false;
			}

			return true;
		}
		
		override protected function handleDataSet( gameData:Object, index:int ):void
		{
			super.handleDataSet( gameData, index );
			mcPlayerGrid.validateNow();
		}
		
		override protected function initControls():void
		{
			mcPlayerGrid.handleScrollBar = true;
			mcPlayerGrid.ignoreGridPosition = true;
			mcPlayerGrid.focusable = false;
			mcPlayerGrid.focused = 0;
			focused = 0;
			
			mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE, handleSlotChanged, false, 0 , true);
		}
		
		override protected function updateActiveContext(currentSlot:SlotBase):void 
		{
			if (focused)
			{
				super.updateActiveContext(currentSlot);
			}
		}
		
		override public function toString() : String
		{
			return "[W3 ModuleContainer]"
		}
		
		
		/*
		 * DRAG & DROP
		 */
		
		// #Y TODO: Remove, move this logic to the menu level
		// MenuInventory :: IMS_Player, IMS_Shop, IMS_Container
		protected var _dropMode:int;
		public function get dropMode():int { return _dropMode }
		public function set dropMode(value:int):void
		{
			_dropMode = value;
		}
		
		protected var _dropSelection:Boolean;
		public function get dropSelection():Boolean { return _dropSelection; }
        public function set dropSelection(value:Boolean):void
		{
			_dropSelection = value;
		}
		
		protected var _dropEnabled:Boolean;
		public function get dropEnabled():Boolean { return _dropEnabled; }
        public function set dropEnabled(value:Boolean):void
		{
			_dropEnabled = value;
		}
		
		public function processOver(avatar:SlotDragAvatar):int
		{
			if (avatar)
			{
				var isInternal:Boolean = avatar.getSourceContainer() == mcPlayerGrid;
				
				if (!isInternal)
				{
					mcStateDropTarget.visible = _dropSelection && avatar;
					return SlotDragAvatar.ACTION_DROP;
				}
				else
				{
					mcStateDropTarget.visible = false;
					return SlotDragAvatar.ACTION_NONE;
				}
			}
			else
			{
				mcStateDropTarget.visible = false;
				return SlotDragAvatar.ACTION_NONE;
			}
			
		}
		
		public function canDrop(sourceObject:IDragTarget):Boolean
		{
			var sourceRenderer:IInventorySlot = sourceObject as IInventorySlot;
			var isInternal:Boolean = sourceRenderer.owner == mcPlayerGrid;
			
			return !isInternal;
		}
		
		public function applyDrop(sourceObject:IDragTarget):void
		{
			var itemData:ItemDataStub = sourceObject.getDragData() as ItemDataStub;
			
			if (itemData)
			{
				if (_dropMode == MenuInventory.IMS_Shop)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnSellItem", [ itemData.id, itemData.quantity ] ) );
				}
				else if (_dropMode == MenuInventory.IMS_Container)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnTransferItem", [ itemData.id, itemData.quantity, -1 ] ) );
				}
				else if (_dropMode == MenuInventory.IMS_Stash)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnMoveToStash", [ itemData.id ] ) );
				}
			}
		}
		
	}
}
