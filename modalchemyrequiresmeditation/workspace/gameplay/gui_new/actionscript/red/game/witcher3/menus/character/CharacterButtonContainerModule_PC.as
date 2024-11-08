/***********************************************************************
/** PANEL Character button container module : PC version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	public class CharacterButtonContainerModule_PC extends CharacterButtonContainerModule
	{
		public function CharacterButtonContainerModule_PC()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			mouseEnabled = false;
		}
		
/*		override protected function setupButtons() : void
		{
			super.setupButtons();
		}*/
		
		override public function toString():String
		{
			return "[W3 ButtonContainerModule_PC: ]";
		}
	}
}