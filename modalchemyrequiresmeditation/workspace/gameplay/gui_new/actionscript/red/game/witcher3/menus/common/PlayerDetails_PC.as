/***********************************************************************
/** Inventory Player details module: CONSOLE VERSION
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.core.events.GameEvent;
	
	public class PlayerDetails_PC extends PlayerDetails
	{
		public var mcExitButton : W3GamepadButton;
		
		public function PlayerDetails_PC()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			mouseChildren = true;
			mcExitButton.addEventListener( ButtonEvent.CLICK, handleButtonExit, false, 0, true );
			mcExitButton.navigationCode = NavigationCode.GAMEPAD_B;
		}
				
		private function handleButtonExit( event : ButtonEvent ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}
	}
}
