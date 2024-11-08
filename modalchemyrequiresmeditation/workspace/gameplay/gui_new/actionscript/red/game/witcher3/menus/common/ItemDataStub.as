package red.game.witcher3.menus.common
{
	public dynamic class ItemDataStub
	{
		public var id : uint;
		public var groupId : int;
		
		public var iconPath : String;
		public var quantity : int;
		public var gridPosition : int;
		public var gridSize : int = 1;
		public var isNew : Boolean;
		public var disableAction : Boolean;
		public var slotType : int; // InventorySlotType
		public var actionType : int; // InventoryActionType
		public var equipped : int; // 0 or 8-11 for quickslots, or user defined meaning
		public var price : int;
		public var quality : int;
		public var needRepair : Boolean = false;
		public var durability : Number = 1;
		public var isReaded : Boolean = false; // #B used when item is a book (isReaded is not the same as isNew) // #Y TODO: rename "READED"
		public var isEquipped : Boolean;
		public var weight : Number;
		
		public var socketsCount:int = 0;
		public var socketsUsedCount:int = 0;
		public var socketsMaxCount:int = 0;
		public var invisible:Boolean;
		public var category:String;
		
		// for drag&drop
		public var isSilverOil:Boolean;
		public var isSteelOil:Boolean;
		public var isArmorUpgrade:Boolean;
		public var isWeaponUpgrade:Boolean;
		public var isArmorRepairKit:Boolean;
		public var isWeaponRepairKit:Boolean;
		public var isItemDye:Boolean;
		public var canDrop:Boolean;
		public var enchanted:Boolean;
		public var enchantmentId:uint;
		// NGE
		public var canBeDyed:Boolean;
		
		public var sortGroup:int = -1;
		
		// for new section grid
		public var sectionId:int = -1;
		
		public var cantEquip:Boolean;
		
		// optional
		public var itemName:String;
		public var description:String;
		public var isNotEnoughSockets:int;
		
		// for default bolts
		public var cantUnequip:Boolean;
		
		public var charges:String;
		public var showExtendedTooltip:Boolean;
		public var tabIndex:int = -1;
		
		// for pinned recipes
		public var highlighted:Boolean = false;
		
		// if dye used
		public var itemColor:String = "";
		public var isDyePreview:Boolean = false;
		
		public var userData:*; // not set the by the engine. Use for whatever internal purposes.
		
		public function toString():String
		{
			return "[W3 ItemDataStub: id<" +id +"> iconPath: " +iconPath + " cantEquip: " + cantEquip + "; quantity " + quantity+" gridPosition " + gridPosition +" gridSize " + gridSize +" slotType " + slotType +" actionType " +actionType +" equipped " + equipped +" price " + price +" quality " + quality +" needRepair " + needRepair +" isReaded " + isReaded + "]";
		}
	}
}
