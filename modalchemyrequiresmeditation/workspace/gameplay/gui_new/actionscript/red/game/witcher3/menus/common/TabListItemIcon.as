/***********************************************************************
/** HACK
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import scaleform.clik.core.UIComponent;
	
	public class TabListItemIcon extends UIComponent
	{
		public function TabListItemIcon()
		{
			super();
		}
		
		public function ForceSetState( state : String )
		{
			gotoAndPlay ( state );
		}
	}
}
