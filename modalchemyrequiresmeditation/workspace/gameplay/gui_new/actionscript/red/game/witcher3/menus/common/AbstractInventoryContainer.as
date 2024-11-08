/***********************************************************************
/** Abstract Inventory container, common for player grid, paperdoll & ...
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/


package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import scaleform.clik.controls.ListItemRenderer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import scaleform.gfx.MouseEventEx;
	
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.ButtonEvent;
	
	import red.game.witcher3.events.GridEvent;
	import red.core.events.GameEvent;

	import scaleform.clik.constants.NavigationCode;
	
	import scaleform.clik.constants.InvalidationType;
	import red.game.witcher3.menus.inventory.InventorySlot;
	import red.game.witcher3.constants.InventoryActionType;

	
	[Event(name = "change", type = "flash.events.Event")]
    [Event(name = "itemClick", type = "scaleform.clik.events.ListEvent")]
    [Event(name = "itemPress", type = "scaleform.clik.events.ListEvent")]
    [Event(name = "itemDoubleClick", type = "scaleform.clik.events.ListEvent")]
	[Event(name = "gridItemChange", type="witcher3.events.GridEvent")]
	public class AbstractInventoryContainer extends AbstractGridContainer
	{
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
	
		public function AbstractInventoryContainer()
		{
			super();
		}
				
		override protected function configUI():void
		{
			super.configUI();
		}
		
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
		
		override protected function handleListItemPress( event : ListEvent ) : Boolean // move to Abstract
		{
			var inventorySlot : InventorySlot;
			inventorySlot = event.itemRenderer as InventorySlot;
			if ( inventorySlot.data )
			{
				switch ( inventorySlot.data.actionType )
				{
					case InventoryActionType.EQUIP:
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipItem', [inventorySlot.data.id, inventorySlot.data.slotType ] ));
							// #B here qp
							var displayEvent:GridEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, inventorySlot.index, -1, -1, inventorySlot, inventorySlot.data );
							trace("INVENTORY handleListItemPress  DISPLAY_TOOLTIP abstract inventory container");
							dispatchEvent(displayEvent);
						}
						break;
					case InventoryActionType.UPGRADE_WEAPON:
						//FIXME: Need to select which one
						//trace("Need to select a weapon to upgrade");
						//GameInterface.callEvent( 'OnIsEnhancementSlotsFull', _activePaperdollItemDataStub.id ,_activeGridItemDataStub.id);
						break;
					case InventoryActionType.UPGRADE_WEAPON_STEEL: // #B kill
					case InventoryActionType.UPGRADE_WEAPON_SILVER: // kill
					case InventoryActionType.UPGRADE_ARMOR: // kill
						break;
					case InventoryActionType.CONSUME:
						//GameInterface.callEvent( 'OnConsumeItem', _activeGridItemDataStub.id );
						break;
					case InventoryActionType.READ:
						//handleBookRead();
						break;
					case InventoryActionType.TRANSFER:
						//
						break;
					case InventoryActionType.SELL:
						//
						break;
					case InventoryActionType.BUY:
						//
						break;
					default:
						break;
				}
			}
			return true;
		}
		
		override protected function checkShowTooltip( renderer : ListItemRenderer) : Boolean
		{
			var inventorySlot : InventorySlot;
			inventorySlot = renderer as InventorySlot;
			return inventorySlot.IsEmpty();
		}
	}
}