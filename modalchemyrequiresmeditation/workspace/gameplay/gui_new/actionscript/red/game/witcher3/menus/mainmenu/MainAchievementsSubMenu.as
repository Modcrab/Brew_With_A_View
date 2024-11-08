/***********************************************************************
/** Main Achivments Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainAchievementsSubMenu extends MainSubMenu
	{
		public function MainAchievementsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.achievements.entries";
		}

		override protected function get menuName():String
		{
			return "MainAchievementsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
