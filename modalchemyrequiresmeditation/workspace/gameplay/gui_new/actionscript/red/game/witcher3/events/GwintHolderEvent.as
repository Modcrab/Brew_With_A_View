package red.game.witcher3.events
{
	import flash.events.Event;
	import red.game.witcher3.menus.gwint.GwintCardHolder;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class GwintHolderEvent extends Event 
	{
		public static const HOLDER_SELECTED:String = "holder_selected"; // select
		public static const HOLDER_CHOSEN:String = "holder_chosen"; // select + press 'A'
		
		public var cardHolder:GwintCardHolder;
		
		public function GwintHolderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, cardHolder:GwintCardHolder = null) 
		{ 
			super(type, bubbles, cancelable);
			this.cardHolder = cardHolder;
		} 
		
		public override function clone():Event 
		{ 
			return new GwintHolderEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("GwintHolderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
