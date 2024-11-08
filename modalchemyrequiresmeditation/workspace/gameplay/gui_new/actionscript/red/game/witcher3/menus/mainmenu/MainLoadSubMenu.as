/***********************************************************************
/** Main Achivments Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.events.ListEvent;

	public class MainLoadSubMenu extends MainSubMenu
	{
		public function MainLoadSubMenu()
		{
			super();
			dataBindingKey = "mainmenu.load.entries";
		}

		override protected function get menuName():String
		{
			return "MainLoadMenu";
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
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSaveLoad', [ renderer.data.tag ] ) );
			}
			else
			{
				trace("MainMenu renderer error "+event.target);
			}
		}
	}
}
