/***********************************************************************
/** Right click menu, curently used in inventory only : PC version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
/*	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;*/
	
	public class RightClickMenu_PC extends RightClickMenu
	{
		public function RightClickMenu_PC()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
		}

		override public function toString():String
		{
			return "[W3 RightClickMenu_PC: ]";
		}
		
		override public function SetPosition( inX : int, inY : int ) : void
		{
			x = inX;
			y = inY;
		}
	}
}