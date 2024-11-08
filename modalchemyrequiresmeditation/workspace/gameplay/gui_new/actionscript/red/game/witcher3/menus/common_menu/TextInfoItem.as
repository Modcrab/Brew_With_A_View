/***********************************************************************
/** MenuHub - Items History for inventory
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import flash.text.TextField;
	import red.game.witcher3.utils.CommonUtils;

	public class TextInfoItem extends UIComponent
	{
		public var tfTop : TextField;
		public var tfBottom : TextField;
		private var _gap : Number;

		override protected function configUI():void
		{
			//visible = false;
			//_gap = tfBottom.y - tfTop.y + tfTop.textHeight;
			_gap = 10;
			super.configUI();
		}

		public function SetEntryTopText( value : String ) : void
		{
			tfTop.htmlText = value;
			tfTop.htmlText = CommonUtils.toUpperCaseSafe(tfTop.htmlText);
			tfBottom.y = tfTop.y + tfTop.textHeight + _gap;
		}

		public function SetEntryBottomText( value : String ) : void
		{
			tfBottom.htmlText = value;
			tfBottom.htmlText = CommonUtils.toUpperCaseSafe(tfBottom.htmlText);
		}
	}
}