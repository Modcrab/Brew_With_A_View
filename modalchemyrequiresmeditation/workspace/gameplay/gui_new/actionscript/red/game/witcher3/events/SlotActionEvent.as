package red.game.witcher3.events 
{
	import flash.events.Event;
	import red.game.witcher3.interfaces.IBaseSlot;
	
	/**
	 * @author Yaroslav Getsevich
	 */
	public class SlotActionEvent extends Event 
	{
		public static const EVENT_ACTIVATE:String = "event_activate";
		public static const EVENT_SECONDARY_ACTION:String = "event_secondary_action";
		public static const EVENT_SELECT:String = "event_select";
		
		public var actionType:int; // Ref to  red.game.witcher3.constants.InventoryActionType
		public var targetSlot:IBaseSlot;
		public var data:Object;
		public var isMouseEvent:Boolean = false;
		
		public function SlotActionEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, actionType:int = 0, targetSlot:IBaseSlot = null)
		{
			super(type, bubbles, cancelable);
			this.actionType = actionType;
			this.targetSlot = targetSlot;
		}
		
		public override function clone():Event 
		{ 
			return new SlotActionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SlotActionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
