/***********************************************************************
/** Common Main Menu class
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

	import red.core.CoreMenu;
	import red.core.events.GameEvent;

	public class CommonMainMenuEP1 extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public function CommonMainMenuEP1()
		{
			super();
			SHOW_ANIM_OFFSET = 0;
			SHOW_ANIM_DURATION = 2;
			//_enableMouse = true;
		}
		
		override protected function get menuName():String
		{
			return "CommonMainMenuEP1";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			// Overriding to disable all default behaviors
		}
	}
}
