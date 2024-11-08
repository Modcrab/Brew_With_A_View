package red.game.witcher3.utils.scrollbar 
{
	import flash.events.Event;
	
	public class ScrollBarEvent extends Event 
	{
		public static const VALUE_CHANGED:String = "valueChanged";
		public static const STOP_DRAG:String = "stopDrag";
		public static const START_DRAG:String = "startDrag";
		public var value:Number;
		public function ScrollBarEvent(type:String, value:Number, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.value = value;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new ScrollBarEvent(type,value, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ScrollBarEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}