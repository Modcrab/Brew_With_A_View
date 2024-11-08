/***********************************************************************
/** PANEL glossary characters main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.preparation_menu
{
	import red.core.events.GameEvent;
	import red.game.witcher3.modules.CollapsableTabbedListModule;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotsListGrid;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	
	public class PreparationTabbedModule extends CollapsableTabbedListModule
	{
		public static const TabIndex_Bombs 		: int = 0;
		public static const TabIndex_Potion		: int = 1;
		public static const TabIndex_Oils 		: int = 2;
		public static const TabIndex_Mutagens	: int = 3;
		
		public var mcSlotsListGrid:SlotsListGrid;
		
		public var canEquipSteelOil:Boolean = true;
		public var canEquipSilverOil:Boolean = true;
		
		protected override function configUI():void
		{
			super.configUI();
			
			setTabData(new DataProvider( [ { icon:"Bombs", locKey:"[[panel_inventory_paperdoll_slotname_petards]]" },
										   { icon:"Potion", locKey:"[[panel_inventory_paperdoll_slotname_potions]]" },
										   { icon:"Oils", locKey:"[[panel_inventory_paperdoll_slotname_oils]]" },
										   { icon:"Mutagens", locKey:"[[panel_inventory_paperdoll_slotname_mutagen]]" } ] ));
			
			addToListContainer(mcSlotsListGrid);
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'preparation.slot.silversword.locked', [ updateCanEquipSilverOil ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'preparation.slot.steelsword.locked', [ updateCanEquipSteelOil ] ) );
			
			if (mcSlotsListGrid)
			{
				mcSlotsListGrid.focusable = false;
				_inputHandlers.push(mcSlotsListGrid);
				mcSlotsListGrid.visible = false;
				mcSlotsListGrid.handleScrollBar = true;
				mcSlotsListGrid.ignoreGridPosition = true;
			}
		}
		
		override protected function updateSubData(index:int):void
		{
			super.updateSubData(index);
			
			for (var i:int = 0; i < mcSlotsListGrid.getRenderersCount(); ++i)
			{
				var currentSlot:SlotInventoryGrid = mcSlotsListGrid.getRendererAt(i) as SlotInventoryGrid;
				if (currentSlot)
				{
					currentSlot.useContextMgr = false;
				}
			}
		}
		
		override protected function setAllowSelectionHighlight(allowed:Boolean):void
		{
			super.setAllowSelectionHighlight(allowed);
			
			var currentSlotItem:SlotBase;
			var i:int;
			
			if (mcSlotsListGrid)
			{
				mcSlotsListGrid.validateNow();
				for (i = 0; i < mcSlotsListGrid.getRenderersLength(); ++i)
				{
					currentSlotItem = mcSlotsListGrid.getRendererAt(i) as SlotBase;
					
					if (currentSlotItem)
					{
						currentSlotItem.activeSelectionEnabled = allowed;
					}
				}
			}
		}
		
		override public function getDataShowerForTab(index:int):UIComponent
		{
			return mcSlotsListGrid;
		}
		
		protected function updateCanEquipSilverOil(value:Boolean):void
		{
			canEquipSilverOil = !value;
		}
		
		protected function updateCanEquipSteelOil(value:Boolean):void
		{
			canEquipSteelOil = !value;
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
	}
}