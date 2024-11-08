/***********************************************************************
/** MenuHub - TExtInfo Item For mappin info
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.common_menu
{
	import flash.display.MovieClip;

	public class TextInfoItemMappin extends TextInfoItem
	{
		public var mcMappinIco : MovieClip;
		var iconPath : String;

		override protected function configUI():void
		{
			super.configUI();
		}

		public function SetEntryType( value : String ) : void
		{
			iconPath = value;

			if ( mcMappinIco )
			{
				mcMappinIco.gotoAndStop( value );
			}
		}
	}
}