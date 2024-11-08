/***********************************************************************
/** PANEL Character button container module : CONSOLE version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	
	public class CharacterButtonContainerModule_CONSOLE extends CharacterButtonContainerModule
	{
		public var btnExit : W3GamepadButton;
		
		public function CharacterButtonContainerModule_CONSOLE()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			//stage.addEventListener( GameEvent.PASSINPUT, handleGetInput, false, 0, true);
		}
		
		override protected function setupButtons() : void
		{
			super.setupButtons();
			btnExit.label = "[[panel_button_common_exit]]";
			btnExit.addEventListener( ButtonEvent.CLICK, handleButtonExit, false, 0, true );
			btnExit.navigationCode = NavigationCode.GAMEPAD_B;
			_inputHandlers.push( btnExit );
		}
		
		override public function toString():String
		{
			return "[W3 CharacterButtonContainerModule_CONSOLE: ]";
		}
		
		private function handleButtonExit( event : ButtonEvent ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}
	}
}