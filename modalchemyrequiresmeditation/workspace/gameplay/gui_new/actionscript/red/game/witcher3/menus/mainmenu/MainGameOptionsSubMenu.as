/***********************************************************************
/** Main Game Options Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainGameOptionsSubMenu extends MainSubMenu
	{
		public function MainGameOptionsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.game.entries";
		}

		override protected function get menuName():String
		{
			return "MainGameOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
