package red.game.witcher3.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Yaroslav Getsevich
	 */
	public class ContextEvent extends Event 
	{
		public static var ACTIVATE:String  = "contextevent_activate";
		public var contextData:Object;
		
		public function ContextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new ContextEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ContextEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}