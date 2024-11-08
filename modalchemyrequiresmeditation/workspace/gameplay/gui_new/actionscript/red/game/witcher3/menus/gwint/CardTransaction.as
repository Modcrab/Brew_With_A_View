package red.game.witcher3.menus.gwint
{
	public class CardTransaction
	{
		public var sourceCardInstanceRef:CardInstance = null;
		public var targetCardInstanceRef:CardInstance = null;
		public var targetSlotID:int = CardManager.CARD_LIST_LOC_INVALID;
		public var targetPlayerID:int = CardManager.PLAYER_INVALID;
		public var powerChangeResult:Number = 0;
		public var strategicValue:Number = 0;
		
		public function toString():String
		{
			return "[Gwint CardTransaction] sourceCard:[[[" + sourceCardInstanceRef + "]]], targetSlotID:" + targetSlotID + ", targetPlayerID:" + targetPlayerID + 
					", StrategicValue:" + strategicValue.toString() + ", PowerChangeResult:" + powerChangeResult.toString() + ", targetCardRef:[[[" + targetCardInstanceRef + "]]]";
		}
	}
}