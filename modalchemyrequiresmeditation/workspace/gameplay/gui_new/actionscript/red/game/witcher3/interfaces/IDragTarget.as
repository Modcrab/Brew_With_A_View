package red.game.witcher3.interfaces 
{
	import flash.display.DisplayObject;
	import red.game.witcher3.menus.common.ItemDataStub;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.interfaces.IUIComponent;
	
	/**
	 * Slot data transfer system. Dragable component
	 * @author Yaroslav Getsevich
	 */
	public interface IDragTarget extends IUIComponent
	{
		function getDragData():*;
		function getAvatar():UILoader;
		
		function canDrag():Boolean;
	
		function get dragSelection():Boolean;
        function set dragSelection(value:Boolean):void;
	}
}