package red.game.witcher3.constants
{
	import red.game.witcher3.menus.common.ItemDataStub;
	/**
	 * Data provider for debug data
	 * For testing in the flash/gfx player
	 * @author Yaroslav Getsevich
	 */
	public class DebugDataProvider
	{
		public static function GetGridDebugData():Array
		{
			var testData:Array = [];
			var newItemStub0:ItemDataStub = new ItemDataStub();
			newItemStub0.actionType = InventoryActionType.EQUIP;
			newItemStub0.equipped = 0;
			newItemStub0.gridPosition = 0;
			newItemStub0.gridSize = 2;
			newItemStub0.iconPath = "../../icons/inventory/armor-01.png";
			newItemStub0.id = 1;
			newItemStub0.isNew = true;
			newItemStub0.price = 100;
			newItemStub0.needRepair = true;
			newItemStub0.quantity = 10;
			newItemStub0.slotType = InventorySlotType.Armor;
			testData.push(newItemStub0);
			
			var newItemStub1:ItemDataStub = new ItemDataStub();
			newItemStub1.actionType = InventoryActionType.EQUIP;
			newItemStub1.equipped = 0;
			newItemStub1.gridPosition = 1;
			newItemStub1.gridSize = 2;
			newItemStub1.iconPath = "../../icons/inventory/sword-01-B.png";
			newItemStub1.id = 1;
			newItemStub1.isNew = true;
			newItemStub1.price = 100;
			newItemStub1.needRepair = true;
			newItemStub1.quantity = 10;
			newItemStub1.slotType = InventorySlotType.SilverSword;
			testData.push(newItemStub1);
			
			return testData;
		}
		
		public static function GetPaperdollData():Array
		{
			var testData:Array = [];
			var newItemStub0:ItemDataStub = new ItemDataStub();
			newItemStub0.actionType = InventoryActionType.EQUIP;
			newItemStub0.equipped = 0;
			newItemStub0.gridPosition = 1;
			newItemStub0.gridSize = 2;
			newItemStub0.iconPath = "../../icons/inventory/armor-01.png";
			newItemStub0.id = 1;
			newItemStub0.isNew = true;
			newItemStub0.price = 100;
			newItemStub0.needRepair = true;
			newItemStub0.quantity = 10;
			newItemStub0.slotType = InventorySlotType.Armor;
			testData.push(newItemStub0);
			
			var newItemStub1:ItemDataStub = new ItemDataStub();
			newItemStub1.actionType = InventoryActionType.EQUIP;
			newItemStub1.equipped = 0;
			newItemStub1.gridPosition = 1;
			newItemStub1.gridSize = 2;
			newItemStub1.iconPath = "../../icons/inventory/sword-01-B.png";
			newItemStub1.id = 1;
			newItemStub1.isNew = true;
			newItemStub1.price = 100;
			newItemStub1.needRepair = true;
			newItemStub1.quantity = 10;
			newItemStub1.slotType = InventorySlotType.SilverSword;
			testData.push(newItemStub1);
			
			var newItemStub2:ItemDataStub = new ItemDataStub();
			newItemStub2.actionType = InventoryActionType.EQUIP;
			newItemStub2.equipped = 0;
			newItemStub2.gridPosition = 1;
			newItemStub2.gridSize = 1;
			newItemStub2.iconPath = "../../icons/inventory/ico_apple.png";
			newItemStub2.id = 2;
			newItemStub2.isNew = true;
			newItemStub2.price = 100;
			newItemStub2.needRepair = true;
			newItemStub2.quantity = 10;
			newItemStub2.slotType = InventorySlotType.Potion2;
			testData.push(newItemStub2);
			
			return testData;
		}
		
	}
}