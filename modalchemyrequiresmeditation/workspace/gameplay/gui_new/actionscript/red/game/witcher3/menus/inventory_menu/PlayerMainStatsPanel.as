package red.game.witcher3.menus.inventory_menu 
{
	import scaleform.clik.core.UIComponent;
	/**
	 * @author Getsevich Yaroslav
	 */
	public class PlayerMainStatsPanel extends UIComponent
	{
		private var _data:Object;

		
		public function PlayerMainStatsPanel() 
		{
			
		}
		
		public function get data():Object { return _data }
		public function set data(value:Object):void 
		{ 
			_data = value;
		}
		

		
	}

}
