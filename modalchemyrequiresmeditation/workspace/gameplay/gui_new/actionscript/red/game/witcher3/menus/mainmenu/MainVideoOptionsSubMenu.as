/***********************************************************************
/** Main Video Options Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainVideoOptionsSubMenu extends MainSubMenu
	{
		public function MainVideoOptionsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.video.entries";
		}

		override protected function get menuName():String
		{
			return "MainVideoOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
