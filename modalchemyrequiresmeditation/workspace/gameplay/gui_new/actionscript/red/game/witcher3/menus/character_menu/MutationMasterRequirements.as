package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationMasterRequirements
	 * @author Getsevich Yaroslav
	 */
	public class MutationMasterRequirements extends UIComponent
	{
		private const LIST_PADDING:Number = 10;
		
		public var mcBackground:MovieClip;
		public var mcLockIcon:MovieClip;
		public var tfText:TextField;
		private var _text:String;
		
		public function get text():String { return _text; }
		public function set text(value:String):void
		{
			_text = value;
			if (CoreComponent.isArabicAligmentMode)
			{
				tfText.htmlText = "<p align=\"right\">" + _text + "</p>";
			}
			else
			{
				tfText.htmlText = _text;
				tfText.height = tfText.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			}
			mcBackground.height = tfText.height + LIST_PADDING;
			mcLockIcon.y = mcBackground.y + ( mcBackground.height - mcLockIcon.height ) / 2;
		}
		
	}

}
