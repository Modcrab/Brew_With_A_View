package red.game.witcher3.events 
{
	import flash.events.Event;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	
	/**
	 * Slot transfer event
	 * @author Yaroslav Getsevich
	 */
	public class ItemDragEvent extends Event
	{
		public static const START_DRAG:String = "startDrag";
		public static const STOP_DRAG:String = "stopDrag";
        public var targetItem:IDragTarget; 
		public var targetRecepient:IDropTarget; 
		public var success:Boolean;
       
        public function ItemDragEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = true, targetItem:IDragTarget = null, success:Boolean = false) 
        {
            super(type, bubbles, cancelable);
            this.targetItem = targetItem;
			this.success = success;
        }

        override public function clone():Event 
		{
            return new ItemDragEvent(type, bubbles, cancelable, targetItem);
        }
        
        override public function toString():String {
            return formatToString("ItemDragEvent", "type", "bubbles", "cancelable", "tooltipData");
        }
		
	}

}