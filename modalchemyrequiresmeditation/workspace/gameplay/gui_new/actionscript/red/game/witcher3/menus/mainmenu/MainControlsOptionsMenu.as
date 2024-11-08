/***********************************************************************
/** Main Controls Options Menu class
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

	public class MainControlsOptionsMenu extends MainMenu
	{
		public function MainControlsOptionsMenu()
		{
			super();
			dataBindingKey = "mainmenu.controlsoptions.entries";
		}

		override protected function get menuName():String
		{
			return "MainControlsOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			trace("MainMenu closeMenu controls");
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
