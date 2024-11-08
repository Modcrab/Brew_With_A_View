package red.game.witcher3.events
{
	import flash.events.Event;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	
	/**
	 * Event for dropdown list
	 * @author Getsevich Yaroslav
	 */
	public class CategoryChangeEvent extends Event 
	{
		public static const CATEGORY_CHANGED:String = "category_changed";
		public var categoryIdx:int;
		public var categoryItemRenderer:W3DropdownMenuListItem;
		
		public function CategoryChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, categoryIdx:int = -1) 
		{
			this.categoryIdx = categoryIdx;
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new CategoryChangeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CategoryChangeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
