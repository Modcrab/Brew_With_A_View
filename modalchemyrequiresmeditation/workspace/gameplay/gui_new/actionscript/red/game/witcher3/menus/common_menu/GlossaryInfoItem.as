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

	public class GlossaryInfoItem extends UIComponent
	{
		public var tfEntry : TextField;
		public var tfTitle : TextField;

		override protected function configUI():void
		{
			super.configUI();
		}

		public function SetEntryTitle( value : String ) : void
		{
			tfEntry.htmlText = value;
		}

		public function SetEntryString( value : String ) : void
		{
			tfTitle.htmlText = value;
		}
	}
}