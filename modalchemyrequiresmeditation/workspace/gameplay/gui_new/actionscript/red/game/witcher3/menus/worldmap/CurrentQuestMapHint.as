package red.game.witcher3.menus.worldmap 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class CurrentQuestMapHint extends UIComponent
	{
		protected const COLLAPSED_SIZE:Number = 52;
		protected const EXTENDED_SIZE:Number = 74;
		
		public var tfTitle:TextField;
		public var tfQuest:TextField;
		public var mcBackground:Sprite;
		
		public function CurrentQuestMapHint() 
		{
			tfQuest.visible = false;
		}
		
		protected var _data:Object
		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			_data = value;
			tfQuest.htmlText = value.questName;
			tfQuest.visible = true;
		}
		
	}
}
