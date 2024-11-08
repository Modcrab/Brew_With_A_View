package red.game.witcher3.utils.mydragmanager 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class MyDragManagerEvent extends Event 
	{
		
		static public const ITEM_DROPPED_OUTSIDE:String = "itemDroppedOutside";
		static public const ITEM_DROPPED_IN_SLOT:String = "itemDroppedInSlot";
		static public const ITEM_START_DRAG:String = "itemStartDrag";

		public var item:DraggedItemVO;
		
		public function MyDragManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new MyDragManagerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MyDragManagerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}