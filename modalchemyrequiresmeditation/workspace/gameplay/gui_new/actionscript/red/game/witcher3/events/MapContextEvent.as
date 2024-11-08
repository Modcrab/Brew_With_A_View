package red.game.witcher3.events
{
	import flash.events.Event;
	import red.game.witcher3.data.StaticMapPinData;
	
	/**
	 * Map area change; mappoint selection; etc
	 * @author Getsevich Yaroslav
	 */
	public class MapContextEvent extends Event 
	{
		public static const CONTEXT_CHANGE:String = "contextChange";
		public var tooltipData:Object;
		public var active:Boolean;
		public var mapppinData:StaticMapPinData;
		
		public function MapContextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new MapContextEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MapContextEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
