/***********************************************************************
/** Tab icons container, not connected with icons type ...
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import scaleform.clik.core.UIComponent;
	
	public class TabListItemIconsContainer extends UIComponent
	{
		public function TabListItemIconsContainer()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		public function ForceSetState( state : String )
		{
			var mcIconState : TabListItemIcon;
			
			mcIconState = getChildAt(0) as TabListItemIcon; //#B container has only one child at given time
			if(mcIconState)
			{
				mcIconState.ForceSetState( state );
			}
		}
	}
}
