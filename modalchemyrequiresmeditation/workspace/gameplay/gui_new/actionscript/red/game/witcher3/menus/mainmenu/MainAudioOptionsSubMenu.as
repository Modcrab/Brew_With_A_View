/***********************************************************************
/** Main Audio Options Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;

	public class MainAudioOptionsSubMenu extends MainSubMenu
	{
		public function MainAudioOptionsSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.audio.entries";
		}

		override protected function get menuName():String
		{
			return "MainAudioOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
