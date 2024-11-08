package red.game.witcher3.menus.inventory_menu
{
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotsListPaperdoll;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.events.ListEvent;
	
	/**
	 * Horse paperdoll module
	 * @author Getsevich Yaroslav
	 */
	public class ModuleHorsePaperdoll extends ModulePaperdollBase
	{
		public var mcHorseSlot1:SlotPaperdoll;
		public var mcHorseSlot2:SlotPaperdoll;
		public var mcHorseSlot3:SlotPaperdoll;
		public var mcHorseSlot4:SlotPaperdoll;
		
		public function ModuleHorsePaperdoll()
		{
			dataBindingKey = "inventory.grid.paperdoll.horse";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.grid.paperdoll.horse", [handlePaperdollDataSet]));
		}	
		
		protected override function /*Witcher Script*/ handlePaperdollDataSet( gameData:Object, index:int ):void
		{		
			mcPaperdoll.data = gameData as Array;
			mcPaperdoll.validateNow();
		}
		
		override public function toString() : String
		{
			return "[W3 ModuleHorsePaperdoll]";
		}
	}
}
