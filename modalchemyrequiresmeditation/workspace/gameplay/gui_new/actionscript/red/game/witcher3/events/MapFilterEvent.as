package red.game.witcher3.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Yaroslav Getsevich
	 */
	public class MapFilterEvent extends Event 
	{
		public static const ACTIVATE_FILTER:String = "activate_filter";
		public var filterTypeId:uint;
		public var filterEnable:Boolean;
		
		public function MapFilterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, filterTypeId = 0, filterEnable = false) 
		{
			super(type, bubbles, cancelable);
			this.filterTypeId = filterTypeId;
			this.filterEnable = filterEnable;
		}
		
		public override function clone():Event 
		{ 
			return new MapFilterEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MapFilterEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}