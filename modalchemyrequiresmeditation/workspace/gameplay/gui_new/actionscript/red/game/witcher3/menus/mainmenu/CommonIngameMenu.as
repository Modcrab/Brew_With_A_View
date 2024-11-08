/***********************************************************************
/** Common Ingame Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;

	public class CommonIngameMenu extends CommonMainMenu
	{
		public function CommonIngameMenu()
		{
			super();
			SHOW_ANIM_OFFSET = 0;
			SHOW_ANIM_DURATION = 2;
			//_enableMouse = true;
		}
		
		override protected function get menuName():String
		{
			return "CommonIngameMenu";
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			super.handleInput(event); // #B for what we call empty super ?
			var details:InputDetails = event.details;
			
			// Handle only down state to avoid jumping
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			
			if (!event.handled)
			{
				if (keyUp && !_restrictDirectClosing)
				{
					switch (details.navEquivalent)
					{
						case NavigationCode.GAMEPAD_START:
						case NavigationCode.GAMEPAD_BACK:
								closeMenu();
								return;
								break;
					}
				}
			}
		}
	}
}
