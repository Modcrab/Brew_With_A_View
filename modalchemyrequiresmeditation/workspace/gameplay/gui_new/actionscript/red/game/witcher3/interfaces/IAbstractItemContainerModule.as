/***********************************************************************
/** Interface Inventory Player grid module & paperdoll module
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.interfaces
{
	import scaleform.clik.interfaces.IUIComponent;
	import red.game.witcher3.menus.common.ItemDataStub;
	
	public interface IAbstractItemContainerModule extends IUIComponent
	{
		function get CurrentItemDataStub():ItemDataStub;
	}
}