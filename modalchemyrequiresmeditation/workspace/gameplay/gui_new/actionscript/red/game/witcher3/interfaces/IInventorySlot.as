package red.game.witcher3.interfaces 
{
	/**
	 * Interface for inventory grid item
	 * @author Yaroslav Getsevich
	 */
	public interface IInventorySlot extends IBaseSlot
	{
		function get uplink():IInventorySlot
		function set uplink(value:IInventorySlot):void
		
		function get highlight():Boolean
        function set highlight(value:Boolean):void
	}
}