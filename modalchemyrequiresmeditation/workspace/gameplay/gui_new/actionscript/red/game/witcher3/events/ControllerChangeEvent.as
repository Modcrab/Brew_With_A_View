package red.game.witcher3.events 
{
	import flash.events.Event;
	
	/**
	 * Controller change event
	 * @author Yaroslav Getsevich
	 */
	public class ControllerChangeEvent extends Event
	{
		public static const CONTROLLER_CHANGE:String = "controller_change";
		public var isGamepad:Boolean;
		public var platformType:uint;
		
		public function ControllerChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = true, isGamepad:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			this.isGamepad = isGamepad;
		}
		
		override public function clone():Event 
		{
            return new ControllerChangeEvent(type, bubbles, cancelable, isGamepad);
        }
	}
}
