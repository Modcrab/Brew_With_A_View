package red.game.witcher3.data
{
	public class StaticMapPinData
	{
		public var id:uint;
		public var type:String;
		public var filteredType:String;
		public var label:String;
		public var description:String;
		public var posX:Number;
		public var posY:Number;
		public var radius:Number;
		
		 // for quest mappins
		public var tracked:Boolean;
		public var highlighted:Boolean;
		
		public var areaId:uint;
		public var journalAreaId:uint;
		
		public var rotation:Number;
		
		public var isFastTravel:Boolean;
		public var isQuest:Boolean;
		public var isPlayer:Boolean;
		public var isUserPin:Boolean;
		
		public var distance:Number;
		
		public var hidden:Boolean;
		
		public function toString():String
		{
			return "";
			/*
			return "[W3 StaticMapPinData: id " + id + " = " + id +
				", type = " + type + ", posX = " + posX + ", posY = " + posY + ", posZ = " + posZ + ", enabled = " + enabled + ", current = " + current + "]";
			*/
		}
	}
}
