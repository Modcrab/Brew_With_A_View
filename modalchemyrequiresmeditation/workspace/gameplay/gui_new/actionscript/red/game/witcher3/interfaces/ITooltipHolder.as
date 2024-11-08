package red.game.witcher3.interfaces 
{
	import scaleform.clik.interfaces.IUIComponent;
	
	/**
	 * For controls with tooltip
	 * @author Yaroslav Getsevich
	 */
	public interface ITooltipHolder extends IUIComponent
	{
		function getTooltipKeyData():Array;
	}
}