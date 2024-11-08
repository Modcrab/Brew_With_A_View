/***********************************************************************
/** Main Hud Options Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainHudOptionsSubMenu extends MainSubMenu
	{
		public function MainHudOptionsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.hud.entries";
		}

		override protected function get menuName():String
		{
			return "MainHudOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
