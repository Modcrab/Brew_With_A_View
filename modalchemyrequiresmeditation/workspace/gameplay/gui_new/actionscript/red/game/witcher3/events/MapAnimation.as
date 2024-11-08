package red.game.witcher3.events 
{
	import flash.events.Event;
	
	/**
	 * Events for tracking map animations
	 * @author Yaroslav Getsevich
	 */
	public class MapAnimation extends Event 
	{
		public static const COMPLETE_HIDE:String = "MapAnimation_COMPLETE_HIDE";
		public static const COMPLETE_SHOW:String = "MapAnimation_COMPLETE_SHOW";
		public static const AREA_CHANGED:String = "MapAnimation_AREA_CHANGED";
		
		public function MapAnimation(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{
			return new MapAnimation(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MapAnimation", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}