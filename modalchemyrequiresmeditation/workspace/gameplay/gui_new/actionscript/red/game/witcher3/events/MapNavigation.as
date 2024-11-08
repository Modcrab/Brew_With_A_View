package red.game.witcher3.events 
{
	import flash.events.Event;
	
	/**
	 * Navigation request event
	 * @author Yaroslav Getsevich
	 */
	public class MapNavigation extends Event 
	{
		public static const REQUEST:String = "MapNavigation_REQUEST";
		public var targetMappin:uint;
		public var targetArea:uint;
		public var targetAreaName:String;
		
		public function MapNavigation(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new MapNavigation(type, bubbles, cancelable);
		} 
		
		public override function toString():String
		{
			return formatToString("MapNavigation", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}