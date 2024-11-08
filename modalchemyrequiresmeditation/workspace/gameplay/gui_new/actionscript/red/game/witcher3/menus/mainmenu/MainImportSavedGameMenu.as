/***********************************************************************
/** Main Import Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.ListEvent;
	
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;

	public class MainImportSavedGameMenu extends MainSubMenu
	{
		public function MainImportSavedGameMenu()
		{
			super();
			dataBindingKey = "mainmenu.import.entries";
		}

		override protected function get menuName():String
		{
			return "MainImportSavedGameMenu";
		}

		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}

		private function onItemClicked( event : ListEvent ):void
		{
			var renderer : BaseListItem =  mcMenuList.getRendererAt( event.index, mcMenuList.scrollPosition ) as BaseListItem;
			if(renderer)
			{
				trace("HUD onItemClicked renderer.data.tag "+renderer.data.tag);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSavedGameImport', [ renderer.data.tag ] ) );
			}
			else
			{
				trace("MainMenu renderer error "+event.target);
			}
		}
	}

}
