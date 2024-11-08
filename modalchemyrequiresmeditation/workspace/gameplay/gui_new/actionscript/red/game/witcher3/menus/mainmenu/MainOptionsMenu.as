/***********************************************************************
/** Main Options Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	
	import red.core.events.GameEvent;

	public class MainOptionsMenu extends MainMenu
	{
		public function MainOptionsMenu()
		{
			super();
			dataBindingKey = "mainmenu.options.entries";
		}

		override protected function get menuName():String
		{
			return "MainOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
