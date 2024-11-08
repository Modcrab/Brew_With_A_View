/***********************************************************************
/** Main Mouse Options Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainPadOptionsSubMenu extends MainSubMenu
	{
		public function MainPadOptionsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.pad.entries";
		}

		override protected function get menuName():String
		{
			return "MainPadOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
