package red.game.witcher3.menus.inventory_menu 
{
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IDataProvider;
	
	/**
	 * red.game.witcher3.menus.inventory_menu.PlayerGeneralStatsPanel
	 * @author Getsevich Yaroslav
	 */
	public class PlayerGeneralStatsPanel extends UIComponent
	{
		public var mcStatsList:W3ScrollingList;
		public var dataSetterDelegate:Function;
		
		public function PlayerGeneralStatsPanel() 
		{
			mcStatsList.visible = false;
			mcStatsList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
		}
		
		private var _data:Array;
		public function get data():Array { return _data }
		public function set data(value:Array):void
		{
			_data = value;
			mcStatsList.dataProvider = new DataProvider(_data as Array);
			mcStatsList.focused = 1;
			
			if (mcStatsList.selectedIndex == -1)
			{
				mcStatsList.selectedIndex = 0;
			}
		}
		
		private function handleIndexChanged(event:ListEvent):void
		{
			trace("GFX PlayerGeneralStatsPanel :: handleIndexChanged ", event.itemData);
			
			if (dataSetterDelegate != null)
			{
				if (event.itemData && event.itemData.subStats)
				{
					dataSetterDelegate(event.itemData.subStats);
				}
				else
				{
					dataSetterDelegate([]);
				}
			}
			
		}
		
	}
}
