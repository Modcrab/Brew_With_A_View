/***********************************************************************
/** Main Mouse Options Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainMouseOptionsSubMenu extends MainSubMenu
	{
		public function MainMouseOptionsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.mouse.entries";
		}

		override protected function get menuName():String
		{
			return "MainMouseOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
