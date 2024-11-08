package red.game.witcher3.interfaces 
{
	import flash.geom.Rectangle;
	import red.game.witcher3.menus.common.ItemDataStub;	
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.interfaces.IUIComponent;
	
	/**
	 * Interface for all type of slots (paperdoll, grid)
	 * @author Yaroslav Getsevich
	 */
	public interface IBaseSlot extends IListItemRenderer, IInteractionObject
	{
		function get data():*;
		function set data(value:*):void;
		
		function get activeSelectionEnabled():Boolean
		function set activeSelectionEnabled(value:Boolean):void
		
		function get useContextMgr():Boolean
		function set useContextMgr(value:Boolean):void
		
		function cleanup():void;
		function isEmpty():Boolean;
		function getSlotRect():Rectangle;
	}
}
