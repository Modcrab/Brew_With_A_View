/***********************************************************************
/** Main Visuals Options Menu class
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

	public class MainVisualsOptionsMenu extends MainMenu
	{
		public function MainVisualsOptionsMenu()
		{
			super();
			dataBindingKey = "mainmenu.visualsoptions.entries";
		}

		override protected function get menuName():String
		{
			return "MainVisualsOptionsMenu";
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
	}
}
