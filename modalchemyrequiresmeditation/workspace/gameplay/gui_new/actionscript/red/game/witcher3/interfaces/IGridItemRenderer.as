package red.game.witcher3.interfaces
{
	import scaleform.clik.interfaces.IListItemRenderer;
	
	public interface IGridItemRenderer extends IListItemRenderer
	{
		function get gridSize():int;
		function get data():Object;
		function get uplink():IGridItemRenderer
		function set uplink( value:IGridItemRenderer ):void;
	}
}