package red.game.witcher3.interfaces 
{
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.interfaces.IUIComponent;
	
	/**
	 * Scrolling list interface
	 * @author Yaroslav Getsevich
	 */
	public interface IScrollingList extends IUIComponent
	{
		function getRendererAt(index:uint, offset:int=0):IListItemRenderer
        function get selectedIndex():int;
		function set selectedIndex(value:int):void;
	}
	
}