package red.game.witcher3.interfaces 
{
	import flash.display.DisplayObject;
	
	/**
	 * Interface for inventory paperdoll
	 * @author Yaroslav Getsevich
	 */
	public interface IPaperdollSlot extends IInventorySlot
	{
		function get slotType():int
		function get slotTag():String
		function set slotTag( value:String ):void
		
		function get navigationUp():int
		function set navigationUp( value:int ):void
		function get navigationDown():int
		function set navigationDown( value:int ):void
		function get navigationRight():int
		function set navigationRight( value:int ):void
		function get navigationLeft():int
		function set navigationLeft( value:int ):void
		function get equipID():int
		function set equipID( value:int ):void
		
		function getHitArea():DisplayObject
	}
	
}
