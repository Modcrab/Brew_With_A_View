package red.game.witcher3.menus.inventory_menu
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Point;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.DebugDataProvider;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.interfaces.IAbstractItemContainerModule;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotsListPaperdoll;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	
	/**
	 * Base class for all paperdolls (player / horse)
	 * @author Getsevich Yaroslav
	 */
	public class ModulePaperdollBase extends CoreMenuModule implements IAbstractItemContainerModule
	{
		public var mcPaperdoll : SlotsListPaperdoll;
		
		public function ModulePaperdollBase()
		{
			dataBindingKey = "inventory.paperdoll";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			mcPaperdoll.focusable = false;
			mcPaperdoll.activeSelectionVisible = false;
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			mcPaperdoll.addEventListener(ListEvent.INDEX_CHANGE, handleSlotChanged, false, 0 , true);
			//mcPaperdoll.
			
			if (!Extensions.isScaleform)
			{
				initDebugMode();
			}
		}
		
		public function /*Witcher Script*/ paperdollRemoveItem( itemId : uint ):void
		{
			if (enabled)
			{
				mcPaperdoll.removeItem(itemId);
				invalidate(INVALIDATE_CONTEXT);
			}
		}
		
		public function /*Witcher Script*/ handlePaperdollUpdateItem( itemData : Object ):void
		{
			if (enabled)
			{
				mcPaperdoll.updateItemData(itemData);
				invalidate(INVALIDATE_CONTEXT);
			}
		}
		
		public function /*Witcher Script*/ handlePaperdollUpdateItems( itemsList : Array ):void
		{
			if (enabled && itemsList)
			{
				var len:int = itemsList.length;
				
				for (var i:int = 0; i <  len; i++ )
				{
					mcPaperdoll.updateItemData(itemsList[i]);
				}
				
				invalidate(INVALIDATE_CONTEXT);
			}
		}
		
		
		
		protected function /*Witcher Script*/ handlePaperdollDataSet( gameData:Object, index:int ):void
		{
			if (enabled)
			{
				mcPaperdoll.data = gameData as Array;
			}
		}
		
		/*
		 * 							- Context -
		 */
		override protected function handleModuleSelected():void
		{
			super.handleModuleSelected();
			if (mcPaperdoll.selectedIndex < 0)
			{
				mcPaperdoll.selectedIndex = 0;
			}
			invalidate(INVALIDATE_CONTEXT);
		}

		protected function handleSlotChanged( event : ListEvent ):void
		{
			if (enabled)
			{
				updateActiveContext(event.itemRenderer as SlotPaperdoll);
			}
			dispatchEvent(event);
		}

		public function forceSelectPaperdollSlot( slotType : int ):void
		{
			mcPaperdoll.selectedIndex = mcPaperdoll.getIndexForSlotType( slotType );
		}

		// #Y TODO: Move to base class ???
		protected function updateActiveContext(currentSlot:SlotPaperdoll):void
		{
			if (focused > 0)
			{
				var targetId:uint = 0;
				var targetSlot:int = -1;
				var targetPoint:Point = new Point();
				
				if (currentSlot)
				{
					var slotData:ItemDataStub = currentSlot.data as ItemDataStub;
					if (slotData)
					{
						targetId = slotData.id;
					}
					var targetX:Number = currentSlot.x + currentSlot.getSlotRect().width;
					var targetY:Number = currentSlot.y + currentSlot.getSlotRect().height;

					targetPoint = currentSlot.parent.localToGlobal(new Point(targetX, targetY));
					targetSlot = currentSlot.slotType;
				}
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectPaperdollItem", [targetId, targetSlot, targetPoint.x, targetPoint.y]));
			}
		}
		
		
		/*
		 * 							- Core -
		 */
		
		override protected function draw():void
		{
			super.draw();
			if (isInvalid(INVALIDATE_CONTEXT))
			{
				if (mcPaperdoll.selectedIndex > -1)
				{
					var curIdx:int = mcPaperdoll.selectedIndex;
					var curSlot:SlotPaperdoll = mcPaperdoll.getRendererAt(curIdx) as SlotPaperdoll;
					if (curSlot)
					{
						updateActiveContext(curSlot);
					}
				}
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			if (!focused)
			{
				return;
			}
			
			if (!event.handled)
			{
				mcPaperdoll.handleInputPreset(event);
			}
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			if (value > 0)
			{
				unbindInventory();
				var curSlot:SlotPaperdoll = mcPaperdoll.getRendererAt(mcPaperdoll.selectedIndex) as SlotPaperdoll;
				if (curSlot)
				{
					updateActiveContext(curSlot);
				}
			}
			
			mcPaperdoll.activeSelectionVisible = value != 0;
			
			if (mcPaperdoll.getSelectedRenderer() != null)
			{
				if (focused != 0)
				{
					(mcPaperdoll.getSelectedRenderer() as SlotBase).showTooltip();
				}
				else
				{
					(mcPaperdoll.getSelectedRenderer() as SlotBase).hideTooltip();
				}
			}
		}
		
		protected function unbindInventory():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetCurrentPlayerGrid', ["inventory.grid.player"] ) );
		}
		
		public function get CurrentItemDataStub() : ItemDataStub
		{
			return null;
		}
		
		private function initDebugMode():void
		{
			handlePaperdollDataSet(DebugDataProvider.GetPaperdollData(), -1);
		}
		
		override public function toString() : String
		{
			return "[W3 ModulePaperdollBase]";
		}
		
		public function startSelectModeWithValidSlots(slotList:Array):void
		{
			var i:int;
			var x:int;
			var curSlot:SlotPaperdoll;
			var validSlot:Boolean;
			
			for (i = 0; i < mcPaperdoll.getRenderersLength(); ++i)
			{
				curSlot = mcPaperdoll.getRendererAt(i) as SlotPaperdoll;
				validSlot = false;
				
				if (curSlot)
				{
					for (x = 0; x < slotList.length; ++x)
					{
						if (curSlot.CheckSlotsType(slotList[x]))
						{
							validSlot = true;
							break;
						}
					}
						
					if (!validSlot)
					{
						curSlot.selectable = false;
					}
					
					curSlot.selectionMode = true;
				}
			}
			
			//mcPaperdoll.ignoreSelectable = false;
			
			mcPaperdoll.ReselectIndexIfInvalid(mcPaperdoll.selectedIndex);
		}
		
		public function endSelectionMode():void
		{
			var i:int;
			var curSlot:SlotPaperdoll;
			
			for (i = 0; i < mcPaperdoll.getRenderersLength(); ++i)
			{
				curSlot = mcPaperdoll.getRendererAt(i) as SlotPaperdoll;
				
				if (curSlot)
				{
					curSlot.selectable = true;
					curSlot.selectionMode = false;
				}
			}
		}
		
		private function isHorseSlot(targetSlot:SlotPaperdoll):Boolean
		{
		 	return targetSlot.CheckSlotsType(InventorySlotType.HorseBag) || targetSlot.CheckSlotsType(InventorySlotType.HorseBlinders) ||
				   targetSlot.CheckSlotsType(InventorySlotType.HorseSaddle) || targetSlot.CheckSlotsType(InventorySlotType.HorseTrophy);
		}
		
	}
}
