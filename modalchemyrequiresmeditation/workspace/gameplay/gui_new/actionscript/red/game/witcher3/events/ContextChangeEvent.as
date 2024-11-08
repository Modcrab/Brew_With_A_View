package red.game.witcher3.events
{
	import flash.events.Event;
	import red.game.witcher3.interfaces.IInteractionObject;
	
	/**
	 * 
	 * DEPRECATED; KILL ME;
	 * 
	 * Event for changing tooltips, popups, default action targets, etc
	 * @author Getsevich Yaroslav
	 */
	public class ContextChangeEvent extends Event 
	{
		public static const CONTEXT_CHANGED:String = "context_changed";
		public var contextHolder:IInteractionObject;
		
		public function ContextChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.contextHolder = contextHolder;
		} 
		
		public override function clone():Event 
		{ 
			return new ContextChangeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ContextChangeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}