package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;

	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class TutorialPopupTitle extends UIComponent
	{
		protected static const TITLE_TEXTFIELD_PADDING:Number = 10;

		public var txtTitle:TextField;
		public var background:MovieClip;

		private var _minWidth:Number;

		public function TutorialPopupTitle()
		{
			_minWidth = this.width;
		}

		protected var _text:String;
		public function get text():String { return _text }
		public function set text(value:String):void
		{
			if (value)
			{

				_text = value;
				txtTitle.htmlText = _text;
				txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);
				txtTitle.width =  txtTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;

				var titleWidth:Number = Math.max(TITLE_TEXTFIELD_PADDING + txtTitle.width, _minWidth);
				background.width = titleWidth;
				txtTitle.x = (background.width - txtTitle.width) / 2;

				visible = true;
			}
			else
			{
				visible = false;
			}
		}
	}

}
