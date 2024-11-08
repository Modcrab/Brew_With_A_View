package red.game.witcher3.events 
{
	import flash.events.Event;
	import scaleform.clik.events.InputEvent;
	
	/**
	 * see ModuleInputfeedback.as
	 * @author Getsevich Yaroslav
	 */
	public class InputFeedbackEvent extends Event 
	{
		public static const USER_ACTION:String = "user_action";
		
		public var inputEventRef:InputEvent;
		public var actionId:int;
		public var messageId:int;
		public var isMouseEvent:Boolean;
		
		public function InputFeedbackEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new InputFeedbackEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("InputFeedbackEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
