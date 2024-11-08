package red.game.witcher3.menus.character_menu 
{
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Skills grid sub group title
	 * ESP_Sword, ESP_Signs, ESP_Alchemy
	 * @author Getsevich Yaroslav
	 */
	public class SkillsGroupTitle extends UIComponent
	{
		public var textField:TextField;
		protected var _skillGroup:String;
		protected var _title:String;
		protected var _colorMap:Object = { ESP_Sword:0xDDFFFF, ESP_Signs:0xFFD3C1, ESP_Alchemy: 0xBDFFFF };
		
		public function get skillGroup():String { return _skillGroup };
		public function set skillGroup(value:String):void
		{
			if (value)
			{
				_skillGroup = value;
				gotoAndStop(_skillGroup);
				textField.textColor = _colorMap[_skillGroup];
			}
		}
		
		public function get title():String { return _title };
		public function set title(value:String):void
		{
			_title = value;
			textField.htmlText = _title;
		}
		
	}

}